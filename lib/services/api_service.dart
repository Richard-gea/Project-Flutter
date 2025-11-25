import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient.dart';
import '../models/malady.dart';
import '../models/medicament.dart';
import '../models/consultation.dart';

class ApiService {
  // Change this to your actual MongoDB/Node.js backend URL
  // For local MongoDB at mongodb://127.0.0.1:27017
  static const String baseUrl = 'http://127.0.0.1:3000/api';
  
  // Test mode - set to true to simulate successful operations without backend
  static const bool testMode = false;
  
  // Mock patient ID counter for test mode
  static int _mockIdCounter = 1;

  // Get all patients
  static Future<List<Patient>> getPatients() async {
    if (testMode) {
      print('🧪 Test Mode: Simulating patient retrieval');
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Return mock patients
      
      
     
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patients'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        // The new backend returns patients in a 'patients' field with pagination info
        final List<dynamic> patientsData = jsonData['patients'] ?? jsonData;
        return patientsData.map((json) => Patient.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load patients: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching patients: $e');
    }
  }

  // Create a new patient
  static Future<Patient> createPatient(Patient patient) async {
    if (testMode) {
      print('🧪 Test Mode: Simulating patient creation');
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return a mock patient with generated ID
      final mockPatient = Patient(
        id: 'mock_${_mockIdCounter++}',
        firstName: patient.firstName,
        lastName: patient.lastName,
        email: patient.email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      print('✅ Test Mode: Mock patient created with ID: ${mockPatient.id}');
      return mockPatient;
    }
    try {
      print('🔄 ApiService: Creating patient for ${patient.firstName} ${patient.lastName}');
      
      final Map<String, dynamic> patientData = patient.toJson();
      // Remove null id and timestamps for creation
      patientData.removeWhere((key, value) => value == null || key == '_id');
      
      print('🔄 ApiService: Sending POST request to $baseUrl/patients');
      print('🔄 ApiService: Patient data: $patientData');

      final response = await http.post(
        Uri.parse('$baseUrl/patients'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(patientData),
      );

      print('🔄 ApiService: Response status: ${response.statusCode}');
      print('🔄 ApiService: Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        // The new backend returns the patient in a 'patient' field
        final patientJson = jsonData['patient'] ?? jsonData;
        final newPatient = Patient.fromJson(patientJson);
        print('✅ ApiService: Successfully created patient with ID: ${newPatient.id}');
        return newPatient;
      } else {
        final errorData = json.decode(response.body);
        final errorMsg = errorData['error'] ?? 'Failed to create patient';
        print('❌ ApiService: Server error (${ response.statusCode}): $errorMsg');
        throw Exception('Server error (${response.statusCode}): $errorMsg');
      }
    } catch (e, stackTrace) {
      print('❌ ApiService: Exception in createPatient: $e');
      print('❌ ApiService: Stack trace: $stackTrace');
      
      if (e.toString().contains('Connection refused') || e.toString().contains('network')) {
        throw Exception('Cannot connect to server. Please check if the backend is running on $baseUrl');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Network error. Please check your internet connection and server URL.');
      } else {
        throw Exception('Error creating patient: $e');
      }
    }
  }

  // Update a patient
  // static Future<Patient> updatePatient(String id, Patient patient) async {
  //   try {
  //     final Map<String, dynamic> patientData = patient.toJson();
  //     // Remove id and timestamps for update
  //     patientData.removeWhere((key, value) => 
  //       key == '_id' || key == 'createdAt' || key == 'updatedAt');

  //     final response = await http.put(
  //       Uri.parse('$baseUrl/patients/$id'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode(patientData),
  //     );

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonData = json.decode(response.body);
  //       // The new backend returns the patient in a 'patient' field
  //       final patientJson = jsonData['patient'] ?? jsonData;
  //       return Patient.fromJson(patientJson);
  //     } else {
  //       final errorData = json.decode(response.body);
  //       throw Exception(errorData['error'] ?? 'Failed to update patient');
  //     }
  //   } catch (e) {
  //     throw Exception('Error updating patient: $e');
  //   }
  // }

  // Delete a patient
  // static Future<bool> deletePatient(String id) async {
  //   try {
  //     final response = await http.delete(
  //       Uri.parse('$baseUrl/patients/$id'),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       final errorData = json.decode(response.body);
  //       throw Exception(errorData['error'] ?? 'Failed to delete patient');
  //     }
  //   } catch (e) {
  //     throw Exception('Error deleting patient: $e');
  //   }
  // }

  // Search patients by name or phone
  static Future<List<Patient>> searchPatients(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patients/search?q=${Uri.encodeComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Patient.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to search patients');
      }
    } catch (e) {
      throw Exception('Error searching patients: $e');
    }
  }

  // Get API health status
  static Future<Map<String, dynamic>> getHealthStatus() async {
    if (testMode) {
      print('🧪 Test Mode: Simulating health check');
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'status': 'OK',
        'message': 'Test mode - simulated connection',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
    try {
      final response = await http.get(
        Uri.parse('${baseUrl.replaceAll('/api', '')}/health'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get health status');
      }
    } catch (e) {
      throw Exception('Error checking health: $e');
    }
  }

  // Get database statistics
  // static Future<Map<String, dynamic>> getStatistics() async {
  //   if (testMode) {
  //     print('🧪 Test Mode: Simulating statistics');
  //     await Future.delayed(const Duration(milliseconds: 300));
  //     return {
  //       'totalPatients': _mockIdCounter - 1,
  //       'recentPatients': 2,
  //       'sickTypeDistribution': [
  //         {'_id': 'Flu', 'count': 3},
  //         {'_id': 'Headache', 'count': 2},
  //         {'_id': 'Fever', 'count': 1},
  //       ],
  //       'generatedAt': DateTime.now().toIso8601String(),
  //     };
  //   }
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/stats'),
  //       headers: {'Content-Type': 'application/json'},
  //     );

  //     if (response.statusCode == 200) {
  //       return json.decode(response.body);
  //     } else {
  //       final errorData = json.decode(response.body);
  //       throw Exception(errorData['error'] ?? 'Failed to get statistics');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching statistics: $e');
  //   }
  // }


  static Future<List<Malady>> getMaladies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/maladies'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> maladiesData = jsonData['maladies'] ?? jsonData;
        return maladiesData.map((json) => Malady.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load maladies: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching maladies: $e');
    }
  }



  // Get all medicaments
  static Future<List<Medicament>> getMedicaments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medicaments'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> medicamentsData = jsonData['medicaments'] ?? jsonData;
        return medicamentsData.map((json) => Medicament.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load medicaments: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching medicaments: $e');
    }
  }

  // Get medicaments by malady ID
  static Future<List<Medicament>> getMedicamentsByMalady(String maladyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medicaments/malady/$maladyId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> medicamentsData = jsonData['medicaments'] ?? jsonData;
        return medicamentsData.map((json) => Medicament.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load medicaments: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching medicaments for malady: $e');
    }
  }


  static Future<Malady> createMalady(Map<String, dynamic> maladyData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/maladies'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(maladyData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Malady.fromJson(data['malady'] ?? data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to create malady: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating malady: $e');
    }
  }

