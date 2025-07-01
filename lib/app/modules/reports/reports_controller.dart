// reports_controller.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/repositories/reports/reports_repository.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/discipline.dart';

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
   final RxList<Map<String, dynamic>> occurrencesData = <Map<String, dynamic>>[].obs;
  
  // Student-related observables
  final RxList<Map<String, dynamic>> reportStudents = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredReportStudents = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingStudents = false.obs;
  final studentSearchText = ''.obs;
  final TextEditingController studentSearchController = TextEditingController();

  // Unified student report observables
  final RxList<Map<String, dynamic>> studentAttendanceHistory = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> studentOccurrencesHistory = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingStudentAttendance = false.obs;
  final RxBool isLoadingStudentOccurrences = false.obs;

  final RxList<Map<String, dynamic>> attendanceReportData = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingAttendance = false.obs;

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
    log('🚀 ReportsController.loadYearsAndClasses - Iniciando...', name: 'ReportsController');
    final yearsMap = await _reportsRepository.getMinMaxYearsByTable();
    log('📅 Anos disponíveis: $yearsMap', name: 'ReportsController');
    
    yearsByTab[0] = yearsMap['classes'] ?? [];
    yearsByTab[1] = yearsMap['students'] ?? yearsMap['classes'] ?? []; // Use same years for students initially

    final currentYear = DateTime.now().year;
    log('📆 Ano atual: $currentYear', name: 'ReportsController');
    
    final initialYears = yearsByTab[0] ?? [];
    
    // Sempre iniciar no ano vigente se disponível, senão usar o mais recente
    if (initialYears.isNotEmpty) {
      selectedFilterYear.value = initialYears.contains(currentYear) 
          ? currentYear 
          : initialYears.reduce((a, b) => a > b ? a : b); // Pegar o ano mais recente
      log('🎯 Ano selecionado: ${selectedFilterYear.value}', name: 'ReportsController');
      await readClasses(year: selectedFilterYear.value);
      await readStudents(year: selectedFilterYear.value);
    } else {
      selectedFilterYear.value = currentYear;
      log('⚠️ Nenhum ano encontrado, usando ano atual: ${selectedFilterYear.value}', name: 'ReportsController');
      await readClasses(year: selectedFilterYear.value);
      await readStudents(year: selectedFilterYear.value);
    }
    filterClasses();
    filterStudents();
    log('✅ ReportsController.loadYearsAndClasses - Concluído', name: 'ReportsController');
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

      reportClasses.clear();
      final Map<int, Classe> classMap = {};

      for (var row in rawData) {
        final int classeId = row['classe_id'];
        final String classeName = row['classe_name'];
        final String? classeDescription = row['description'] as String?;
        final int schoolYear = row['school_year'] as int;
        final DateTime? classeCreatedAt = row['created_at'] != null ? DateTime.tryParse(row['created_at'].toString()) : null;
        final int classeActive = row['classe_active'] as int? ?? 1;

        final String startTimeStr = row['start_time'] as String? ?? '00:00';
        final String endTimeStr = row['end_time'] as String? ?? '00:00';
        final int startTimeMinutes = Grade.timeStringToInt(startTimeStr);
        final int endTimeMinutes = Grade.timeStringToInt(endTimeStr);

        Grade? gradeSchedule;
        if (row['day_of_week'] != null) {
          gradeSchedule = Grade(
            classeId: classeId,
            dayOfWeek: row['day_of_week'] as int,
            startTimeTotalMinutes: startTimeMinutes,
            endTimeTotalMinutes: endTimeMinutes,
            disciplineId: row['discipline_id'] as int?,
            discipline: row['discipline_name'] != null
                ? Discipline(
                    id: row['discipline_id'] as int?,
                    name: row['discipline_name'] as String,
                  )
                : null,
          );
        }

        if (!classMap.containsKey(classeId)) {
          classMap[classeId] = Classe(
            id: classeId,
            name: classeName,
            description: classeDescription,
            schoolYear: schoolYear,
            createdAt: classeCreatedAt,
            active: classeActive == 1,
            schedules: [],
          );
        }
        if (gradeSchedule != null) {
          classMap[classeId]!.schedules.add(gradeSchedule);
        }
      }

      reportClasses.addAll(classMap.values.toList());
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
    log('🔍 ReportsController.readStudents - Carregando alunos para o ano: $year', name: 'ReportsController');
    isLoadingStudents.value = true;
    try {
      final studentsData = await _reportsRepository.getStudentsWithReportsData(year);
      log('📊 ReportsController.readStudents - Dados recebidos: ${studentsData.length} alunos', name: 'ReportsController');
      
      reportStudents.clear();
      
      for (var studentData in studentsData) {
        final totalClasses = studentData['total_classes'] as int? ?? 0;
        final totalPresences = studentData['total_presences'] as int? ?? 0;
        final totalAbsences = studentData['total_absences'] as int? ?? 0;
        final totalOccurrences = studentData['total_occurrences'] as int? ?? 0;
        
        // Calculate attendance percentage
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
        log('👤 Aluno adicionado: ${studentData['name']} (Turma: ${studentData['class_name']})', name: 'ReportsController');
      }
      
      log('📝 Total de alunos processados: ${reportStudents.length}', name: 'ReportsController');
      filterStudents();
    } catch (e) {
      log('❌ Erro ao carregar alunos: ${e.toString()}', name: 'ReportsController');
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
    final data = await _reportsRepository.getAttendanceReportByClassId(classId);
    attendanceReportData.assignAll(data);
  } catch (e) {
    log('Erro ao carregar relatório de presença: $e', name: 'ReportsController');
  } finally {
    isLoadingAttendance.value = false;
  }
}

  // Class report methods
  void openAttendanceReport(Classe classe) {
    Get.toNamed('/reports/attendance-report', arguments: {
      'classId': classe.id,
      'className': classe.name,
    });
  }

  void openGradesReport(Classe classe) {
    Get.toNamed('/reports/grades-report', arguments: {
      'classId': classe.id,
      'className': classe.name,
    });
  }

  void openOccurrencesReport(Classe classe) {
    Get.toNamed('/reports/occurrences-report', arguments: {
      'classId': classe.id,
      'className': classe.name,
    });
  }

  // Student report methods
  void openStudentAttendanceReport(Map<String, dynamic> student) {
    Get.toNamed('/reports/student-attendance-report', arguments: {
      'studentId': student['id'],
      'studentName': student['name'],
    });
  }

  void openStudentGradesReport(Map<String, dynamic> student) {
    Get.toNamed('/reports/student-grades-report', arguments: {
      'studentId': student['id'],
      'studentName': student['name'],
    });
  }

  void openStudentOccurrencesReport(Map<String, dynamic> student) {
    Get.toNamed('/reports/student-occurrences-report', arguments: {
      'studentId': student['id'],
      'studentName': student['name'],
    });
  }

  // Methods to get detailed reports
  Future<List<Map<String, dynamic>>> getStudentAttendanceDetails(int studentId) async {
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

  Future<List<Map<String, dynamic>>> getStudentOccurrencesDetails(int studentId) async {
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

  // Unified student report methods
  Future<void> loadStudentAttendanceHistory(int studentId) async {
    isLoadingStudentAttendance.value = true;
    try {
      final data = await _reportsRepository.getStudentAttendanceReport(studentId);
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
      final data = await _reportsRepository.getStudentOccurrencesReport(studentId);
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

  // New unified student report navigation
  void openStudentUnifiedReport(Map<String, dynamic> student) {
    Get.toNamed('/reports/student-unified-report', arguments: student);
  }

  Future<void> loadOccurrencesReport(int classeId) async {
  try {
    log('⏳ Iniciando carregamento de ocorrências para turma $classeId', name: 'ReportsController');
    isLoadingOccurrences.value = true;
    occurrencesData.clear();
    
    // Usar o repository para buscar as ocorrências
    final result = await _reportsRepository.getOccurrencesReportByClassId(classeId);
    
    log('📊 Ocorrências recebidas: ${result.length}', name: 'ReportsController');
    if (result.isNotEmpty) {
      log('📋 Primeira ocorrência: ${result.first}', name: 'ReportsController');
    } else {
      log('⚠️ Nenhuma ocorrência encontrada para esta turma', name: 'ReportsController');
    }
    
    // Process dates for consistent formatting
    final processedResult = result.map((item) {
      // Parse and standardize date format
      try {
        if (item['date'] != null && item['date'].toString().isNotEmpty) {
          final DateTime date = DateTime.parse(item['date'].toString());
          item['date'] = date.toIso8601String().split('T')[0];
        }
      } catch (e) {
        log('⚠️ Erro ao processar data: ${item['date']} - $e', name: 'ReportsController');
      }
      return item;
    }).toList();
    
    occurrencesData.addAll(processedResult);
    log('✅ Ocorrências carregadas e processadas: ${occurrencesData.length}', name: 'ReportsController');
  } catch (e) {
    log('❌ Erro ao carregar ocorrências: $e', name: 'ReportsController');
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
}