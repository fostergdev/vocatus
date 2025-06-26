// reports_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
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

  final RxList<Classe> reportClasses = <Classe>[].obs;
  final RxList<Classe> filteredReportClasses = <Classe>[].obs;

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
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }

  Future<void> loadYearsAndClasses() async {
    final yearsMap = await _reportsRepository.getMinMaxYearsByTable();
    yearsByTab[0] = yearsMap['classes'] ?? [];

    final initialYears = yearsByTab[0] ?? [];
    if (initialYears.isNotEmpty) {
      selectedFilterYear.value = initialYears.first;
      await readClasses(year: initialYears.first);
    } else {
      selectedFilterYear.value = DateTime.now().year;
      await readClasses(year: selectedFilterYear.value);
    }
    filterClasses();
  }

  void onYearSelected(int tabIndex, int year) {
    selectedFilterYear.value = year;
    searchText.value = '';
    searchInputController.clear();
    readClasses(year: year);
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

  void filterClasses() {
    final query = searchText.value.toLowerCase().trim();

    if (query.isEmpty) {
      filteredReportClasses.value = reportClasses.toList();
    } else {
      filteredReportClasses.value = reportClasses.where((classe) {
        final name = classe.name.toLowerCase();
        final id = classe.id.toString().toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();
    }
  }

  void onSearchTextChanged(String text) {
    searchText.value = text;
  }

  Future<void> loadAttendanceReport(int classId) async {
    isLoadingAttendance.value = true;
    try {
      final data = await _reportsRepository.getAttendanceReportByClassId(classId);
      attendanceReportData.value = data;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o relatório de chamadas: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      attendanceReportData.clear();
    } finally {
      isLoadingAttendance.value = false;
    }
  }
}