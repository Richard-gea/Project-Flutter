const express = require('express');
const router = express.Router();
const Medicament = require('../models/Medicament');


router.get('/', async (req, res) => {
  try {
    const medicaments = await Medicament.find({ isDeleted: false })
      .populate('malady_id', 'maladyName')
      .sort({ createdAt: -1 });
    res.json({ medicaments, count: medicaments.length });
  } catch (error) {
    console.error('Error fetching medicaments:', error);
    res.status(500).json({ error: 'Failed to fetch medicaments' });
  }
});


router.get('/malady/:maladyId', async (req, res) => {
  try {
    const medicaments = await Medicament.find({ 
      malady_id: req.params.maladyId,
      isDeleted: false 
    }).populate('malady_id', 'maladyName');
    res.json({ medicaments, count: medicaments.length });
  } catch (error) {
    console.error('Error fetching medicaments for malady:', error);
    res.status(500).json({ error: 'Failed to fetch medicaments' });
  }
});


router.post('/', async (req, res) => {
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

router.delete('/:id', async (req, res) => {
  try {
    const medicament = await Medicament.findByIdAndUpdate(
      req.params.id,
      { isDeleted: true },
      { new: true }
    );
    if (!medicament) {
      return res.status(404).json({ error: 'Medicament not found' });
    }
    res.status(200).json({ message: 'Medicament deleted successfully' });
  } catch (error) {
    console.error('Error deleting medicament:', error);
    res.status(500).json({ error: 'Failed to delete medicament' });
  }
});

module.exports = router;
