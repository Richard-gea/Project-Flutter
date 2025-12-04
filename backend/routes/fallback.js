// Fallback routes when database is not available
const express = require('express');
const router = express.Router();

// Mock data for testing
const mockPatients = [
  { _id: '1', nom: 'Test Patient', email: 'test@example.com', age: 30 }
];

const mockMedicaments = [
  { _id: '1', nom: 'Aspirin', description: 'Pain reliever', prix: 10 }
];

const mockMaladies = [
  { _id: '1', nom: 'Headache', description: 'Common pain' }
];

// Patients
router.get('/patients', (req, res) => {
  res.json(mockPatients);
});

router.post('/patients', (req, res) => {
  const newPatient = { _id: Date.now().toString(), ...req.body };
  mockPatients.push(newPatient);
  res.json(newPatient);
});

// Medicaments
router.get('/medicaments', (req, res) => {
  res.json(mockMedicaments);
});

router.post('/medicaments', (req, res) => {
  const newMedicament = { _id: Date.now().toString(), ...req.body };
  mockMedicaments.push(newMedicament);
  res.json(newMedicament);
});

// Maladies
router.get('/maladies', (req, res) => {
  res.json(mockMaladies);
});

router.post('/maladies', (req, res) => {
  const newMalady = { _id: Date.now().toString(), ...req.body };
  mockMaladies.push(newMalady);
  res.json(newMalady);
});

module.exports = router;