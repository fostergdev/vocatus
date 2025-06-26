// lib/app/models/student.dart

import 'dart:convert';

class Student {
  final int? id;
  final String name;
  final DateTime? createdAt;
  final bool? active;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? classeStudentActive;

  Student({
    this.id,
    required this.name,
    this.createdAt,
    this.active,
    this.startDate,
    this.endDate,
    this.classeStudentActive,
  });

  Student copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    bool? active,
    DateTime? startDate,
    DateTime? endDate,
    bool? classeStudentActive,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      classeStudentActive: classeStudentActive ?? this.classeStudentActive,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'active': active == null ? null : (active! ? 1 : 0),
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'classe_student_active': classeStudentActive == null ? null : (classeStudentActive! ? 1 : 0),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: map['created_at'] != null && (map['created_at'] as String).isNotEmpty
          ? DateTime.parse(map['created_at'] as String)
          : null,
      active: map['active'] != null ? (map['active'] as int) == 1 : null,
      startDate: map['start_date'] != null && (map['start_date'] is String) && (map['start_date'] as String).isNotEmpty
          ? DateTime.tryParse(map['start_date'] as String)
          : null,
      endDate: map['end_date'] != null && (map['end_date'] is String) && (map['end_date'] as String).isNotEmpty
          ? DateTime.tryParse(map['end_date'] as String)
          : null,
      classeStudentActive: map['classe_student_active'] != null ? (map['classe_student_active'] as int) == 1 : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Student.fromJson(String source) =>
      Student.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Student(id: $id, name: $name, createdAt: $createdAt, active: $active, startDate: $startDate, endDate: $endDate, classeStudentActive: $classeStudentActive)';

  @override
  bool operator ==(covariant Student other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.active == active &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.classeStudentActive == classeStudentActive;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      createdAt.hashCode ^
      active.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      classeStudentActive.hashCode;
}