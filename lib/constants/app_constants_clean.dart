class AppConstants {
  // Default sick type
  static const String defaultSickType = 'Flu';
  
  // Available sick types and their corresponding medications
  static const Map<String, List<String>> sickTypeMedicaments = {
    'Flu': [
      'Paracetamol',
      'Ibuprofen',
      'Aspirin',
      'Oseltamivir (Tamiflu)',
    ],
    'Headache': [
      'Paracetamol',
      'Ibuprofen',
      'Aspirin',
      'Sumatriptan',
    ],
    'Fever': [
      'Paracetamol',
      'Ibuprofen',
      'Aspirin',
      'Acetaminophen',
    ],
    'Cold': [
      'Paracetamol',
      'Pseudoephedrine',
      'Guaifenesin',
      'Dextromethorphan',
    ],
    'Cough': [
      'Dextromethorphan',
      'Guaifenesin',
      'Codeine',
      'Honey-based syrup',
    ],
    'Allergies': [
      'Antihistamines',
      'Cetirizine',
      'Loratadine',
      'Diphenhydramine',
    ],
    'Stomach Ache': [
      'Antacids',
      'Omeprazole',
      'Simethicone',
      'Bismuth subsalicylate',
    ],
    'Diarrhea': [
      'Loperamide',
      'Bismuth subsalicylate',
      'Oral rehydration salts',
      'Probiotics',
    ],
    'Constipation': [
      'Fiber supplements',
      'Laxatives',
      'Docusate sodium',
      'Polyethylene glycol',
    ],
    'High Blood Pressure': [
      'ACE inhibitors',
      'Beta blockers',
      'Diuretics',
      'Calcium channel blockers',
    ],
    'Diabetes': [
      'Metformin',
      'Insulin',
      'Sulfonylureas',
      'DPP-4 inhibitors',
    ],
    'Anxiety': [
      'Benzodiazepines',
      'SSRIs',
      'Beta blockers',
      'Buspirone',
    ],
    'Depression': [
      'SSRIs',
      'SNRIs',
      'Tricyclic antidepressants',
      'MAO inhibitors',
    ],
    'Insomnia': [
      'Melatonin',
      'Zolpidem',
      'Diphenhydramine',
      'Trazodone',
    ],
    'Back Pain': [
      'Ibuprofen',
      'Naproxen',
      'Muscle relaxants',
      'Topical analgesics',
    ],
    'Arthritis': [
      'NSAIDs',
      'Disease-modifying antirheumatic drugs',
      'Corticosteroids',
      'Biologics',
    ],
    'Migraine': [
      'Sumatriptan',
      'Ergotamine',
      'Beta blockers',
      'Anticonvulsants',
    ],
    'Asthma': [
      'Bronchodilators',
      'Corticosteroids',
      'Leukotriene modifiers',
      'Long-acting beta agonists',
    ],
  };

  // Get all available sick types
  static List<String> get allSickTypes {
    return sickTypeMedicaments.keys.toList()..sort();
  }

  // Get medicaments for a specific sick type
  static List<String> getMedicamentsForSickType(String sickType) {
    return sickTypeMedicaments[sickType] ?? ['Paracetamol'];
  }

  // Check if a sick type exists
  static bool sickTypeExists(String sickType) {
    return sickTypeMedicaments.containsKey(sickType);
  }

  // Get all unique medicaments
  static List<String> get allMedicaments {
    final Set<String> allMeds = {};
    for (final medicaments in sickTypeMedicaments.values) {
      allMeds.addAll(medicaments);
    }
    return allMeds.toList()..sort();
  }

  // Common phone number patterns for validation
  static final RegExp phoneRegExp = RegExp(r'^[\+]?[\d\s\-\(\)]{10,}$');

  // Validation messages
  static const String nameValidationMessage = 'Name cannot be empty';
  static const String phoneValidationMessage = 'Please enter a valid phone number';
  static const String sickTypeValidationMessage = 'Please select a condition';
  static const String medicamentValidationMessage = 'Please select a medication';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  
  // Success messages
  static const String patientAddedSuccessMessage = 'Patient added successfully!';
  static const String patientUpdatedSuccessMessage = 'Patient updated successfully!';
  static const String patientDeletedSuccessMessage = 'Patient deleted successfully!';
  
  // Error messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred.';
}