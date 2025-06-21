import 'package:flutter/material.dart'; // Para @immutable
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/grade.dart';

@immutable
class Attendance {
  final int? id;
  final int classeId;
  final int gradeId; // A qual Grade (horário agendado) esta chamada se refere
  final DateTime date; // A data real em que a chamada foi feita (YYYY-MM-DD)
  final DateTime? createdAt;
  final bool? active; // Adicionado para soft delete da Attendance

  // Campos extras para conveniência na UI (não persistem no DB)
  final Classe? classe;
  final Grade? grade; // Grade completa associada
  final String? content;

  const Attendance({
    this.id,
    required this.classeId,
    required this.gradeId,
    required this.date,
    this.createdAt,
    this.classe,
    this.grade,
    this.active = true, // Default to active
    this.content,
  });

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'] as int?,
      classeId: map['classe_id'] as int,
      gradeId: map['grade_id'] as int,
      date: DateTime.parse(map['date'] as String),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      active: map['active'] == 1, // Convert int to bool
      content: map['content'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classe_id': classeId,
      'grade_id': gradeId,
      'date': date.toIso8601String().split('T')[0], // Salva apenas a data (YYYY-MM-DD)
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'active': (active ?? true) ? 1 : 0, // Salva o status ativo
      'content': content,
    };
  }

  Attendance copyWith({
    int? id,
    int? classeId,
    int? gradeId,
    DateTime? date,
    DateTime? createdAt,
    Classe? classe,
    Grade? grade,
    bool? active,
    String? content,
  }) {
    return Attendance(
      id: id ?? this.id,
      classeId: classeId ?? this.classeId,
      gradeId: gradeId ?? this.gradeId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      classe: classe ?? this.classe,
      grade: grade ?? this.grade,
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
}