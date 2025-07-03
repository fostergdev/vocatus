import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/schedule.dart';

abstract class IAttendanceSelectRepository {
  Future<List<Schedule>> getAllSchedulesForSelection({
    int? classeId,
    int? disciplineId,
    int? dayOfWeek,
    bool? activeStatus,
    int? year,
  });

  Future<List<Discipline>> getAllActiveDisciplines();
  Future<List<Classe>> getAllActiveClasses();
}
