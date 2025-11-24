const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// MongoDB connection URI
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/pharmax';

// Middleware
app.use(cors());
app.use(express.json());

// ================================
// 📊 DATABASE SCHEMAS (4 Collections)
// ================================

// 1️⃣ PATIENTS Collection
const patientSchema = new mongoose.Schema({
  firstName: {
    type: String,
    required: [true, 'First name is required'],
    trim: true,
    minlength: 2
  },
  lastName: {
    type: String,
    required: [true, 'Last name is required'],
    trim: true,
    minlength: 2
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    trim: true,
    lowercase: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
  }
}, {
  timestamps: true
});

// 2️⃣ MALADIES Collection
const maladySchema = new mongoose.Schema({
  maladyName: {
    type: String,
    required: [true, 'Malady name is required'],
    unique: true,
    trim: true
  },
}, {
  timestamps: true
});

// 3️⃣ MEDICAMENTS Collection
const medicamentSchema = new mongoose.Schema({
  medicamentName: {
    type: String,
    required: [true, 'Medicament name is required'],
    trim: true
  },
  malady_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Malady',
    required: [true, 'Malady ID is required']
  }
}, {
  timestamps: true
});

// 4️⃣ CONSULTATIONS Collection
const consultationSchema = new mongoose.Schema({
  patient_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: [true, 'Patient ID is required']
  },
  malady_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Malady',
    required: [true, 'Malady ID is required']
  },
  medicament_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Medicament',
    required: [true, 'Medicament ID is required']
  },
  date: {
    type: Date,
    default: Date.now,
    required: true
  },
}, {
  timestamps: true
});

// Create Models
const Patient = mongoose.model('Patient', patientSchema);
const Malady = mongoose.model('Malady', maladySchema);
const Medicament = mongoose.model('Medicament', medicamentSchema);
const Consultation = mongoose.model('Consultation', consultationSchema);

// ================================
// 🔗 MONGODB CONNECTION
// ================================

async function connectToMongoDB() {
  try {
    await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB');
    console.log(`🌐 Database: ${mongoose.connection.name}`);
    console.log(`📍 Host: ${mongoose.connection.host}:${mongoose.connection.port}`);
    
    // Initialize sample data
    await initializeSampleData();
  } catch (error) {
    console.error('❌ MongoDB Connection Error:', error.message);
   
    process.exit(1);
  }
}

// ================================
// 🎯 INITIALIZE SAMPLE DATA
// ================================

async function initializeSampleData() {
  try {
    // Check if we already have data
    const maladyCount = await Malady.countDocuments();
    
    if (maladyCount === 0) {
      console.log('🔧 Initializing sample data...');
      
      // Create sample maladies
      const sampleMaladies = [
        { maladyName: 'Diabetes' },
        { maladyName: 'Hypertension' },
        { maladyName: 'Flu' },
        { maladyName: 'Asthma' },
        { maladyName: 'Migraine' }
      ];
      
      const createdMaladies = await Malady.insertMany(sampleMaladies);
      console.log(`✅ Created ${createdMaladies.length} sample maladies`);
      
      // Create sample medicaments
      const sampleMedicaments = [
        { medicamentName: 'Metformin',  malady_id: createdMaladies[0]._id },
        { medicamentName: 'Insulin', malady_id: createdMaladies[0]._id },
        { medicamentName: 'Lisinopril', malady_id: createdMaladies[1]._id },
        { medicamentName: 'Amlodipine',  malady_id: createdMaladies[1]._id },
        { medicamentName: 'Tamiflu',  malady_id: createdMaladies[2]._id },
        { medicamentName: 'Albuterol',  malady_id: createdMaladies[3]._id },
        { medicamentName: 'Sumatriptan',  malady_id: createdMaladies[4]._id }
      ];
      
      const createdMedicaments = await Medicament.insertMany(sampleMedicaments);
      console.log(`✅ Created ${createdMedicaments.length} sample medicaments`);
    }
  } catch (error) {
    console.error('⚠️ Error initializing sample data:', error.message);
  }
}

// ================================
// 🏥 API ROUTES - PATIENTS
// ================================

