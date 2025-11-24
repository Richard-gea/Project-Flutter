import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../services/api_service.dart';

class PatientProvider with ChangeNotifier {
  List<Patient> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _statistics;
  bool _isConnected = false;

  // Getters
  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasData => _patients.isNotEmpty;
  bool get isConnected => _isConnected;
  Map<String, dynamic>? get statistics => _statistics;

  // Initialize and test MongoDB connection
  Future<void> initializeConnection() async {
    await loadPatients();
    await loadStatistics();
  }

  // Test connection to MongoDB
  Future<void> testConnection() async {
    _setLoading(true);
    try {
      final healthStatus = await ApiService.getHealthStatus();
      _isConnected = healthStatus['status'] == 'OK';
      _clearError();
      
      if (_isConnected) {
        await loadPatients();
      }
    } catch (e) {
      _isConnected = false;
      _setError('Failed to connect to MongoDB: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all patients from MongoDB
  Future<void> loadPatients() async {
    _setLoading(true);
    try {
      _patients = await ApiService.getPatients();
      _isConnected = true;
      _clearError();
      debugPrint('✅ Successfully loaded ${_patients.length} patients from MongoDB');
    } catch (e) {
      _isConnected = false;
      _setError('Failed to load patients: $e');
      debugPrint('❌ Error loading patients: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new patient to MongoDB
  Future<bool> addPatient(Patient patient) async {
    _setLoading(true);
    try {
      debugPrint('🔄 PatientProvider: Starting to add patient: ${patient.firstName} ${patient.lastName}');
      debugPrint('🔄 PatientProvider: Calling ApiService.createPatient...');
      
      final newPatient = await ApiService.createPatient(patient);
      
      debugPrint('✅ PatientProvider: Successfully received patient from API: ${newPatient.id}');
      _patients.add(newPatient);
      _clearError();
      notifyListeners();
      debugPrint('✅ Successfully added patient: ${newPatient.firstName} ${newPatient.lastName}');
      
      try {
        await loadStatistics(); // Refresh stats
        debugPrint('✅ PatientProvider: Statistics refreshed');
      } catch (statsError) {
        debugPrint('⚠️ PatientProvider: Failed to refresh statistics: $statsError');
        // Don't fail the whole operation for stats
      }
      
      return true;
    } catch (e, stackTrace) {
      final errorMsg = 'Failed to add patient: $e';
      debugPrint('❌ PatientProvider Error: $errorMsg');
      debugPrint('❌ PatientProvider Stack: $stackTrace');
      _setError(errorMsg);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing patient in MongoDB
  Future<bool> updatePatient(String id, Patient patient) async {
    _setLoading(true);
    try {
      final updatedPatient = await ApiService.updatePatient(id, patient);
      final index = _patients.indexWhere((p) => p.id == id);
      if (index != -1) {
        _patients[index] = updatedPatient;
        _clearError();
        notifyListeners();
        debugPrint('✅ Successfully updated patient: ${updatedPatient.firstName} ${updatedPatient.lastName}');
        await loadStatistics(); // Refresh stats
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update patient: $e');
      debugPrint('❌ Error updating patient: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a patient from MongoDB
  Future<bool> deletePatient(String id) async {
    _setLoading(true);
    try {
      final success = await ApiService.deletePatient(id);
      if (success) {
        _patients.removeWhere((patient) => patient.id == id);
        _clearError();
        notifyListeners();
        debugPrint('✅ Successfully deleted patient with ID: $id');
        await loadStatistics(); // Refresh stats
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete patient: $e');
      debugPrint('❌ Error deleting patient: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search patients in MongoDB
  Future<void> searchPatients(String query) async {
    if (query.trim().isEmpty) {
      await loadPatients();
      return;
    }

    _setLoading(true);
    try {
      _patients = await ApiService.searchPatients(query);
      _clearError();
      debugPrint('✅ Search completed: found ${_patients.length} patients');
    } catch (e) {
      _setError('Failed to search patients: $e');
      debugPrint('❌ Error searching patients: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load statistics from MongoDB
  Future<void> loadStatistics() async {
    try {
      _statistics = await ApiService.getStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Could not load statistics: $e');
      // Don't set error for statistics as it's not critical
    }
  }

  // Get patients statistics by email domain
  Map<String, int> getPatientsStatistics() {
    final Map<String, int> stats = {};
    for (final patient in _patients) {
      final domain = patient.email.split('@').last;
      final domainKey = domain.isNotEmpty ? domain : 'Unknown';
      stats[domainKey] = (stats[domainKey] ?? 0) + 1;
    }
    return stats;
  }

  // Get total patients count
  int get totalPatients => _patients.length;

  // Get patients by email domain
  List<Patient> getPatientsByEmailDomain(String domain) {
    return _patients.where((patient) => patient.email.contains('@$domain')).toList();
  }

  // Clear all data
  void clearData() {
    _patients.clear();
    _statistics = null;
    _isConnected = false;
    _clearError();
    notifyListeners();
  }

  // Retry connection
  Future<void> retryConnection() async {
    debugPrint('🔄 Retrying MongoDB connection...');
    await testConnection();
  }

  // Private helper methods
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

  // Get connection status for UI
  String get connectionStatus {
    if (_isLoading) return 'Connecting to MongoDB...';
    if (_isConnected) return 'Connected to MongoDB';
    if (hasError) return 'Connection Failed';
    return 'Not Connected';
  }

  // Get connection icon for UI
  IconData get connectionIcon {
    if (_isLoading) return Icons.hourglass_empty;
    if (_isConnected) return Icons.check_circle;
    if (hasError) return Icons.error;
    return Icons.cloud_off;
  }

  // Get connection color for UI
  Color get connectionColor {
    if (_isLoading) return Colors.orange;
    if (_isConnected) return Colors.green;
    if (hasError) return Colors.red;
    return Colors.grey;
  }
}