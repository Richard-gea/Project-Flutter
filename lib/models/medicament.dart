class Medicament {
  final String? id;
  final String medicamentName;
  final String description;
  final String? maladyId;
  final String? maladyName; // For populated responses
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Medicament({
    this.id,
    required this.medicamentName,
    required this.description,
    this.maladyId,
    this.maladyName,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON (MongoDB response)
  factory Medicament.fromJson(Map<String, dynamic> json) {
    String? extractId() {
      final idField = json['_id'] ?? json['id'];
      if (idField == null) return null;
      
      // Handle MongoDB ObjectId format: {"$oid": "..."}
      if (idField is Map<String, dynamic> && idField.containsKey('\$oid')) {
        return idField['\$oid']?.toString();
      }
      
      // Handle simple string ID
      return idField.toString();
    }

    String? extractMaladyId() {
      final maladyField = json['malady_id'];
      if (maladyField == null) return null;
      
      // Handle populated malady object
      if (maladyField is Map<String, dynamic>) {
        final idField = maladyField['_id'] ?? maladyField['id'];
        if (idField is Map<String, dynamic> && idField.containsKey('\$oid')) {
          return idField['\$oid']?.toString();
        }
        return idField?.toString();
      }
      
      // Handle ObjectId format
      if (maladyField is Map<String, dynamic> && maladyField.containsKey('\$oid')) {
        return maladyField['\$oid']?.toString();
      }
      
      return maladyField.toString();
    }

    String? extractMaladyName() {
      final maladyField = json['malady_id'];
      if (maladyField is Map<String, dynamic>) {
        return maladyField['maladyName']?.toString();
      }
      return null;
    }

    return Medicament(
      id: extractId(),
      medicamentName: json['medicamentName'] ?? '',
      description: json['description'] ?? '',
      maladyId: extractMaladyId(),
      maladyName: extractMaladyName(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Convert to JSON (for MongoDB request)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'medicamentName': medicamentName,
      'description': description,
    };
    
    if (maladyId != null) data['malady_id'] = maladyId;
    if (id != null) data['_id'] = id;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    
    return data;
  }

  // Copy with method for immutable updates
  Medicament copyWith({
    String? id,
    String? medicamentName,
    String? description,
    String? maladyId,
    String? maladyName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicament(
      id: id ?? this.id,
      medicamentName: medicamentName ?? this.medicamentName,
      description: description ?? this.description,
      maladyId: maladyId ?? this.maladyId,
      maladyName: maladyName ?? this.maladyName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Medicament(id: $id, medicamentName: $medicamentName, maladyName: $maladyName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicament && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}