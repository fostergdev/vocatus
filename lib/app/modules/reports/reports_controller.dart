import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/repositories/reports/reports_repository.dart';

class ReportsController extends GetxController {
  final ReportsRepository _reportsRepository = ReportsRepository(
    DatabaseHelper.instance,
  );
  late final Rx<Classe> classe;

  final RxBool isLoadingAttendances = true.obs;
  final RxBool isLoadingOccurrences = true.obs;
  final RxBool isLoadingHomeworks = true.obs;
  final RxBool isLoadingAttendanceGrid = true.obs;

  final RxList<dynamic> attendances = <dynamic>[].obs;
  final RxList<dynamic> occurrences = <dynamic>[].obs;
  final RxList<dynamic> homeworks = <dynamic>[].obs;

  final RxInt totalAttendances = 0.obs;
  final RxDouble attendancePercentage = 0.0.obs;
  final RxDouble averageOccurrences = 0.0.obs;
  final RxMap<String, int> occurrenceCountByType = <String, int>{}.obs;
  final RxInt touchedIndex = (-1).obs;

  // Attendance Grid Data
  final RxList<String> attendanceDates = <String>[].obs;
  final RxList<Map<String, dynamic>> attendanceStudentsData =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> attendanceSessions =
      <Map<String, dynamic>>[].obs;

  // Student Reports Data
  final selectedFilterYear = DateTime.now().year.obs;
  final availableYears = <int>[].obs;
  final RxList<Map<String, dynamic>> reportStudents =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredReportStudents =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingStudents = false.obs;
  final studentSearchText = ''.obs;
  final TextEditingController studentSearchController = TextEditingController();

