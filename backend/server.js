const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/pharmax';

app.use(cors());
app.use(express.json());

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
  }
}, {
  timestamps: true
});

const Patient = mongoose.model('Patient', patientSchema);
const Malady = mongoose.model('Malady', maladySchema);
const Medicament = mongoose.model('Medicament', medicamentSchema);
const Consultation = mongoose.model('Consultation', consultationSchema);

async function connectToMongoDB() {
  try {
    await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    await initializeSampleData();
  } catch (error) {
    console.error('MongoDB Connection Error:', error.message);
    process.exit(1);
  }
}

async function initializeSampleData() {
  try {
    const maladyCount = await Malady.countDocuments();
    if (maladyCount === 0) {
      const sampleMaladies = [
        { maladyName: 'Diabetes' },
        { maladyName: 'Hypertension' },
        { maladyName: 'Flu' },
        { maladyName: 'Asthma' },
        { maladyName: 'Migraine' }
      ];
      const createdMaladies = await Malady.insertMany(sampleMaladies);
      const sampleMedicaments = [
        { medicamentName: 'Metformin',  malady_id: createdMaladies[0]._id },
        { medicamentName: 'Insulin', malady_id: createdMaladies[0]._id },
        { medicamentName: 'Lisinopril', malady_id: createdMaladies[1]._id },
        { medicamentName: 'Amlodipine',  malady_id: createdMaladies[1]._id },
        { medicamentName: 'Tamiflu',  malady_id: createdMaladies[2]._id },
        { medicamentName: 'Albuterol',  malady_id: createdMaladies[3]._id },
        { medicamentName: 'Sumatriptan',  malady_id: createdMaladies[4]._id }
      ];
      await Medicament.insertMany(sampleMedicaments);
    }
  } catch (error) {
    console.error('Error initializing sample data:', error.message);
  }
}

app.get('/api/patients', async (req, res) => {
  try {
    const patients = await Patient.find().sort({ createdAt: -1 });
    res.json({ patients, count: patients.length });
  } catch (error) {
    console.error('Error fetching patients:', error);
    res.status(500).json({ error: 'Failed to fetch patients' });
  }
});

app.post('/api/patients', async (req, res) => {
  try {
    const { firstName, lastName, email } = req.body;
    const patient = new Patient({ firstName, lastName, email });
    const savedPatient = await patient.save();
    res.status(201).json({ patient: savedPatient });
  } catch (error) {
    console.error('Error creating patient:', error);
    if (error.code === 11000) {
      res.status(400).json({ error: 'Email already exists' });
    } else {
      res.status(400).json({ error: error.message });
    }
  }
});

app.get('/api/maladies', async (req, res) => {
  try {
    const maladies = await Malady.find().sort({ createdAt: -1 });
    res.json({ maladies, count: maladies.length });
  } catch (error) {
    console.error('Error fetching maladies:', error);
    res.status(500).json({ error: 'Failed to fetch maladies' });
  }
});

