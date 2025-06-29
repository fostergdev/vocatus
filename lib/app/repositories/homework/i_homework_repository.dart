import 'package:vocatus/app/models/homework.dart';
import 'package:vocatus/app/models/discipline.dart';

abstract class IHomeworkRepository {
  Future<List<Homework>> getHomeworksByClasseId(int classeId);
  Future<List<Homework>> getHomeworksByStatus(HomeworkStatus status, {int? classeId});
  Future<List<Homework>> getHomeworksByDateRange(DateTime startDate, DateTime endDate, {int? classeId});
  Future<void> createHomework(Homework homework);
  Future<void> updateHomework(Homework homework);
  Future<void> deleteHomework(int homeworkId);
  Future<Homework?> getHomeworkById(int homeworkId);
  Future<List<Discipline>> getAvailableDisciplines({int? classeId});
  Future<List<Homework>> getOverdueHomeworks({int? classeId});
  Future<List<Homework>> getTodayHomeworks({int? classeId});
  Future<List<Homework>> getUpcomingHomeworks({int? classeId, int? days});
}
