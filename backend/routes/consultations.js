const express = require('express');
const router = express.Router();
const ConsultationController = require('../controllers/consultationController');

// GET /api/consultations - Get all consultations
router.get('/', ConsultationController.getAllConsultations);

// GET /api/consultations/:id - Get consultation by ID
router.get('/:id', ConsultationController.getConsultationById);

// POST /api/consultations - Create new consultation
router.post('/', ConsultationController.createConsultation);

// PUT /api/consultations/:id - Update consultation
router.put('/:id', ConsultationController.updateConsultation);

// DELETE /api/consultations/:id - Delete consultation
router.delete('/:id', ConsultationController.deleteConsultation);

module.exports = router;

// Get all consultations (not deleted)
router.get('/', async (req, res) => {
  try {
    const consultations = await Consultation.find({ isDeleted: false })
      .populate('patient_id', 'firstName lastName email')
      .populate('malady_id', 'maladyName')
      .populate('medicament_id', 'medicamentName')
      .sort({ createdAt: -1 });
    res.json({ consultations, count: consultations.length });
  } catch (error) {
    console.error('Error fetching consultations:', error);
    res.status(500).json({ error: 'Failed to fetch consultations' });
  }
});

// Get a single consultation by ID
router.get('/:id', async (req, res) => {
  try {
    const consultation = await Consultation.findOne({ 
      _id: req.params.id, 
      isDeleted: false 
    })
      .populate('patient_id', 'firstName lastName email')
      .populate('malady_id', 'maladyName')
      .populate('medicament_id', 'medicamentName');
    
    if (!consultation) {
      return res.status(404).json({ error: 'Consultation not found' });
    }
    res.json({ consultation });
  } catch (error) {
    console.error('Error fetching consultation:', error);
    res.status(500).json({ error: 'Failed to fetch consultation' });
  }
});

// Create a new consultation
router.post('/', async (req, res) => {
  try {
    const { patientId, maladyId, medicamentId, date } = req.body;
    
    if (!patientId || !maladyId || !medicamentId) {
      return res.status(400).json({ error: 'Patient ID, Malady ID, and Medicament ID are required' });
    }
    
    const consultation = new Consultation({
      patient_id: patientId,
      malady_id: maladyId,
      medicament_id: medicamentId,
      date: date || Date.now(),
     
    });
    
    const savedConsultation = await consultation.save();
    const populatedConsultation = await Consultation.findById(savedConsultation._id)
      .populate('patient_id', 'firstName lastName email')
      .populate('malady_id', 'maladyName')
      .populate('medicament_id', 'medicamentName');
    
    res.status(201).json({ consultation: populatedConsultation });
  } catch (error) {
    console.error('Error creating consultation:', error);
    res.status(400).json({ error: error.message });
  }
});

// Soft delete a consultation
router.delete('/:id', async (req, res) => {
  try {
    const consultation = await Consultation.findByIdAndUpdate(
      req.params.id,
      { isDeleted: true },
      { new: true }
    );
    if (!consultation) {
      return res.status(404).json({ error: 'Consultation not found' });
    }
    res.status(200).json({ message: 'Consultation deleted successfully' });
  } catch (error) {
    console.error('Error deleting consultation:', error);
    res.status(500).json({ error: 'Failed to delete consultation' });
  }
});

module.exports = router;
