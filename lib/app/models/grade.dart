import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';

@immutable
class Grade {
  final int? id;
  final int classeId;
  final int? disciplineId;
  final int dayOfWeek;
  final int startTimeTotalMinutes;
  final int endTimeTotalMinutes;
  final DateTime? createdAt;
  final bool? active;
  final Classe? classe;
  final Discipline? discipline;

  const Grade({
    this.id,
    required this.classeId,
    this.disciplineId,
    required this.dayOfWeek,
    required this.startTimeTotalMinutes,
    required this.endTimeTotalMinutes,
    this.createdAt,
    this.active = true,
    this.classe,
    this.discipline,
  });

  factory Grade.fromMap(Map<String, dynamic> map) {
    String startTimeStr = map['start_time'] as String;
    String endTimeStr = map['end_time'] as String;

    return Grade(
      id: map['id'] as int?,
      classeId: map['classe_id'] as int,
      disciplineId: map['discipline_id'] as int?,
      dayOfWeek: map['day_of_week'] as int,
      startTimeTotalMinutes: Grade._timeStringToInt(startTimeStr),
      endTimeTotalMinutes: Grade._timeStringToInt(endTimeStr),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      active: map['active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classe_id': classeId,
      'discipline_id': disciplineId,
      'day_of_week': dayOfWeek,
      'start_time': Grade._intToTimeString(startTimeTotalMinutes),
      'end_time': Grade._intToTimeString(endTimeTotalMinutes),
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'active': (active ?? true) ? 1 : 0,
    };
  }

  Grade copyWith({
    int? id,
    int? classeId,
    int? disciplineId,
    int? dayOfWeek,
    int? startTimeTotalMinutes,
    int? endTimeTotalMinutes,
    DateTime? createdAt,
    bool? active,
    Classe? classe,
    Discipline? discipline,
  }) {
    return Grade(
      id: id ?? this.id,
      classeId: classeId ?? this.classeId,
      disciplineId: disciplineId ?? this.disciplineId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTimeTotalMinutes: startTimeTotalMinutes ?? this.startTimeTotalMinutes,
      endTimeTotalMinutes: endTimeTotalMinutes ?? this.endTimeTotalMinutes,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
      classe: classe ?? this.classe,
      discipline: discipline ?? this.discipline,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Grade && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  static int timeOfDayToInt(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  static TimeOfDay intToTimeOfDay(int intTime) {
    return TimeOfDay(hour: intTime ~/ 60, minute: intTime % 60);
  }

  static String formatTimeDisplay(TimeOfDay time) {
    final localizations = MaterialLocalizations.of(Get.context!);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }

  static int _timeStringToInt(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  static String _intToTimeString(int totalMinutes) {
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  TimeOfDay get startTimeOfDay => Grade.intToTimeOfDay(startTimeTotalMinutes);
  TimeOfDay get endTimeOfDay => Grade.intToTimeOfDay(endTimeTotalMinutes);
}