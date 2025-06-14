import 'dart:convert';

class Classe {
  final int? id;
  final String name;
  final String? description;
  final int schoolYear;
  final DateTime? createdAt;
  final bool? active;

  Classe({
    this.id,
    required this.name,
    this.description,
    required this.schoolYear,
    this.createdAt,
    this.active = true,
  });

  Classe copyWith({
    int? id,
    String? name,
    String? description,
    int? schoolYear,
    DateTime? createdAt,
    bool? active,
  }) {
    return Classe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      schoolYear: schoolYear ?? this.schoolYear,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
    );
  }

  factory Classe.fromMap(Map<String, dynamic> map) {
    return Classe(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      schoolYear: map['school_year'] as int,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      active: map['active'] != null ? (map['active'] as int) == 1 : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'school_year': schoolYear,
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'active': (active ?? true) ? 1 : 0,
    };
  }

  String toJson() => json.encode(toMap());

  factory Classe.fromJson(String source) =>
      Classe.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Classe(id: $id, name: $name, description: $description, schoolYear: $schoolYear, createdAt: $createdAt, active: $active)';
  }

  @override
  bool operator ==(covariant Classe other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.description == description &&
        other.schoolYear == schoolYear &&
        other.createdAt == createdAt &&
        other.active == active;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        schoolYear.hashCode ^
        createdAt.hashCode ^
        active.hashCode;
  }
}
