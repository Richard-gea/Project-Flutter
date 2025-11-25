const express = require('express');
const router = express.Router();
const Patient = require('../models/Patient');

// Get all patients (not deleted)
router.get('/', async (req, res) => {
  try {
    const patients = await Patient.find({ isDeleted: false }).sort({ createdAt: -1 });
    res.json({ patients, count: patients.length });
  } catch (error) {
    console.error('Error fetching patients:', error);
    res.status(500).json({ error: 'Failed to fetch patients' });
  }
});

// Create a new patient
router.post('/', async (req, res) => {
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

module.exports = router;
