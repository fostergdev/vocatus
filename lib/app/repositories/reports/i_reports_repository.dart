abstract class IReportsRepository {
  Future<List<Map<String, dynamic>>> getClassesRawReport(int year);
  Future<Map<String, List<int>>> getMinMaxYearsByTable();
  Future<List<Map<String, dynamic>>> getArchivedStudentsByYear(int year);
  Future<List<Map<String, dynamic>>> getAttendanceReportByClassId(int classId);
  Future<Map<String, dynamic>?> getStudentDetails(int studentId);
  Future<List<Map<String, dynamic>>> getStudentsByClassId(int classId);
  Future<List<Map<String, dynamic>>> getStudentsWithReportsData(int year);
  Future<List<Map<String, dynamic>>> getStudentAttendanceReport(int studentId);
  Future<List<Map<String, dynamic>>> getStudentOccurrencesReport(int studentId);
  Future<List<Map<String, dynamic>>> getOccurrencesReportByClassId(int classId);
  Future<List<Map<String, dynamic>>> getHomeworkByClassId(int classId);
  Future<int> getTotalAttendancesCountByClassId(int classId);
  Future<double> getAttendancePercentageByClassId(int classId);
  Future<double> getAverageOccurrencesPerClass(int classId);
  Future<Map<String, int>> getOccurrenceCountByType(int classId);
  Future<Map<String, dynamic>> getAttendanceGridDataByClassId(int classId);
  Future<List<Map<String, dynamic>>> getStudentClassesWithDetails(int studentId);
  Future<List<Map<String, dynamic>>> getStudentOccurrencesByClass(int studentId);
}
