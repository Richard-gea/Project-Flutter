class Consultation {
  final String? id;
  final String patientId;
  final String maladyId;
  final String medicamentId;
  final DateTime date;
 
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Populated fields when fetched with relations
  final Map<String, dynamic>? patient;
  final Map<String, dynamic>? malady;
  final Map<String, dynamic>? medicament;

  Consultation({
    this.id,
    required this.patientId,
    required this.maladyId,
    required this.medicamentId,
    required this.date,
    this.createdAt,
    this.updatedAt,
    this.patient,
    this.malady,
    this.medicament,
  });

  // Convert from JSON (MongoDB response)
  factory Consultation.fromJson(Map<String, dynamic> json) {
    String? extractId() {
      final idField = json['_id'] ?? json['id'];
      if (idField == null) return null;
      
      if (idField is Map<String, dynamic> && idField.containsKey('\$oid')) {
        return idField['\$oid']?.toString();
      }
      
      return idField.toString();
    }

    return Consultation(
      id: extractId(),
      patientId: json['patient_id']?.toString() ?? '',
      maladyId: json['malady_id']?.toString() ?? '',
      medicamentId: json['medicament_id']?.toString() ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date'])
          : DateTime.now(),
     
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
      patient: json['patient_id'] is Map<String, dynamic> 
          ? Map<String, dynamic>.from(json['patient_id'])
          : null,
      malady: json['malady_id'] is Map<String, dynamic> 
          ? Map<String, dynamic>.from(json['malady_id'])
          : null,
      medicament: json['medicament_id'] is Map<String, dynamic> 
          ? Map<String, dynamic>.from(json['medicament_id'])
          : null,
    );
  }

  // Convert to JSON (for MongoDB request)
  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'malady_id': maladyId,
      'medicament_id': medicamentId,
      'date': date.toIso8601String(),
    
    };
  }

  @override
  String toString() {
    return 'Consultation(id: $id, patientId: $patientId, maladyId: $maladyId, medicamentId: $medicamentId, date: $date)';
  }
}