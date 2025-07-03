import 'package:flutter/material.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/schedule.dart';


@immutable
class Attendance {
  final int? id;
  final int classeId;
  final int scheduleId;
  final DateTime date;
  final DateTime? createdAt;
  final bool? active;
  final Classe? classe;
  final Schedule? schedule;
  final String? content;

  const Attendance({
    this.id,
    required this.classeId,
    required this.scheduleId,
    required this.date,
    this.createdAt,
    this.classe,
    this.schedule,
    this.active = true,
    this.content,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as int?,
      classeId: map['classe_id'] as int,
      scheduleId: map['schedule_id'] as int,
      date: DateTime.parse(map['date'] as String),
      createdAt: map['created_at'] != null && (map['created_at'] is String) && (map['created_at'] as String).isNotEmpty
          ? DateTime.parse(map['created_at'] as String)
          : null,
      active: map['active'] == 1,
      content: map['content'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classe_id': classeId,
      'schedule_id': scheduleId,
      'date': date.toIso8601String().split('T')[0],
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'active': (active ?? true) ? 1 : 0,
      'content': content,
    };
  }

  Attendance copyWith({
    int? id,
    int? classeId,
    int? scheduleId,
    DateTime? date,
    DateTime? createdAt,
    Classe? classe,
    Schedule? schedule,
    bool? active,
    String? content,
  }) {
    return Attendance(
      id: id ?? this.id,
      classeId: classeId ?? this.classeId,
      scheduleId: scheduleId ?? this.scheduleId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      classe: classe ?? this.classe,
      schedule: schedule ?? this.schedule,
      active: active ?? this.active,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Attendance(id: $id, classeId: $classeId, scheduleId: $scheduleId, date: $date, createdAt: $createdAt, active: $active, content: $content)';
  }
}