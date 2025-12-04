const PatientService = require('../services/patientService');

class PatientController {
  static async getAllPatients(req, res) {
    try {
      const patients = await PatientService.getAllPatients();
      res.json(patients);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get patients', message: error.message });
    }
  }

  static async getPatientById(req, res) {
    try {
      const patient = await PatientService.getPatientById(req.params.id);
      if (!patient) {
        return res.status(404).json({ error: 'Patient not found' });
      }
      res.json(patient);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get patient', message: error.message });
    }
  }

  static async createPatient(req, res) {
    try {
      const patient = await PatientService.createPatient(req.body);
      res.status(201).json(patient);
    } catch (error) {
      res.status(400).json({ error: 'Failed to create patient', message: error.message });
    }
  }

  static async updatePatient(req, res) {
    try {
      const patient = await PatientService.updatePatient(req.params.id, req.body);
      if (!patient) {
        return res.status(404).json({ error: 'Patient not found' });
      }
      res.json(patient);
    } catch (error) {
      res.status(400).json({ error: 'Failed to update patient', message: error.message });
    }
  }

  static async deletePatient(req, res) {
    try {
      const deleted = await PatientService.deletePatient(req.params.id);
      if (!deleted) {
        return res.status(404).json({ error: 'Patient not found' });
      }
      res.json({ message: 'Patient deleted successfully', id: req.params.id });
    } catch (error) {
      res.status(500).json({ error: 'Failed to delete patient', message: error.message });
    }
  }
}

module.exports = PatientController;