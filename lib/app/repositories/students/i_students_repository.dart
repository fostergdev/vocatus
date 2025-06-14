import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/student.dart';

abstract class IStudentsRepository {
  Future<List<Student>> getStudentsByClasseId(int classeId);
  Future<void> addStudentsToClasse(List<Student> students, int classeId);
  Future<void> deleteStudentFromClasse(Student student, int classeId);
  Future<void> updateStudent(Student student);
  Future<List<Classe>> getAllClassesExcept(int excludeId);
  Future<void> moveStudentToClasse(
    Student student,
    int fromClasseId,
    int toClasseId,
  );
  Future<List<int>> getAvailableYears({bool? activeStatus});
  Future<List<Classe>> getClassesByStatusAndYear({
    bool? activeStatus,
    int? year,
  });

}
