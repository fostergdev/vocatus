
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/repositories/reports/reports_repository.dart';

class StudentsReportsController extends GetxController {
  final ReportsRepository _reportsRepository = ReportsRepository(
    DatabaseHelper.instance,
  );

  final selectedFilterYear = DateTime.now().year.obs; 
  final availableYears = <int>[].obs;

  
  final RxList<Map<String, dynamic>> reportStudents = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredReportStudents = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingStudents = false.obs;
  final studentSearchText = ''.obs;
  final TextEditingController studentSearchController = TextEditingController();

  
  final RxList<Map<String, dynamic>> studentAttendanceHistory = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> studentOccurrencesHistory = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingStudentAttendance = false.obs;
  final RxBool isLoadingStudentOccurrences = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadYearsAndStudents();
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
      final studentsData = await _reportsRepository.getStudentsWithReportsData(year);
      
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
    Get.toNamed('/student/unified-report', arguments: student);
  }

  
  Future<void> loadStudentAttendanceHistory(int studentId) async {
    isLoadingStudentAttendance.value = true;
    try {
      final attendanceData = await _reportsRepository.getStudentAttendanceReport(studentId);
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
      final occurrencesData = await _reportsRepository.getStudentOccurrencesReport(studentId);
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
}
