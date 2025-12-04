const ConsultationService = require('../services/consultationService');

class ConsultationController {
  static async getAllConsultations(req, res) {
    try {
      const consultations = await ConsultationService.getAllConsultations();
      res.json(consultations);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get consultations', message: error.message });
    }
  }

  static async getConsultationById(req, res) {
    try {
      const consultation = await ConsultationService.getConsultationById(req.params.id);
      if (!consultation) {
        return res.status(404).json({ error: 'Consultation not found' });
      }
      res.json(consultation);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get consultation', message: error.message });
    }
  }

  static async createConsultation(req, res) {
    try {
      const consultation = await ConsultationService.createConsultation(req.body);
      res.status(201).json(consultation);
    } catch (error) {
      res.status(400).json({ error: 'Failed to create consultation', message: error.message });
    }
  }

  static async updateConsultation(req, res) {
    try {
      const consultation = await ConsultationService.updateConsultation(req.params.id, req.body);
      if (!consultation) {
        return res.status(404).json({ error: 'Consultation not found' });
      }
      res.json(consultation);
    } catch (error) {
      res.status(400).json({ error: 'Failed to update consultation', message: error.message });
    }
  }

  static async deleteConsultation(req, res) {
    try {
      const deleted = await ConsultationService.deleteConsultation(req.params.id);
      if (!deleted) {
        return res.status(404).json({ error: 'Consultation not found' });
      }
      res.json({ message: 'Consultation deleted successfully', id: req.params.id });
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete consultation', message: error.message });
    }
  }
}

module.exports = ConsultationController;