app.post('/api/maladies', async (req, res) => {
  try {
    const { maladyName } = req.body;
    if (!maladyName || maladyName.trim() === '') {
      return res.status(400).json({ error: 'Malady name is required' });
    }
    const malady = new Malady({ maladyName: maladyName.trim() });
    const savedMalady = await malady.save();
    res.status(201).json({ malady: savedMalady });
  } catch (error) {
    console.error('Error creating malady:', error);
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/maladies/:id', async (req, res) => {
  try {
    const deletedMalady = await Malady.findByIdAndDelete(req.params.id);
    if (!deletedMalady) {
      return res.status(404).json({ error: 'Malady not found' });
    }
    
    // Delete all medicaments associated with this malady
    await Medicament.deleteMany({ malady_id: req.params.id });
    console.log(`✅ Deleted malady: ${deletedMalady.maladyName} and its related medicaments`);
    
    res.status(200).json({ message: 'Malady deleted successfully' });
  } catch (error) {
    console.error('Error deleting malady:', error);
    res.status(500).json({ error: 'Failed to delete malady' });
  }
});

app.get('/api/medicaments', async (req, res) => {
  try {
    const medicaments = await Medicament.find().populate('malady_id', 'maladyName').sort({ createdAt: -1 });
    res.json({ medicaments, count: medicaments.length });
  } catch (error) {
    console.error('Error fetching medicaments:', error);
    res.status(500).json({ error: 'Failed to fetch medicaments' });
  }
});

app.get('/api/medicaments/malady/:maladyId', async (req, res) => {
  try {
    const medicaments = await Medicament.find({ malady_id: req.params.maladyId }).populate('malady_id', 'maladyName');
    res.json({ medicaments, count: medicaments.length });
  } catch (error) {
    console.error('Error fetching medicaments for malady:', error);
    res.status(500).json({ error: 'Failed to fetch medicaments' });
  }
});

app.post('/api/medicaments', async (req, res) => {
  try {
    const { medicamentName, maladyId } = req.body;
    if (!medicamentName || medicamentName.trim() === '') {
      return res.status(400).json({ error: 'Medicament name is required' });
    }
    if (!maladyId) {
      return res.status(400).json({ error: 'Malady ID is required' });
    }
    const medicament = new Medicament({ 
      medicamentName: medicamentName.trim(), 
      malady_id: maladyId 
    });
    const savedMedicament = await medicament.save();
    res.status(201).json({ medicament: savedMedicament });
  } catch (error) {
    console.error('Error creating medicament:', error);
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/medicaments/:id', async (req, res) => {
  try {
    const deletedMedicament = await Medicament.findByIdAndDelete(req.params.id);
    if (!deletedMedicament) {
      return res.status(404).json({ error: 'Medicament not found' });
    }
    res.status(200).json({ message: 'Medicament deleted successfully' });
  } catch (error) {
    console.error('Error deleting medicament:', error);
    res.status(500).json({ error: 'Failed to delete medicament' });
  }
});

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
    const populatedConsultation = await Consultation.findById(savedConsultation._id)
      .populate('patient_id', 'firstName lastName email')
      .populate('malady_id', 'maladyName description')
      .populate('medicament_id', 'medicamentName description');
    res.status(201).json({ consultation: populatedConsultation });
  } catch (error) {
    console.error('Error creating consultation:', error);
    res.status(400).json({ error: error.message });
  }
});

app.get('/api/consultations/patient/:patientId', async (req, res) => {
  try {
    const consultations = await Consultation.find({ 
      patient_id: req.params.patientId
    })
      .populate('malady_id', 'maladyName description')
      .populate('medicament_id', 'medicamentName description')
      .sort({ date: -1 });
    res.json({ consultations, count: consultations.length });
  } catch (error) {
    console.error('Error fetching patient consultations:', error);
    res.status(500).json({ error: 'Failed to fetch consultations' });
  }
});

// Soft delete consultation
app.patch('/api/consultations/:id', async (req, res) => {
  try {
    const consultation = await Consultation.findByIdAndDelete(req.params.id);
    
    if (!consultation) {
      return res.status(404).json({ error: 'Consultation not found' });
    }
    
    console.log(`🗑️ Deleted consultation: ${req.params.id}`);
    res.json({ message: 'Consultation deleted successfully', consultation });
  } catch (error) {
    console.error('Error deleting consultation:', error);
    res.status(500).json({ error: 'Failed to delete consultation' });
  }
});

app.get('/health', (req, res) => {
  const mongoStatus = mongoose.connection.readyState === 1 ? 'Connected' : 'Disconnected';
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    database: mongoStatus,
    collections: ['patients', 'maladies', 'medicaments', 'consultations']
  });
});

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

connectToMongoDB().then(() => {
  app.listen(PORT);
});

process.on('SIGINT', async () => {
  await mongoose.connection.close();
  process.exit(0);
});
