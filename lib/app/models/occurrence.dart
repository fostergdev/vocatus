import 'package:flutter/material.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/models/student.dart';

enum OccurrenceType {
  comportamento,
  saude,
  atraso,
  material,
  geral,
  outros,
}

@immutable
class Occurrence {
  final int? id;
  final int attendanceId;
  final int? studentId; // null para ocorrência geral da sala
  final OccurrenceType? occurrenceType;
  final String? title;
  final String description;
  final DateTime occurrenceDate;
  final DateTime? createdAt;
  final bool? active;
  final Attendance? attendance;
  final Student? student;

  const Occurrence({
    this.id,
    required this.attendanceId,
    this.studentId,
    this.occurrenceType,
    this.title,
    required this.description,
    required this.occurrenceDate,
    this.createdAt,
    this.active = true,
    this.attendance,
    this.student,
  });

  factory Occurrence.fromMap(Map<String, dynamic> map) {
    return Occurrence(
      id: map['id'] as int?,
      attendanceId: map['attendance_id'] as int,
      studentId: map['student_id'] as int?,
      occurrenceType: map['occurrence_type'] != null
          ? _getOccurrenceTypeFromString(map['occurrence_type'] as String)
          : null,
      title: map['title'] as String?,
      description: map['description'] as String,
      occurrenceDate: DateTime.parse(map['occurrence_date'] as String),
      createdAt: map['created_at'] != null && (map['created_at'] is String) && (map['created_at'] as String).isNotEmpty
          ? DateTime.parse(map['created_at'] as String)
          : null,
      active: map['active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attendance_id': attendanceId,
      'student_id': studentId,
      'occurrence_type': occurrenceType?.name,
      'title': title,
      'description': description,
      'occurrence_date': occurrenceDate.toIso8601String().split('T')[0],
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'active': (active ?? true) ? 1 : 0,
    };
  }

  Occurrence copyWith({
    int? id,
    int? attendanceId,
    int? studentId,
    OccurrenceType? occurrenceType,
    String? title,
    String? description,
    DateTime? occurrenceDate,
    DateTime? createdAt,
    bool? active,
    Attendance? attendance,
    Student? student,
  }) {
    return Occurrence(
      id: id ?? this.id,
      attendanceId: attendanceId ?? this.attendanceId,
      studentId: studentId ?? this.studentId,
      occurrenceType: occurrenceType ?? this.occurrenceType,
      title: title ?? this.title,
      description: description ?? this.description,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
      attendance: attendance ?? this.attendance,
      student: student ?? this.student,
    );
  }

  static OccurrenceType _getOccurrenceTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'comportamento':
        return OccurrenceType.comportamento;
      case 'saude':
      case 'saúde':
        return OccurrenceType.saude;
      case 'atraso':
        return OccurrenceType.atraso;
      case 'material':
        return OccurrenceType.material;
      case 'geral':
        return OccurrenceType.geral;
      default:
        return OccurrenceType.outros;
    }
  }

  String getTypeDisplayName() {
    switch (occurrenceType) {
      case OccurrenceType.comportamento:
        return 'Comportamento';
      case OccurrenceType.saude:
        return 'Saúde';
      case OccurrenceType.atraso:
        return 'Atraso';
      case OccurrenceType.material:
        return 'Material';
      case OccurrenceType.geral:
        return 'Geral';
      case OccurrenceType.outros:
        return 'Outros';
      default:
        return 'Não especificado';
    }
  }

  IconData getTypeIcon() {
    switch (occurrenceType) {
      case OccurrenceType.comportamento:
        return Icons.psychology;
      case OccurrenceType.saude:
        return Icons.local_hospital;
      case OccurrenceType.atraso:
        return Icons.access_time;
      case OccurrenceType.material:
        return Icons.inventory;
      case OccurrenceType.geral:
        return Icons.info;
      case OccurrenceType.outros:
        return Icons.more_horiz;
      default:
        return Icons.report;
    }
  }

  Color getTypeColor() {
    switch (occurrenceType) {
      case OccurrenceType.comportamento:
        return Colors.orange;
      case OccurrenceType.saude:
        return Colors.red;
      case OccurrenceType.atraso:
        return Colors.purple;
      case OccurrenceType.material:
        return Colors.brown;
      case OccurrenceType.geral:
        return Colors.blue;
      case OccurrenceType.outros:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  bool get isGeneralOccurrence => studentId == null;
  bool get isStudentOccurrence => studentId != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Occurrence && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Occurrence(id: $id, attendanceId: $attendanceId, studentId: $studentId, occurrenceType: $occurrenceType, description: $description, occurrenceDate: $occurrenceDate, active: $active)';
  }
}
