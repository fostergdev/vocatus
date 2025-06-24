abstract class IReportsRepository {
  Future<List<Map<String, dynamic>>> getClassesRawReport(int year);
}
