const MedicamentService = require('../services/medicamentService');

class MedicamentController {
  static async getAllMedicaments(req, res) {
    try {
      const medicaments = await MedicamentService.getAllMedicaments();
      res.json(medicaments);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get medicaments', message: error.message });
    }
  }

  static async getMedicamentById(req, res) {
    try {
      const medicament = await MedicamentService.getMedicamentById(req.params.id);
      if (!medicament) {
        return res.status(404).json({ error: 'Medicament not found' });
      }
      res.json(medicament);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get medicament', message: error.message });
    }
  }

  static async createMedicament(req, res) {
    try {
      const medicament = await MedicamentService.createMedicament(req.body);
      res.status(201).json(medicament);
    } catch (error) {
      res.status(400).json({ error: 'Failed to create medicament', message: error.message });
    }
  }

  static async updateMedicament(req, res) {
    try {
      const medicament = await MedicamentService.updateMedicament(req.params.id, req.body);
      if (!medicament) {
        return res.status(404).json({ error: 'Medicament not found' });
      }
      res.json(medicament);
    } catch (error) {
      res.status(400).json({ error: 'Failed to update medicament', message: error.message });
    }
  }

  static async deleteMedicament(req, res) {
    try {
      const deleted = await MedicamentService.deleteMedicament(req.params.id);
      if (!deleted) {
        return res.status(404).json({ error: 'Medicament not found' });
      }
      res.json({ message: 'Medicament deleted successfully', id: req.params.id });
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete medicament', message: error.message });
    }
  }
}

module.exports = MedicamentController;