import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/schedule.dart';

abstract class IScheduleRepository {
  Future<Schedule> createSchedule(Schedule schedule);
  Future<List<Schedule>> getSchedulesByClasseId(int classeId);
  Future<List<Schedule>> getAllSchedules({
    int? classeId,
    int? disciplineId,
    int? dayOfWeek,
    bool? activeStatus = true,
    int? year,
  });
  Future<void> updateSchedule(Schedule schedule);
  Future<void> toggleScheduleActiveStatus(Schedule schedule);
  Future<void> deleteSchedule(int scheduleId);
  Future<List<Discipline>> getAllDisciplines();
  Future<List<Classe>> getAllActiveClasses([int? year]);
}
