import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/malady.dart';
import '../models/medicament.dart';
import '../models/consultation.dart';
import '../models/patient.dart';
import '../services/api_service.dart';

class ConsultationProvider with ChangeNotifier {
  List<Malady> _maladies = [];
  List<Medicament> _medicaments = [];
  List<Consultation> _consultations = [];
  List<Patient> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Malady> get maladies => _maladies;
  List<Medicament> get medicaments => _medicaments;
  List<Consultation> get consultations => _consultations;
  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Private helper methods (defined first)
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load all maladies from database
  Future<void> loadMaladies() async {
    try {
      _maladies = await ApiService.getMaladies();
      debugPrint('✅ Loaded ${_maladies.length} maladies');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading maladies: $e');
      throw e;
    }
  }

  // Load all medicaments from database
  Future<void> loadMedicaments() async {
    try {
      _medicaments = await ApiService.getMedicaments();
      debugPrint('✅ Loaded ${_medicaments.length} medicaments');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading medicaments: $e');
      throw e;
    }
  }

  // Load patients from database
  Future<void> loadPatients() async {
    try {
      _patients = await ApiService.getPatients();
      debugPrint('✅ Loaded ${_patients.length} patients');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading patients: $e');
      throw e;
    }
  }

  // Initialize data by loading from database
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadMaladies(),
        loadMedicaments(),
        loadPatients(),
      ]);
      _clearError();
    } catch (e) {
      _setError('Failed to initialize data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get medicaments filtered by malady
  List<Medicament> getMedicamentsForMalady(String maladyId) {
    return _medicaments.where((med) => med.maladyId == maladyId).toList();
  }

  // Create a new consultation
  Future<bool> createConsultation({
    required String patientId,
    required String maladyId,
    required String medicamentId,
    String notes = '',
  }) async {
    _setLoading(true);
    try {
      final consultation = Consultation(
        patientId: patientId,
        maladyId: maladyId,
        medicamentId: medicamentId,
        date: DateTime.now(),
        notes: notes,
      );

      debugPrint('🔄 Creating consultation for patient: $patientId');
      final newConsultation = await ApiService.createConsultation(consultation);
      
      _consultations.insert(0, newConsultation); // Add to beginning
      _clearError();
      notifyListeners();
      
      debugPrint('✅ Successfully created consultation: ${newConsultation.id}');
      return true;
    } catch (e) {
      final errorMsg = 'Failed to create consultation: $e';
      debugPrint('❌ $errorMsg');
      _setError(errorMsg);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create a new patient and return the patient object
  Future<Patient?> createPatient({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    try {
      final patient = Patient(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      debugPrint('🔄 Creating patient: $firstName $lastName');
      final newPatient = await ApiService.createPatient(patient);
      
      _patients.add(newPatient);
      notifyListeners();
      
      debugPrint('✅ Successfully created patient: ${newPatient.id}');
      return newPatient;
    } catch (e) {
      debugPrint('❌ Error creating patient: $e');
      _setError('Failed to create patient: $e');
      rethrow; // Re-throw the error so it can be caught by the caller
    }
  }

  // Load consultations from database
  Future<void> loadConsultations() async {
    try {
      _consultations = await ApiService.getConsultations();
      debugPrint('✅ Loaded ${_consultations.length} consultations');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading consultations: $e');
      _setError('Failed to load consultations: $e');
    }
  }

  // Get malady by ID
  Malady? getMaladyById(String id) {
    try {
      return _maladies.firstWhere((malady) => malady.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get medicament by ID
  Medicament? getMedicamentById(String id) {
    try {
      return _medicaments.firstWhere((med) => med.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get patient by ID
  Patient? getPatientById(String id) {
    try {
      return _patients.firstWhere((patient) => patient.id == id);
    } catch (e) {
      return null;
    }
  }

  // CRUD operations for Maladies
  Future<bool> createMalady({
    required String maladyName,
  
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final malady = await ApiService.createMalady({
        'maladyName': maladyName,
       
      });
      
      _maladies.add(malady);
      notifyListeners();
      debugPrint('✅ Created malady: $maladyName');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating malady: $e');
      _setError('Failed to create malady: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteMalady(String id) async {
    try {
      _setLoading(true);
      _clearError();
      
      await ApiService.deleteMalady(id);
      
      _maladies.removeWhere((malady) => malady.id == id);
      notifyListeners();
      debugPrint('✅ Deleted malady: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting malady: $e');
      _setError('Failed to delete malady: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // CRUD operations for Medicaments
  Future<bool> createMedicament({
    required String medicamentName,
    
    required String maladyId,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final medicament = await ApiService.createMedicament({
        'medicamentName': medicamentName,
        
        'maladyId': maladyId,
      });
      
      _medicaments.add(medicament);
      notifyListeners();
      debugPrint('✅ Created medicament: $medicamentName');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating medicament: $e');
      _setError('Failed to create medicament: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteMedicament(String id) async {
    try {
      _setLoading(true);
      _clearError();
      
      await ApiService.deleteMedicament(id);
      
      _medicaments.removeWhere((medicament) => medicament.id == id);
      notifyListeners();
      debugPrint('✅ Deleted medicament: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting medicament: $e');
      _setError('Failed to delete medicament: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

}