  final RxList<Map<String, dynamic>> studentAttendanceHistory =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> studentOccurrencesHistory =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingStudentAttendance = false.obs;
  final RxBool isLoadingStudentOccurrences = false.obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    if (args is Classe) {
      classe = Rx<Classe>(args);
      fetchReportsData(classe.value.id!);
      fetchAttendanceGridData(classe.value.id!); // Fetch grid data
    } else if (args is int) {
      // Assuming student ID is passed as int for unified report
      openStudentUnifiedReport({'id': args});
    } else {
      loadYearsAndStudents(); // Load student reports data if no specific class or student is passed
    }
    debounce(
      studentSearchText,
      (_) => filterStudents(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    studentSearchController.dispose();
    super.onClose();
  }

  Future<void> loadYearsAndStudents() async {
    final yearsMap = await _reportsRepository.getMinMaxYearsByTable();
    final studentYears = yearsMap['students'] ?? yearsMap['classes'] ?? [];

    availableYears.value = studentYears;

    final currentYear = DateTime.now().year;
    if (studentYears.contains(currentYear)) {
      selectedFilterYear.value = currentYear;
    } else if (studentYears.isNotEmpty) {
      selectedFilterYear.value = studentYears.reduce((a, b) => a > b ? a : b);
    }

    await readStudents(year: selectedFilterYear.value);
    filterStudents();
  }

  void onYearSelected(int year) {
    selectedFilterYear.value = year;
    studentSearchText.value = '';
    studentSearchController.clear();
    readStudents(year: year);
  }

  Future<void> readStudents({required int year}) async {
    isLoadingStudents.value = true;

    try {
      final studentsData = await _reportsRepository.getStudentsWithReportsData(
        year,
      );

      reportStudents.clear();

      for (var studentData in studentsData) {
        final totalClasses = studentData['total_classes'] as int? ?? 0;
        final totalPresences = studentData['total_presences'] as int? ?? 0;
        final totalAbsences = studentData['total_absences'] as int? ?? 0;
        final totalOccurrences = studentData['total_occurrences'] as int? ?? 0;

        final attendancePercentage = totalClasses > 0
            ? (totalPresences / totalClasses * 100).toStringAsFixed(1)
            : '0.0';

        final studentReport = {
          'id': studentData['id'],
          'name': studentData['name'],
          'active': studentData['active'],
          'class_name': studentData['class_name'] ?? 'Sem turma',
          'year': studentData['school_year'],
          'total_classes': totalClasses,
          'total_presences': totalPresences,
          'total_absences': totalAbsences,
          'total_occurrences': totalOccurrences,
          'attendance_percentage': attendancePercentage,
        };

        reportStudents.add(studentReport);
      }

      filterStudents();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os relatórios de alunos: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingStudents.value = false;
    }
  }

  void filterStudents() {
    final query = studentSearchText.value.toLowerCase().trim();

    if (query.isEmpty) {
      filteredReportStudents.value = reportStudents.toList();
    } else {
      filteredReportStudents.value = reportStudents.where((student) {
        final name = student['name'].toString().toLowerCase();
        final className = student['class_name'].toString().toLowerCase();
        return name.contains(query) || className.contains(query);
      }).toList();
    }
  }

  void onStudentSearchTextChanged(String text) {
    studentSearchText.value = text;
  }

  void openStudentUnifiedReport(Map<String, dynamic> student) {
    // Implement navigation to unified report page, passing student data
    // For now, just load attendance and occurrences history
    if (student['id'] != null) {
      loadStudentAttendanceHistory(student['id'] as int);
      loadStudentOccurrencesHistory(student['id'] as int);
    }
  }

  Future<void> loadStudentAttendanceHistory(int studentId) async {
    isLoadingStudentAttendance.value = true;
    try {
      final attendanceData = await _reportsRepository
          .getStudentAttendanceReport(studentId);
      studentAttendanceHistory.value = attendanceData;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o histórico de frequência do aluno.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingStudentAttendance.value = false;
    }
  }

  Future<void> loadStudentOccurrencesHistory(int studentId) async {
    isLoadingStudentOccurrences.value = true;
    try {
      final occurrencesData = await _reportsRepository
          .getStudentOccurrencesReport(studentId);
      studentOccurrencesHistory.value = occurrencesData;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o histórico de ocorrências do aluno.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingStudentOccurrences.value = false;
    }
  }

  Future<void> fetchReportsData(int classId) async {
    try {
      isLoadingAttendances(true);
      final result = await _reportsRepository.getAttendanceReportByClassId(
        classId,
      );
      attendances.assignAll(result);

      final count = await _reportsRepository.getTotalAttendancesCountByClassId(
        classId,
      );
      totalAttendances.value = count;

      final percentage = await _reportsRepository
          .getAttendancePercentageByClassId(classId);
      attendancePercentage.value = percentage;
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar os dados de presença.');
    } finally {
      isLoadingAttendances(false);
    }

    try {
      isLoadingOccurrences(true);
      final result = await _reportsRepository.getOccurrencesReportByClassId(
        classId,
      );
      occurrences.assignAll(result);

      final average = await _reportsRepository.getAverageOccurrencesPerClass(
        classId,
      );
      averageOccurrences.value = average;

      final counts = await _reportsRepository.getOccurrenceCountByType(classId);
      occurrenceCountByType.value = counts;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os dados de ocorrências.',
      );
    } finally {
      isLoadingOccurrences(false);
    }

    try {
      isLoadingHomeworks(true);
      final result = await _reportsRepository.getHomeworkByClassId(classId);
      homeworks.assignAll(result);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os dados de tarefas de casa.',
      );
    } finally {
      isLoadingHomeworks(false);
    }
  }

  Future<void> fetchAttendanceGridData(int classId) async {
    try {
      isLoadingAttendanceGrid(true);
      final data = await _reportsRepository.getAttendanceGridDataByClassId(
        classId,
      );
      attendanceSessions.assignAll(
        data['sessions'] as List<Map<String, dynamic>>,
      );
      attendanceStudentsData.assignAll(
        data['students'] as List<Map<String, dynamic>>,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os dados da grade de presença.',
      );
    } finally {
      isLoadingAttendanceGrid(false);
    }
  }

  int getTotalAttendances() {
    return totalAttendances.value;
  }

  int getTotalOccurrences() {
    return occurrences.length;
  }

  int getTotalHomeworks() {
    return homeworks.length;
  }
}