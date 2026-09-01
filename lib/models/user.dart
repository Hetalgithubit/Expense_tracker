class User {
  final String id;
  final String name;
  final String mobileNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.createdAt,
    required this.updatedAt,
});

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id' : id,
      'name' : name,
      'mobile_number' : mobileNumber,
      'created_at' : createdAt.toIso8601String(),
      'updated_at' : updatedAt.toIso8601String(),
    };
  }

  factory User.fromDatabaseMap(
      Map<String, dynamic> map,
      ) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      mobileNumber: map['mobile_number'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? mobileNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
})  {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,

    );
  }
}