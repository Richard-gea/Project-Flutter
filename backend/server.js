const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(express.json());

// Health check endpoint for Elastic Beanstalk
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'OK', 
    message: 'PharmaX Server is running',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: '🏥 PharmaX API',
    status: 'running',
    endpoints: ['/health', '/api/patients', '/api/medicaments', '/api/maladies']
  });
});

// Simple mock data for testing
const mockPatients = [
  { _id: '1', nom: 'John Doe', email: 'john@test.com', age: 30, telephone: '123456789' }
];

const mockMedicaments = [
  { _id: '1', nom: 'Paracetamol', description: 'Pain reliever', prix: 15.50 }
];

const mockMaladies = [
  { _id: '1', nom: 'Flu', description: 'Common cold symptoms' }
];

// API Routes
app.get('/api/patients', (req, res) => {
  res.json(mockPatients);
});

app.post('/api/patients', (req, res) => {
  const newPatient = { _id: Date.now().toString(), ...req.body };
  mockPatients.push(newPatient);
  res.json(newPatient);
});

app.get('/api/medicaments', (req, res) => {
  res.json(mockMedicaments);
});

app.post('/api/medicaments', (req, res) => {
  const newMedicament = { _id: Date.now().toString(), ...req.body };
  mockMedicaments.push(newMedicament);
  res.json(newMedicament);
});

app.get('/api/maladies', (req, res) => {
  res.json(mockMaladies);
});

app.post('/api/maladies', (req, res) => {
  const newMalady = { _id: Date.now().toString(), ...req.body };
  mockMaladies.push(newMalady);
  res.json(newMalady);
});

app.get('/api/consultations', (req, res) => {
  res.json([]);
});

app.post('/api/consultations', (req, res) => {
  res.json({ _id: Date.now().toString(), ...req.body });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 PharmaX Server running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/health`);
});
