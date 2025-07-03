

import 'dart:convert';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/schedule.dart'; 

class Classe {
  final int? id;
  final String name;
  final String? description;
  final int schoolYear;
  final DateTime? createdAt;
  final bool? active;
  final List<Schedule> schedules; 

  Classe({
    this.id,
    required this.name,
    this.description,
    required this.schoolYear,
    this.createdAt,
    this.active = true, 
    this.schedules = const [], 
  });

  
  
  Classe copyWith({
    int? id,
    String? name,
    String? description,
    int? schoolYear,
    DateTime? createdAt,
    bool? active,
    List<Schedule>? schedules,
  }) {
    return Classe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      schoolYear: schoolYear ?? this.schoolYear,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
      schedules: schedules ?? this.schedules,
    );
  }

  
  
  
  
  
  factory Classe.fromMap(Map<String, dynamic> map) {
    return Classe(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      schoolYear: map['school_year'] as int,
      createdAt: map['created_at'] != null && (map['created_at'] is String) && (map['created_at'] as String).isNotEmpty
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      active: map['active'] != null ? (map['active'] as int) == 1 : null, 
      schedules: [], 
    );
  }

  
  
  
  
  
  static List<Classe> fromRawReportList(List<Map<String, dynamic>> rawData) {
    final Map<int, Classe> classesMap = {};

    for (var row in rawData) {
      final int? classeId = row['classe_id'] as int?;
      if (classeId == null) continue; 

      
      if (!classesMap.containsKey(classeId)) {
        classesMap[classeId] = Classe(
          id: classeId,
          name: row['classe_name'] as String,
          description: row['description'] as String?,
          schoolYear: row['school_year'] as int,
          createdAt: row['created_at'] != null && (row['created_at'] is String) && (row['created_at'] as String).isNotEmpty
              ? DateTime.tryParse(row['created_at'] as String)
              : null,
          active: row['classe_active'] != null ? (row['classe_active'] as int) == 1 : null,
          schedules: [], 
        );
      }

      
      
      
      if (row['schedule_id'] != null && row['day_of_week'] != null && row['start_time'] != null) {
        final Discipline? discipline = row['discipline_id'] != null
            ? Discipline(
                id: row['discipline_id'] as int,
                name: row['discipline_name'] as String,
                active: true, 
              )
            : null;

        final Schedule schedule = Schedule(
          id: row['schedule_id'] as int, 
          classeId: classeId,
          disciplineId: row['discipline_id'] as int?,
          dayOfWeek: row['day_of_week'] as int,
          startTimeTotalMinutes: Schedule.timeStringToInt(row['start_time'] as String),
          endTimeTotalMinutes: Schedule.timeStringToInt(row['end_time'] as String),
          scheduleYear: row['school_year'] as int, 
          discipline: discipline,
          active: true, 
        );

        
        classesMap[classeId]!.schedules.add(schedule);
      }
    }
    
    return classesMap.values.toList();
  }

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'school_year': schoolYear,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'active': (active ?? true) ? 1 : 0, 
    };
  }

  
  String toJson() => json.encode(toMap());

  
  factory Classe.fromJson(String source) =>
      Classe.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Classe(id: $id, name: $name, schoolYear: $schoolYear, active: $active, schedules: ${schedules.length} schedules)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Classe && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}