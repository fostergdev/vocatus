
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/repositories/reports/reports_repository.dart';
import 'package:vocatus/app/models/classe.dart';

enum AttendanceSortOrder {
  dateAscending,
  dateDescending,
  timeAscending,
}

class ReportsController extends GetxController {
  final ReportsRepository _reportsRepository = ReportsRepository(
    DatabaseHelper.instance,
  );

  final selectedFilterYear = 0.obs;
  final yearsByTab = <int, List<int>>{}.obs;
  final currentTabIndex = 0.obs;

  final RxList<Classe> reportClasses = <Classe>[].obs;
  final RxList<Classe> filteredReportClasses = <Classe>[].obs;

  final RxBool isLoadingOccurrences = false.obs;
  final RxList<Map<String, dynamic>> occurrencesData =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoadingHomework = false.obs;
  final RxList<Map<String, dynamic>> homeworkData =
      <Map<String, dynamic>>[].obs;

  
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

  final RxList<Map<String, dynamic>> attendanceReportData =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> sortedAttendanceReportData =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingAttendance = false.obs;
  final Rx<AttendanceSortOrder> currentAttendanceSortOrder =
      AttendanceSortOrder.dateDescending.obs;

  void sortAttendanceData() {
    final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(attendanceReportData);

    data.sort((a, b) {
      final dateA = DateTime.tryParse(a['date']) ?? DateTime.now();
      final dateB = DateTime.tryParse(b['date']) ?? DateTime.now();
      final timeA = a['start_time'] as String;
      final timeB = b['start_time'] as String;

      switch (currentAttendanceSortOrder.value) {
        case AttendanceSortOrder.dateAscending:
          final dateCompare = dateA.compareTo(dateB);
          if (dateCompare != 0) return dateCompare;
          return timeA.compareTo(timeB);
        case AttendanceSortOrder.dateDescending:
          final dateCompare = dateB.compareTo(dateA);
          if (dateCompare != 0) return dateCompare;
          return timeB.compareTo(timeA);
        case AttendanceSortOrder.timeAscending:
          final timeCompare = timeA.compareTo(timeB);
          if (timeCompare != 0) return timeCompare;
          return dateA.compareTo(dateB);
      }
    });
    sortedAttendanceReportData.assignAll(data);
  }

  void setAttendanceSortOrder(AttendanceSortOrder order) {
    currentAttendanceSortOrder.value = order;
    sortAttendanceData();
  }

