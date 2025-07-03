

import 'package:flutter/material.dart'; 
import 'package:get/get.dart'; 
import 'package:vocatus/app/models/classe.dart'; 
import 'package:vocatus/app/models/discipline.dart'; 


@immutable
class Schedule {
  final int? id;
  final int classeId;
  final int? disciplineId;
  final int dayOfWeek;
  final int startTimeTotalMinutes;
  final int endTimeTotalMinutes;
  final int? scheduleYear;
  final DateTime? createdAt;
  final bool? active;
  final Classe? classe; 
  final Discipline? discipline; 

  const Schedule({
    this.id,
    required this.classeId,
    this.disciplineId,
    required this.dayOfWeek,
    required this.startTimeTotalMinutes,
    required this.endTimeTotalMinutes,
    this.scheduleYear,
    this.createdAt,
    this.active = true,
    this.classe, 
    this.discipline, 
  });

  factory Schedule.fromMap(Map<String, dynamic> map) {
    String startTimeStr = map['start_time'] as String;
    String endTimeStr = map['end_time'] as String;

    int currentYear = DateTime.now().year;
    int? parsedScheduleYear;
    if (map['schedule_year'] == null) {
      parsedScheduleYear = currentYear;
    } else if (map['schedule_year'] is int) {
      parsedScheduleYear = map['schedule_year'] as int;
    } else {
      parsedScheduleYear = int.tryParse(map['schedule_year'].toString()) ?? currentYear;
    }

    return Schedule(
      id: map['id'] as int?,
      classeId: map['classe_id'] as int,
      disciplineId: map['discipline_id'] as int?,
      dayOfWeek: map['day_of_week'] as int,
      startTimeTotalMinutes: Schedule.timeStringToInt(startTimeStr), 
      endTimeTotalMinutes: Schedule.timeStringToInt(endTimeStr),     
      scheduleYear: parsedScheduleYear,
      createdAt: map['created_at'] != null && (map['created_at'] is String) && (map['created_at'] as String).isNotEmpty
          ? DateTime.parse(map['created_at'] as String)
          : null,
      active: map['active'] == 1,
      
      
      
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classe_id': classeId,
      'discipline_id': disciplineId,
      'day_of_week': dayOfWeek,
      'start_time': Schedule.intToTimeString(startTimeTotalMinutes), 
      'end_time': Schedule.intToTimeString(endTimeTotalMinutes),     
      'schedule_year': scheduleYear,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'active': (active ?? true) ? 1 : 0,
    };
  }

  Schedule copyWith({
    int? id,
    int? classeId,
    int? disciplineId,
    int? dayOfWeek,
    int? startTimeTotalMinutes,
    int? endTimeTotalMinutes,
    int? scheduleYear,
    DateTime? createdAt,
    bool? active,
    Classe? classe,
    Discipline? discipline,
  }) {
    return Schedule(
      id: id ?? this.id,
      classeId: classeId ?? this.classeId,
      disciplineId: disciplineId ?? this.disciplineId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTimeTotalMinutes: startTimeTotalMinutes ?? this.startTimeTotalMinutes,
      endTimeTotalMinutes: endTimeTotalMinutes ?? this.endTimeTotalMinutes,
      scheduleYear: scheduleYear ?? this.scheduleYear,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
      classe: classe ?? this.classe,
      discipline: discipline ?? this.discipline,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Schedule && other.id == id;
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
    if (Get.context != null) {
      final localizations = MaterialLocalizations.of(Get.context!);
      return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: true);
    }
    final hours = (time.hour).toString().padLeft(2, '0');
    final minutes = (time.minute).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  
  static int timeStringToInt(String timeString) { 
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  static String intToTimeString(int totalMinutes) { 
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  TimeOfDay get startTimeOfDay => Schedule.intToTimeOfDay(startTimeTotalMinutes);
  TimeOfDay get endTimeOfDay => Schedule.intToTimeOfDay(endTimeTotalMinutes);

  @override
  String toString() {
    return 'Schedule(id: $id, classeId: $classeId, disciplineId: $disciplineId, dayOfWeek: $dayOfWeek, startTimeTotalMinutes: $startTimeTotalMinutes, endTimeTotalMinutes: $endTimeTotalMinutes, scheduleYear: $scheduleYear, createdAt: $createdAt, active: $active)';
  }
}