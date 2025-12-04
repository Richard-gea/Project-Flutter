const MaladyService = require('../services/maladyService');

class MaladyController {
  static async getAllMaladies(req, res) {
    try {
      const maladies = await MaladyService.getAllMaladies();
      res.json(maladies);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get maladies', message: error.message });
    }
  }

  static async getMaladyById(req, res) {
    try {
      const malady = await MaladyService.getMaladyById(req.params.id);
      if (!malady) {
        return res.status(404).json({ error: 'Malady not found' });
      }
      res.json(malady);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get malady', message: error.message });
    }
  }

  static async createMalady(req, res) {
    try {
      const malady = await MaladyService.createMalady(req.body);
      res.status(201).json(malady);
    } catch (error) {
      res.status(400).json({ error: 'Failed to create malady', message: error.message });
    }
  }

  static async updateMalady(req, res) {
    try {
      const malady = await MaladyService.updateMalady(req.params.id, req.body);
      if (!malady) {
        return res.status(404).json({ error: 'Malady not found' });
      }
      res.json(malady);
    } catch (error) {
      res.status(400).json({ error: 'Failed to update malady', message: error.message });
    }
  }

  static async deleteMalady(req, res) {
    try {
      const deleted = await MaladyService.deleteMalady(req.params.id);
      if (!deleted) {
        return res.status(404).json({ error: 'Malady not found' });
      }
      res.json({ message: 'Malady deleted successfully', id: req.params.id });
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete malady', message: error.message });
    }
  }
}

module.exports = MaladyController;