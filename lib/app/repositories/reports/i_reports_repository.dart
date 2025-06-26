// app/repositories/reports/i_reports_repository.dart
abstract class IReportsRepository {
  Future<List<Map<String, dynamic>>> getClassesRawReport(int year);
  Future<Map<String, List<int>>> getMinMaxYearsByTable();
  Future<List<Map<String, dynamic>>> getArchivedStudentsByYear(int year);
  Future<List<Map<String, dynamic>>> getAttendanceReportByClassId(int classId);
  Future<Map<String, dynamic>?> getStudentDetails(int studentId);
  Future<List<Map<String, dynamic>>> getStudentsByClassId(int classId);
}
