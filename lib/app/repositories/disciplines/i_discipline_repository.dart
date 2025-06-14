import 'package:vocatus/app/models/discipline.dart';

abstract class IDisciplineRepository {
  Future<Discipline> createDiscipline(Discipline discipline);
  Future<List<Discipline>> readDisciplines();
  Future<void> updateDiscipline(Discipline discipline);
  Future<void> deleteDiscipline(int id);
}
