// Mock data store (replace with database later)
let consultations = [
  { 
    id: 1, 
    date: '2024-12-04', 
    patientId: 1, 
    patientName: 'John Doe', 
    diagnosis: 'Common Cold',
    prescription: 'Rest and fluids',
    notes: 'Mild symptoms, should recover in 3-5 days'
  },
  { 
    id: 2, 
    date: '2024-12-03', 
    patientId: 2, 
    patientName: 'Jane Smith', 
    diagnosis: 'Influenza',
    prescription: 'Antiviral medication',
    notes: 'Moderate symptoms, monitor for complications'
  }
];

class ConsultationService {
  static async getAllConsultations() {
    return consultations;
  }

  static async getConsultationById(id) {
    return consultations.find(consultation => consultation.id == id);
  }

  static async createConsultation(consultationData) {
    const newConsultation = {
      id: Date.now(),
      ...consultationData,
      createdAt: new Date().toISOString()
    };
    consultations.push(newConsultation);
    return newConsultation;
  }

  static async updateConsultation(id, consultationData) {
    const index = consultations.findIndex(consultation => consultation.id == id);
    if (index === -1) return null;
    
    consultations[index] = {
      ...consultations[index],
      ...consultationData,
      updatedAt: new Date().toISOString()
    };
    return consultations[index];
  }

  static async deleteConsultation(id) {
    const index = consultations.findIndex(consultation => consultation.id == id);
    if (index === -1) return false;
    
    consultations.splice(index, 1);
    return true;
  }
}

module.exports = ConsultationService;