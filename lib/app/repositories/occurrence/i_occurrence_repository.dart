import 'package:vocatus/app/models/occurrence.dart';
import 'package:vocatus/app/models/student.dart';

abstract class IOccurrenceRepository {
  Future<List<Occurrence>> getOccurrencesByAttendanceId(int attendanceId);
  Future<List<Occurrence>> getOccurrencesByStudentId(int studentId);
  Future<List<Occurrence>> getOccurrencesByClasseId(int classeId, {DateTime? startDate, DateTime? endDate});
  Future<List<Occurrence>> getOccurrencesByType(OccurrenceType type, {int? classeId});
  Future<List<Occurrence>> getGeneralOccurrences({int? classeId, DateTime? startDate, DateTime? endDate});
  Future<List<Occurrence>> getStudentOccurrences({int? classeId, int? studentId, DateTime? startDate, DateTime? endDate});
  Future<void> createOccurrence(Occurrence occurrence);
  Future<void> updateOccurrence(Occurrence occurrence);
  Future<void> deleteOccurrence(int occurrenceId);
  Future<Occurrence?> getOccurrenceById(int occurrenceId);
  Future<List<Student>> getStudentsFromAttendance(int attendanceId);
}
