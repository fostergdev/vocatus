import 'package:flutter/material.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/models/attendance.dart';

enum PresenceStatus {
  present,
  absent,
  justified,
  unknown, // Mantenha este se ele for um valor possível vindo do banco. Se não, remova.
}

@immutable
class StudentAttendance {
  final int attendanceId;
  final int studentId;
  final PresenceStatus presence;
  final DateTime? createdAt;
  final bool? active;
  final Student? student;
  final Attendance? attendance;

  const StudentAttendance({
    required this.attendanceId,
    required this.studentId,
    required this.presence,
    this.createdAt,
    this.student,
    this.attendance,
    this.active = true,
  });

  factory StudentAttendance.fromMap(Map<String, dynamic> map) {
    return StudentAttendance(
      attendanceId: map['attendance_id'] as int,
      studentId: map['student_id'] as int,
      presence: PresenceStatus.values[map['presence'] as int],
      createdAt: map['created_at'] != null && (map['created_at'] is String) && (map['created_at'] as String).isNotEmpty
          ? DateTime.parse(map['created_at'] as String)
          : null,
      active: map['active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attendance_id': attendanceId,
      'student_id': studentId,
      'presence': presence.index,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'active': (active ?? true) ? 1 : 0,
    };
  }

  StudentAttendance copyWith({
    int? attendanceId,
    int? studentId,
    PresenceStatus? presence,
    DateTime? createdAt,
    Student? student,
    Attendance? attendance,
    bool? active,
  }) {
    return StudentAttendance(
      attendanceId: attendanceId ?? this.attendanceId,
      studentId: studentId ?? this.studentId,
      presence: presence ?? this.presence,
      createdAt: createdAt ?? this.createdAt,
      student: student ?? this.student,
      attendance: attendance ?? this.attendance,
      active: active ?? this.active,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentAttendance &&
        other.attendanceId == attendanceId &&
        other.studentId == studentId;
  }

  @override
  int get hashCode => attendanceId.hashCode ^ studentId.hashCode;

  @override
  String toString() {
    return 'StudentAttendance(attendanceId: $attendanceId, studentId: $studentId, presence: $presence, createdAt: $createdAt, active: $active)';
  }
}