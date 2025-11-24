class Malady {
  final String? id;
  final String maladyName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Malady({
    this.id,
    required this.maladyName,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON (MongoDB response)
  factory Malady.fromJson(Map<String, dynamic> json) {
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

    return Malady(
      id: extractId(),
      maladyName: json['maladyName'] ?? '',
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
      'maladyName': maladyName,
      
    };
    
    if (id != null) data['_id'] = id;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    
    return data;
  }

  // Copy with method for immutable updates
  Malady copyWith({
    String? id,
    String? maladyName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Malady(
      id: id ?? this.id,
      maladyName: maladyName ?? this.maladyName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Malady(id: $id, maladyName: $maladyName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Malady && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}