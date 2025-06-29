import 'package:flutter/material.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';

enum HomeworkStatus {
  pending,
  completed,
  cancelled,
}

@immutable
class Homework {
  final int? id;
  final int classeId;
  final int? disciplineId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final DateTime assignedDate;
  final HomeworkStatus status;
  final DateTime? createdAt;
  final bool? active;
  final Classe? classe;
  final Discipline? discipline;

  const Homework({
    this.id,
    required this.classeId,
    this.disciplineId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.assignedDate,
    this.status = HomeworkStatus.pending,
    this.createdAt,
    this.active = true,
    this.classe,
    this.discipline,
  });

  factory Homework.fromMap(Map<String, dynamic> map) {
    return Homework(
      id: map['id'] as int?,
      classeId: map['classe_id'] as int,
      disciplineId: map['discipline_id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: DateTime.parse(map['due_date'] as String),
      assignedDate: DateTime.parse(map['assigned_date'] as String),
      status: HomeworkStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String),
        orElse: () => HomeworkStatus.pending,
      ),
      createdAt: map['created_at'] != null && (map['created_at'] as String).isNotEmpty
          ? DateTime.parse(map['created_at'] as String)
          : null,
      active: map['active'] != null ? (map['active'] as int) == 1 : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classe_id': classeId,
      'discipline_id': disciplineId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'assigned_date': assignedDate.toIso8601String(),
      'status': status.name,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'active': (active ?? true) ? 1 : 0,
    };
  }

  Homework copyWith({
    int? id,
    int? classeId,
    int? disciplineId,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? assignedDate,
    HomeworkStatus? status,
    DateTime? createdAt,
    bool? active,
    Classe? classe,
    Discipline? discipline,
  }) {
    return Homework(
      id: id ?? this.id,
      classeId: classeId ?? this.classeId,
      disciplineId: disciplineId ?? this.disciplineId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      assignedDate: assignedDate ?? this.assignedDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
      classe: classe ?? this.classe,
      discipline: discipline ?? this.discipline,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Homework && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Homework(id: $id, classeId: $classeId, disciplineId: $disciplineId, title: $title, description: $description, dueDate: $dueDate, assignedDate: $assignedDate, status: $status, createdAt: $createdAt, active: $active)';
  }
}