  // Delete malady
  static Future<bool> deleteMalady(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/maladies/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to delete malady: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting malady: $e');
    }
  }

  
  
  // Create medicament
  static Future<Medicament> createMedicament(Map<String, dynamic> medicamentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/medicaments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(medicamentData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Medicament.fromJson(data['medicament'] ?? data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to create medicament: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating medicament: $e');
    }
  }

  // Delete medicament
  static Future<bool> deleteMedicament(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/medicaments/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to delete medicament: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting medicament: $e');
    }
  }

  // Get all consultations
  static Future<List<Consultation>> getConsultations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/consultations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> consultationsData = jsonData['consultations'] ?? jsonData;
        return consultationsData.map((json) => Consultation.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load consultations: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching consultations: $e');
    }
  }

  // Get consultation by ID
  static Future<Consultation> getConsultation(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/consultations/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final consultationData = jsonData['consultation'] ?? jsonData;
        return Consultation.fromJson(consultationData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to load consultation: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching consultation: $e');
    }
  }

  // Create consultation
  static Future<Consultation> createConsultation(Map<String, dynamic> consultationData) async {
    try {
      // Always remove notes field
      consultationData.remove('notes');
      final response = await http.post(
        Uri.parse('$baseUrl/consultations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(consultationData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Consultation.fromJson(data['consultation'] ?? data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to create consultation: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating consultation: $e');
    }
  }

  // Delete consultation
  static Future<bool> deleteConsultation(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/consultations/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to delete consultation: ${errorData['error'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting consultation: $e');
    }
  }

}