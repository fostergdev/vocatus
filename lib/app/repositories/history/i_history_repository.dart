abstract class IHistoryRepository {
  Future<Map<String, List<int>>> getMinMaxYearsByTable();
  Future<List<Map<String, dynamic>>> getArchivedClassesByYear(int year);
  Future<List<Map<String, dynamic>>> getArchivedStudentsByYear(int year);
}
