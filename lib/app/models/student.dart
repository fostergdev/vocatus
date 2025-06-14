import 'dart:convert';

class Student {
  final int? id;
  final String name;
  final DateTime? createdAt;
  final bool? active;

  Student({
    this.id,
    required this.name,
    this.createdAt,
    this.active,
  });

  Student copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    bool? active,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'active': active == null ? null : (active! ? 1 : 0),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.tryParse(map['created_at'].toString()) ?? 0)
          : null,
      active: map['active'] != null ? (map['active'] as int) == 1 : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Student.fromJson(String source) =>
      Student.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Student(id: $id, name: $name, createdAt: $createdAt, active: $active)';

  @override
  bool operator ==(covariant Student other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.active == active;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      createdAt.hashCode ^
      active.hashCode;
}