const express = require('express');
const router = express.Router();
const Malady = require('../models/Malady');
const Medicament = require('../models/Medicament');

// Get all maladies (not deleted)
router.get('/', async (req, res) => {
  try {
    const maladies = await Malady.find({ isDeleted: false }).sort({ createdAt: -1 });
    res.json({ maladies, count: maladies.length });
  } catch (error) {
    console.error('Error fetching maladies:', error);
    res.status(500).json({ error: 'Failed to fetch maladies' });
  }
});

// Create a new malady
router.post('/', async (req, res) => {
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

// Soft delete a malady and its related medicaments
router.delete('/:id', async (req, res) => {
  try {
    const malady = await Malady.findByIdAndUpdate(
      req.params.id,
      { isDeleted: true },
      { new: true }
    );
    if (!malady) {
      return res.status(404).json({ error: 'Malady not found' });
    }
    
    // Soft delete all medicaments associated with this malady
    await Medicament.updateMany(
      { malady_id: req.params.id },
      { isDeleted: true }
    );
    console.log(`✅ Soft deleted malady: ${malady.maladyName} and its related medicaments`);
    
    res.status(200).json({ message: 'Malady deleted successfully' });
  } catch (error) {
    console.error('Error deleting malady:', error);
    res.status(500).json({ error: 'Failed to delete malady' });
  }
});

module.exports = router;
