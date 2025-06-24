import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/models/grade.dart';

abstract class IClasseRepository {
  Future<Classe> createClasse(Classe classe);
  Future<List<Classe>> readClasses({int? year, bool active = true});
  Future<void> updateClasse(Classe classe);
  Future<void> archiveClasseAndStudents(Classe classe);
  Future<Classe?> getClasseDetailsById(int classeId);
  Future<List<Student>> getStudentsInClasse(
    int classeId, {
    bool activeOnly = true,
  });
  Future<List<Grade>> getClasseGrades(int classeId, {bool activeOnly = true});
}
