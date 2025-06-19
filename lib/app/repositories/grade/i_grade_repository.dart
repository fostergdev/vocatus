// lib/app/repositories/grades/i_grades_repository.dart
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/discipline.dart'; // Para buscar disciplinas no GradeRepository

abstract class IGradeRepository {
  Future<Grade> createGrade(Grade grade);
  Future<List<Grade>> getGradesByClasseId(int classeId);
  Future<void> updateGrade(Grade grade);
  Future<void> deleteGrade(int gradeId); // Soft delete
  Future<List<Classe>> getAllActiveClasses(int year);
  Future<void> toggleGradeActiveStatus(Grade grade);
  Future<List<Discipline>> getAllDisciplines();
  Future<List<Grade>> getAllGrades({
    int? classeId,
    int? disciplineId,
    int? dayOfWeek,
    bool? activeStatus = true,
    int? year,
  });
}
