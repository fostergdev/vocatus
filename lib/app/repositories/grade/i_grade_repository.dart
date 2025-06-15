// lib/app/repositories/grades/i_grades_repository.dart
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/discipline.dart'; // Para buscar disciplinas no GradeRepository

abstract class IGradeRepository {
  Future<Grade> createGrade(Grade grade);
  Future<List<Grade>> getGradesByClasseId(int classeId);
  Future<void> updateGrade(Grade grade);
  Future<void> deleteGrade(int gradeId); // Soft delete
  
  // Métodos para buscar disciplinas e usá-las nos dropdowns
  Future<List<Discipline>> getAllDisciplines();
}