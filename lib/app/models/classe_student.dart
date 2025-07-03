import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/student.dart';

class ClasseStudent {
  final int studentId;
  final int classeId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool? active;
  final DateTime? createdAt;
  final Student? student;
  final Classe? classe;

  ClasseStudent({
    required this.studentId,
    required this.classeId,
    required this.startDate,
    this.endDate,
    this.active,
    this.createdAt,
    this.student,
    this.classe,
  });

  factory ClasseStudent.fromMap(Map<String, dynamic> map) {
    return ClasseStudent(
      studentId: map['student_id'] as int,
      classeId: map['classe_id'] as int,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      active: map['active'] == 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'classe_id': classeId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'active': (active ?? true) ? 1 : 0,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