// Get all patients
app.get('/api/patients', async (req, res) => {
  try {
    const patients = await Patient.find().sort({ createdAt: -1 });
    res.json({ patients, count: patients.length });
  } catch (error) {
    console.error('Error fetching patients:', error);
    res.status(500).json({ error: 'Failed to fetch patients' });
  }
});

// Create new patient
app.post('/api/patients', async (req, res) => {
  try {
    const { firstName, lastName, email } = req.body;
    
    const patient = new Patient({ firstName, lastName, email });
    const savedPatient = await patient.save();
    
    console.log(`✅ Created patient: ${firstName} ${lastName}`);
    res.status(201).json({ patient: savedPatient, message: 'Patient created successfully' });
  } catch (error) {
    console.error('Error creating patient:', error);
    if (error.code === 11000) {
      res.status(400).json({ error: 'Email already exists' });
    } else {
      res.status(400).json({ error: error.message });
    }
  }
});

// Get patient by ID
app.get('/api/patients/:id', async (req, res) => {
  try {
    const patient = await Patient.findById(req.params.id);
    if (!patient) {
      return res.status(404).json({ error: 'Patient not found' });
    }
    res.json({ patient });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch patient' });
  }
});

// ================================
// 💊 API ROUTES - MALADIES
// ================================

// Get all maladies
app.get('/api/maladies', async (req, res) => {
  try {
    const maladies = await Malady.find().sort({ maladyName: 1 });
    res.json({ maladies, count: maladies.length });
  } catch (error) {
    console.error('Error fetching maladies:', error);
    res.status(500).json({ error: 'Failed to fetch maladies' });
  }
});

// Create new malady
app.post('/api/maladies', async (req, res) => {
  try {
    const { maladyName, description } = req.body;
    const malady = new Malady({ maladyName, description });
    const savedMalady = await malady.save();
    
    console.log(`✅ Created malady: ${maladyName}`);
    res.status(201).json({ malady: savedMalady, message: 'Malady created successfully' });
  } catch (error) {
    console.error('Error creating malady:', error);
    res.status(400).json({ error: error.message });
  }
});

// ================================
// 💉 API ROUTES - MEDICAMENTS
// ================================

// Get all medicaments
app.get('/api/medicaments', async (req, res) => {
  try {
    const medicaments = await Medicament.find().populate('malady_id', 'maladyName').sort({ medicamentName: 1 });
    res.json({ medicaments, count: medicaments.length });
  } catch (error) {
    console.error('Error fetching medicaments:', error);
    res.status(500).json({ error: 'Failed to fetch medicaments' });
  }
});

// Get medicaments by malady
app.get('/api/medicaments/malady/:maladyId', async (req, res) => {
  try {
    const medicaments = await Medicament.find({ malady_id: req.params.maladyId }).populate('malady_id', 'maladyName');
    res.json({ medicaments, count: medicaments.length });
  } catch (error) {
    console.error('Error fetching medicaments for malady:', error);
    res.status(500).json({ error: 'Failed to fetch medicaments' });
  }
});

// Create new medicament
app.post('/api/medicaments', async (req, res) => {
  try {
    const { medicamentName, description, malady_id } = req.body;
    const medicament = new Medicament({ medicamentName, description, malady_id });
    const savedMedicament = await medicament.save();
    
    console.log(`✅ Created medicament: ${medicamentName}`);
    res.status(201).json({ medicament: savedMedicament, message: 'Medicament created successfully' });
  } catch (error) {
    console.error('Error creating medicament:', error);
    res.status(400).json({ error: error.message });
  }
});

// ================================
// 🏥 API ROUTES - CONSULTATIONS
// ================================

// Get all consultations with full details
app.get('/api/consultations', async (req, res) => {
  try {
    const consultations = await Consultation.find()
      .populate('patient_id', 'firstName lastName email')
      .populate('malady_id', 'maladyName description')
      .populate('medicament_id', 'medicamentName description')
      .sort({ date: -1 });
      
    res.json({ consultations, count: consultations.length });
  } catch (error) {
    console.error('Error fetching consultations:', error);
    res.status(500).json({ error: 'Failed to fetch consultations' });
  }
});