  final searchText = ''.obs;
  final TextEditingController searchInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadYearsAndClasses();
    debounce(
      searchText,
      (_) => filterClasses(),
      time: const Duration(milliseconds: 300),
    );
    debounce(
      studentSearchText,
      (_) => filterStudents(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    searchInputController.dispose();
    studentSearchController.dispose();
    super.onClose();
  }

  Future<void> loadYearsAndClasses() async {
    final yearsMap = await _reportsRepository.getMinMaxYearsByTable();

    yearsByTab[0] = yearsMap['classes'] ?? [];
    yearsByTab[1] =
        yearsMap['students'] ??
        yearsMap['classes'] ??
        []; 

    final currentYear = DateTime.now().year;

    final initialYears = yearsByTab[0] ?? [];

    
    if (initialYears.isNotEmpty) {
      selectedFilterYear.value = initialYears.contains(currentYear)
          ? currentYear
          : initialYears.reduce(
              (a, b) => a > b ? a : b,
            ); 
      await readClasses(year: selectedFilterYear.value);
      await readStudents(year: selectedFilterYear.value);
    } else {
      selectedFilterYear.value = currentYear;
      await readClasses(year: selectedFilterYear.value);
      await readStudents(year: selectedFilterYear.value);
    }
    filterClasses();
    filterStudents();
  }

  void onYearSelected(int tabIndex, int year) {
    selectedFilterYear.value = year;
    currentTabIndex.value = tabIndex;

    if (tabIndex == 0) {
      searchText.value = '';
      searchInputController.clear();
      readClasses(year: year);
    } else {
      studentSearchText.value = '';
      studentSearchController.clear();
      readStudents(year: year);
    }
  }

  Future<void> readClasses({required int year}) async {
    try {
      final rawData = await _reportsRepository.getClassesRawReport(year);
      reportClasses.assignAll(Classe.fromRawReportList(rawData));
      filterClasses();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os relatórios de turmas: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
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

  void filterClasses() {
    final query = searchText.value.toLowerCase().trim();

    if (query.isEmpty) {
      filteredReportClasses.value = reportClasses.toList();
    } else {
      filteredReportClasses.value = reportClasses.where((classe) {
        final name = classe.name.toLowerCase();
        return name.contains(query);
      }).toList();
    }
  }

  void filterStudents() {
    final query = studentSearchText.value.toLowerCase().trim();

    if (query.isEmpty) {
      filteredReportStudents.value = reportStudents.toList();
    } else {
      filteredReportStudents.value = reportStudents.where((student) {
        final name = student['name'].toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }
  }

  void onSearchTextChanged(String text) {
    searchText.value = text;
  }

  void onStudentSearchTextChanged(String text) {
    studentSearchText.value = text;
  }

  Future<void> loadAttendanceReport(int classId) async {
    try {
      isLoadingAttendance.value = true;
      final data = await _reportsRepository.getAttendanceReportByClassId(
        classId,
      );
      attendanceReportData.assignAll(data);
      sortAttendanceData();
    } catch (e) {
      
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  
  void openAttendanceReport(Classe classe) {
    Get.toNamed(
      '/reports/attendance-report',
      arguments: {'classId': classe.id, 'className': classe.name},
    );
  }

  void openSchedulesReport(Classe classe) {
    Get.toNamed(
      '/reports/schedules-report',
      arguments: {'classId': classe.id, 'className': classe.name},
    );
  }

  void openOccurrencesReport(Classe classe) {
    Get.toNamed(
      '/reports/occurrences-report',
      arguments: {'classId': classe.id, 'className': classe.name},
    );
  }

  
  void openStudentAttendanceReport(Map<String, dynamic> student) {
    Get.toNamed(
      '/reports/student-attendance-report',
      arguments: {'studentId': student['id'], 'studentName': student['name']},
    );
  }

  void openStudentSchedulesReport(Map<String, dynamic> student) {
    Get.toNamed(
      '/reports/student-schedules-report',
      arguments: {'studentId': student['id'], 'studentName': student['name']},
    );
  }

  void openStudentOccurrencesReport(Map<String, dynamic> student) {
    Get.toNamed(
      '/reports/student-occurrences-report',
      arguments: {'studentId': student['id'], 'studentName': student['name']},
    );
  }

  
  Future<List<Map<String, dynamic>>> getStudentAttendanceDetails(
    int studentId,
  ) async {
    try {
      return await _reportsRepository.getStudentAttendanceReport(studentId);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o relatório de presenças: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getStudentOccurrencesDetails(
    int studentId,
  ) async {
    try {
      return await _reportsRepository.getStudentOccurrencesReport(studentId);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o relatório de ocorrências: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return [];
    }
  }

  
  Future<void> loadStudentAttendanceHistory(int studentId) async {
    isLoadingStudentAttendance.value = true;
    try {
      final data = await _reportsRepository.getStudentAttendanceReport(
        studentId,
      );
      studentAttendanceHistory.value = data;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o histórico de frequência: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      studentAttendanceHistory.clear();
    } finally {
      isLoadingStudentAttendance.value = false;
    }
  }

  Future<void> loadStudentOccurrencesHistory(int studentId) async {
    isLoadingStudentOccurrences.value = true;
    try {
      final data = await _reportsRepository.getStudentOccurrencesReport(
        studentId,
      );
      studentOccurrencesHistory.value = data;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o histórico de ocorrências: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      studentOccurrencesHistory.clear();
    } finally {
      isLoadingStudentOccurrences.value = false;
    }
  }

  
  void openStudentUnifiedReport(Map<String, dynamic> student) {
    Get.toNamed('/reports/student-unified-report', arguments: student);
  }

  Future<void> loadOccurrencesReport(int classeId) async {
    try {
      isLoadingOccurrences.value = true;
      occurrencesData.clear();

      
      final result = await _reportsRepository.getOccurrencesReportByClassId(
        classeId,
      );

      
      final processedResult = result.map((item) {
        
        try {
          if (item['date'] != null && item['date'].toString().isNotEmpty) {
            final DateTime date = DateTime.parse(item['date'].toString());
            item['date'] = date.toIso8601String().split('T')[0];
          }
        } catch (e) {
          
        }
        return item;
      }).toList();

      occurrencesData.addAll(processedResult);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar as ocorrências: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingOccurrences.value = false;
    }
  }

  
  Future<void> loadHomeworkReport(int classId) async {
    try {
      isLoadingHomework.value = true;
      homeworkData.clear();
      final result = await _reportsRepository.getHomeworkByClassId(classId);

      
      final processedResult = result.map((item) {
        
        try {
          if (item['due_date'] != null &&
              item['due_date'].toString().isNotEmpty) {
            final DateTime dueDate = DateTime.parse(
              item['due_date'].toString(),
            );
            item['due_date_formatted'] = DateFormat(
              'dd/MM/yyyy',
            ).format(dueDate);
          }
          if (item['assigned_date'] != null &&
              item['assigned_date'].toString().isNotEmpty) {
            final DateTime assignedDate = DateTime.parse(
              item['assigned_date'].toString(),
            );
            item['assigned_date_formatted'] = DateFormat(
              'dd/MM/yyyy',
            ).format(assignedDate);
          }
        } catch (e) {
          
        }
        return item;
      }).toList();

      homeworkData.addAll(processedResult);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar as tarefas de casa: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingHomework.value = false;
    }
  }
}
