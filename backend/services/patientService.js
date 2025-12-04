// Mock data store (replace with database later)
let patients = [
  { id: 1, name: 'John Doe', age: 30, email: 'john@example.com', phone: '123-456-7890' },
  { id: 2, name: 'Jane Smith', age: 25, email: 'jane@example.com', phone: '098-765-4321' }
];

class PatientService {
  static async getAllPatients() {
    return patients;
  }

  static async getPatientById(id) {
    return patients.find(patient => patient.id == id);
  }

  static async createPatient(patientData) {
    const newPatient = {
      id: Date.now(),
      ...patientData,
      createdAt: new Date().toISOString()
    };
    patients.push(newPatient);
    return newPatient;
  }

  static async updatePatient(id, patientData) {
    const index = patients.findIndex(patient => patient.id == id);
    if (index === -1) return null;
    
    patients[index] = {
      ...patients[index],
      ...patientData,
      updatedAt: new Date().toISOString()
    };
    return patients[index];
  }

  static async deletePatient(id) {
    const index = patients.findIndex(patient => patient.id == id);
    if (index === -1) return false;
    
    patients.splice(index, 1);
    return true;
  }
}

module.exports = PatientService;