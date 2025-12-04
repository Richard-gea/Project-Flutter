// Mock data store (replace with database later)
let medicaments = [
  { id: 1, name: 'Aspirin', dosage: '500mg', price: 5.99, manufacturer: 'PharmaCorp' },
  { id: 2, name: 'Ibuprofen', dosage: '200mg', price: 7.50, manufacturer: 'MediLab' },
  { id: 3, name: 'Paracetamol', dosage: '500mg', price: 4.25, manufacturer: 'HealthPlus' }
];

class MedicamentService {
  static async getAllMedicaments() {
    return medicaments;
  }

  static async getMedicamentById(id) {
    return medicaments.find(medicament => medicament.id == id);
  }

  static async createMedicament(medicamentData) {
    const newMedicament = {
      id: Date.now(),
      ...medicamentData,
      createdAt: new Date().toISOString()
    };
    medicaments.push(newMedicament);
    return newMedicament;
  }

  static async updateMedicament(id, medicamentData) {
    const index = medicaments.findIndex(medicament => medicament.id == id);
    if (index === -1) return null;
    
    medicaments[index] = {
      ...medicaments[index],
      ...medicamentData,
      updatedAt: new Date().toISOString()
    };
    return medicaments[index];
  }

  static async deleteMedicament(id) {
    const index = medicaments.findIndex(medicament => medicament.id == id);
    if (index === -1) return false;
    
    medicaments.splice(index, 1);
    return true;
  }
}

module.exports = MedicamentService;