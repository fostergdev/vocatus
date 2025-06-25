// lib/app/models/grade.dart

import 'package:flutter/material.dart'; // Para TimeOfDay e MaterialLocalizations
import 'package:get/get.dart'; // Para Get.context!
import 'package:vocatus/app/models/classe.dart'; // Importa Classe se Grade tiver uma referência a ela
import 'package:vocatus/app/models/discipline.dart'; // Importa Discipline se Grade tiver uma referência a ela


@immutable
class Grade {
  final int? id;
  final int classeId;
  final int? disciplineId;
  final int dayOfWeek;
  final int startTimeTotalMinutes;
  final int endTimeTotalMinutes;
  final int? gradeYear;
  final DateTime? createdAt;
  final bool? active;
  final Classe? classe; // Referência opcional à Classe
  final Discipline? discipline; // Referência opcional à Discipline

  const Grade({
    this.id,
    required this.classeId,
    this.disciplineId,
    required this.dayOfWeek,
    required this.startTimeTotalMinutes,
    required this.endTimeTotalMinutes,
    this.gradeYear,
    this.createdAt,
    this.active = true,
    this.classe, // Deve ser fornecido externamente, não mapeado do 'map' da Grade
    this.discipline, // Deve ser fornecido externamente, não mapeado do 'map' da Grade
  });

  factory Grade.fromMap(Map<String, dynamic> map) {
    String startTimeStr = map['start_time'] as String;
    String endTimeStr = map['end_time'] as String;

    int currentYear = DateTime.now().year;
    int? parsedGradeYear;
    if (map['grade_year'] == null) {
      parsedGradeYear = currentYear;
    } else if (map['grade_year'] is int) {
      parsedGradeYear = map['grade_year'] as int;
    } else {
      parsedGradeYear = int.tryParse(map['grade_year'].toString()) ?? currentYear;
    }

    return Grade(
      id: map['id'] as int?,
      classeId: map['classe_id'] as int,
      disciplineId: map['discipline_id'] as int?,
      dayOfWeek: map['day_of_week'] as int,
      startTimeTotalMinutes: Grade.timeStringToInt(startTimeStr), // <--- Método público
      endTimeTotalMinutes: Grade.timeStringToInt(endTimeStr),     // <--- Método público
      gradeYear: parsedGradeYear,
      createdAt: map['created_at'] != null && (map['created_at'] is String) && (map['created_at'] as String).isNotEmpty
          ? DateTime.parse(map['created_at'] as String)
          : null,
      active: map['active'] == 1,
      // Não preenche 'classe' ou 'discipline' aqui via fromMap da Grade,
      // pois eles geralmente são carregados via JOINs em queries separadas
      // e anexados ao objeto Grade posteriormente, ou em uma fromMap especializada.
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classe_id': classeId,
      'discipline_id': disciplineId,
      'day_of_week': dayOfWeek,
      'start_time': Grade.intToTimeString(startTimeTotalMinutes), // <--- Método público
      'end_time': Grade.intToTimeString(endTimeTotalMinutes),     // <--- Método público
      'grade_year': gradeYear,
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
    int? gradeYear,
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
      gradeYear: gradeYear ?? this.gradeYear,
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
    if (Get.context != null) {
      final localizations = MaterialLocalizations.of(Get.context!);
      return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: true);
    }
    final hours = (time.hour).toString().padLeft(2, '0');
    final minutes = (time.minute).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  // Métodos de conversão de tempo tornados públicos
  static int timeStringToInt(String timeString) { // Antigo _timeStringToInt
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return hour * 60 + minute;
  }

  static String intToTimeString(int totalMinutes) { // Antigo _intToTimeString
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  TimeOfDay get startTimeOfDay => Grade.intToTimeOfDay(startTimeTotalMinutes);
  TimeOfDay get endTimeOfDay => Grade.intToTimeOfDay(endTimeTotalMinutes);

  @override
  String toString() {
    return 'Grade(id: $id, classeId: $classeId, disciplineId: $disciplineId, dayOfWeek: $dayOfWeek, startTimeTotalMinutes: $startTimeTotalMinutes, endTimeTotalMinutes: $endTimeTotalMinutes, gradeYear: $gradeYear, createdAt: $createdAt, active: $active)';
  }
}