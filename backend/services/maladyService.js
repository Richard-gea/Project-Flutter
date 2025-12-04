// Mock data store (replace with database later)
let maladies = [
  { id: 1, name: 'Common Cold', severity: 'mild', symptoms: ['cough', 'fever', 'runny nose'] },
  { id: 2, name: 'Influenza', severity: 'moderate', symptoms: ['fever', 'headache', 'muscle aches'] },
  { id: 3, name: 'Pneumonia', severity: 'severe', symptoms: ['chest pain', 'difficulty breathing', 'high fever'] }
];

class MaladyService {
  static async getAllMaladies() {
    return maladies;
  }

  static async getMaladyById(id) {
    return maladies.find(malady => malady.id == id);
  }

  static async createMalady(maladyData) {
    const newMalady = {
      id: Date.now(),
      ...maladyData,
      createdAt: new Date().toISOString()
    };
    maladies.push(newMalady);
    return newMalady;
  }

  static async updateMalady(id, maladyData) {
    const index = maladies.findIndex(malady => malady.id == id);
    if (index === -1) return null;
    
    maladies[index] = {
      ...maladies[index],
      ...maladyData,
      updatedAt: new Date().toISOString()
    };
    return maladies[index];
  }

  static async deleteMalady(id) {
    const index = maladies.findIndex(malady => malady.id == id);
    if (index === -1) return false;
    
    maladies.splice(index, 1);
    return true;
  }
}

module.exports = MaladyService;