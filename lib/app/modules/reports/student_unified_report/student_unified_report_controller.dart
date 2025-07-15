import 'package:get/get.dart';
import 'package:vocatus/app/repositories/reports/reports_repository.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';

class StudentUnifiedReportController extends GetxController {
  final ReportsRepository _reportsRepository = ReportsRepository(
    DatabaseHelper.instance,
  );

  final RxBool isLoading = true.obs;
  final RxMap<String, dynamic> studentData = RxMap<String, dynamic>({});
  final RxList<Map<String, dynamic>> studentClasses =
      <Map<String, dynamic>>[].obs;
  final RxMap<String, List<Map<String, dynamic>>> studentOccurrences =
      RxMap<String, List<Map<String, dynamic>>>({});

  @override
  void onInit() {
    super.onInit();
    final studentId = Get.arguments as int?;
    if (studentId != null) {
      fetchStudentReport(studentId);
    } else {
      isLoading.value = false;
      Get.snackbar('Erro', 'ID do aluno não fornecido.');
    }
  }

  Future<void> fetchStudentReport(int studentId) async {
    try {
      isLoading.value = true;
      final details = await _reportsRepository.getStudentDetails(studentId);
      if (details != null) {
        studentData.value = details;
      }

      studentClasses.value = await _reportsRepository
          .getStudentClassesWithDetails(studentId);

      final rawOccurrences = await _reportsRepository
          .getStudentOccurrencesByClass(studentId);
      final Map<String, List<Map<String, dynamic>>> groupedOccurrences = {};

      for (var occ in rawOccurrences) {
        final type = occ['occurrence_type'] as String? ?? 'Outros';
        if (!groupedOccurrences.containsKey(type)) {
          groupedOccurrences[type] = [];
        }
        groupedOccurrences[type]!.add(occ);
      }

      // Sort occurrences within each group by date (descending)
      groupedOccurrences.forEach((key, value) {
        value.sort(
          (a, b) => (b['occurrence_date'] as String).compareTo(
            a['occurrence_date'] as String,
          ),
        );
      });

      studentOccurrences.value = groupedOccurrences;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o relatório do aluno: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
