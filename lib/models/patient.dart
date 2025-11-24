class Patient {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Patient({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON (MongoDB response)
  factory Patient.fromJson(Map<String, dynamic> json) {
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

    return Patient(
      id: extractId(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Convert to JSON (for MongoDB request)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
    
    if (id != null) data['_id'] = id;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    
    return data;
  }

  // Convert to JSON for update (exclude timestamps)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // Copy with method for immutable updates
  Patient copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Patient(id: $id, firstName: $firstName, lastName: $lastName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