// Create new consultation (Doctor adds patient)
app.post('/api/consultations', async (req, res) => {
  try {
    const { patient_id, malady_id, medicament_id, date, notes } = req.body;
    
    const consultation = new Consultation({
      patient_id,
      malady_id,
      medicament_id,
      date: date || new Date(),
      notes
    });
    
    const savedConsultation = await consultation.save();
    
    // Populate the saved consultation for response
    const populatedConsultation = await Consultation.findById(savedConsultation._id)
      .populate('patient_id', 'firstName lastName email')
      .populate('malady_id', 'maladyName description')
      .populate('medicament_id', 'medicamentName description');
    
    console.log(`✅ Created consultation for patient: ${populatedConsultation.patient_id.firstName}`);
    res.status(201).json({ 
      consultation: populatedConsultation, 
      message: 'Consultation created successfully' 
    });
  } catch (error) {
    console.error('Error creating consultation:', error);
    res.status(400).json({ error: error.message });
  }
});

// Get consultations by patient
app.get('/api/consultations/patient/:patientId', async (req, res) => {
  try {
    const consultations = await Consultation.find({ patient_id: req.params.patientId })
      .populate('malady_id', 'maladyName description')
      .populate('medicament_id', 'medicamentName description')
      .sort({ date: -1 });
      
    res.json({ consultations, count: consultations.length });
  } catch (error) {
    console.error('Error fetching patient consultations:', error);
    res.status(500).json({ error: 'Failed to fetch consultations' });
  }
});

// ================================
// 🔍 HEALTH CHECK
// ================================

app.get('/health', (req, res) => {
  const mongoStatus = mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected';
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    database: mongoStatus,
    collections: ['patients', 'maladies', 'medicaments', 'consultations']
  });
});

// ================================
// 📊 STATISTICS
// ================================

app.get('/api/stats', async (req, res) => {
  try {
    const stats = await Promise.all([
      Patient.countDocuments(),
      Malady.countDocuments(),
      Medicament.countDocuments(),
      Consultation.countDocuments()
    ]);
    
    res.json({
      patients: stats[0],
      maladies: stats[1],
      medicaments: stats[2],
      consultations: stats[3],
      lastUpdated: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error fetching statistics:', error);
    res.status(500).json({ error: 'Failed to fetch statistics' });
  }
});

// ================================
// 🚀 START SERVER
// ================================

// Connect to MongoDB and start server
connectToMongoDB().then(() => {
  app.listen(PORT, () => {
    console.log(`\\n🚀 PharmaX Backend Server running on port ${PORT}`);
    console.log(`📋 API available at: http://localhost:${PORT}/api`);
    console.log(`🔍 Health check: http://localhost:${PORT}/health`);
    
    console.log(`\\n📚 Available Endpoints:`);
    console.log('  🏥 PATIENTS:');
    console.log('    GET    /api/patients           - Get all patients');
    console.log('    POST   /api/patients           - Create patient');
    console.log('    GET    /api/patients/:id       - Get patient by ID');
    console.log('  💊 MALADIES:');
    console.log('    GET    /api/maladies           - Get all maladies');
    console.log('    POST   /api/maladies           - Create malady');
    console.log('  💉 MEDICAMENTS:');
    console.log('    GET    /api/medicaments        - Get all medicaments');
    console.log('    GET    /api/medicaments/malady/:id - Get by malady');
    console.log('    POST   /api/medicaments        - Create medicament');
    console.log('  🏥 CONSULTATIONS:');
    console.log('    GET    /api/consultations      - Get all consultations');
    console.log('    POST   /api/consultations      - Create consultation');
    console.log('    GET    /api/consultations/patient/:id - Get by patient');
    console.log('  📊 STATS:');
    console.log('    GET    /api/stats              - Get statistics');
    console.log('    GET    /health                 - Health check');
    
    console.log(`\\n🛑 Press Ctrl+C to stop server\\n`);
  });
});

// Handle graceful shutdown
process.on('SIGINT', async () => {
  console.log('\\n🛑 Shutting down server...');
  await mongoose.connection.close();
  process.exit(0);
});