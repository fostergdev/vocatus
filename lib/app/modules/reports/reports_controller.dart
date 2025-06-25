// reports_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/repositories/reports/reports_repository.dart';
import 'package:vocatus/app/models/classe.dart'; // <--- Importa Classe (unificada)
import 'package:vocatus/app/models/grade.dart'; // <--- Importa Grade (para criar e usar helpers de tempo)
import 'package:vocatus/app/models/discipline.dart'; // <--- Importa Discipline (se precisar criar Discipline)


class ReportsController extends GetxController {
  final ReportsRepository _reportsRepository = ReportsRepository(
    DatabaseHelper.instance,
  );

  final selectedTabIndex = 0.obs;
  final selectedFilterYear = 0.obs;
  final yearsByTab = <int, List<int>>{}.obs;

  // As listas agora são de objetos Classe (unificada)
  final RxList<Classe> reportClasses = <Classe>[].obs;
  final RxList<Classe> filteredReportClasses = <Classe>[].obs;

  final RxList<Map<String, dynamic>> archivedStudents = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredArchivedStudents = <Map<String, dynamic>>[].obs;

  final searchText = ''.obs;

  final TextEditingController searchInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadYears();
    debounce(
      searchText,
      (_) => filterLists(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }

  Future<void> loadYears() async {
    final yearsMap = await _reportsRepository.getMinMaxYearsByTable();
    yearsByTab[0] = yearsMap['classes'] ?? [];
    yearsByTab[1] = yearsMap['students'] ?? [];
    final initialYears = yearsByTab[0] ?? [];
    if (initialYears.isNotEmpty) {
      selectedFilterYear.value = initialYears.first;
      await readClasses(year: initialYears.first);
    } else {
      selectedFilterYear.value = DateTime.now().year;
      await readClasses(year: selectedFilterYear.value);
    }
     if (yearsByTab[1]?.isNotEmpty ?? false) {
      await readStudents(year: yearsByTab[1]!.first);
    } else {
      await readStudents(year: DateTime.now().year);
    }

    filterLists();
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
    searchText.value = '';
    searchInputController.clear();

    final years = yearsByTab[index] ?? [];
    if (years.isNotEmpty) {
      selectedFilterYear.value = years.first;
      if (index == 0) {
        readClasses(year: selectedFilterYear.value);
      } else {
        readStudents(year: selectedFilterYear.value);
      }
    } else {
      selectedFilterYear.value = DateTime.now().year;
      if (index == 0) {
        readClasses(year: selectedFilterYear.value);
      } else {
        readStudents(year: selectedFilterYear.value);
      }
    }
    filterLists();
  }

  void onYearSelected(int tabIndex, int year) {
    selectedFilterYear.value = year;
    searchText.value = '';
    searchInputController.clear();

    if (selectedTabIndex.value == 0) {
      readClasses(year: year);
    } else {
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
            disciplineId: row['discipline_id'] as int?, // Garante que o ID da disciplina é passado para o Grade
            discipline: row['discipline_name'] != null
                ? Discipline(
                    id: row['discipline_id'] as int?, // Passa o ID da disciplina para o objeto Discipline
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
            active: classeActive == 1, // Converte int (0 ou 1) para bool
            schedules: [],
          );
        }
        if (gradeSchedule != null) {
          classMap[classeId]!.schedules.add(gradeSchedule);
        }
      }

      reportClasses.addAll(classMap.values.toList());
      filterLists();

    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os relatórios de turmas: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError, // Corrigido aqui
      );
    }
  }

  Future<void> readStudents({required int year}) async {
    try {
      final rawData = await _reportsRepository.getArchivedStudentsByYear(year);
      archivedStudents.value = rawData;
      filterLists();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível carregar os relatórios de alunos: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError, // Corrigido aqui
      );
    }
  }

  void filterLists() {
    final query = searchText.value.toLowerCase().trim();

    if (selectedTabIndex.value == 0) {
      if (query.isEmpty) {
        filteredReportClasses.value = reportClasses.toList();
      } else {
        filteredReportClasses.value = reportClasses.where((classe) {
          final name = classe.name.toLowerCase();
          final id = classe.id.toString().toLowerCase();
          return name.contains(query) || id.contains(query);
        }).toList();
      }
    } else {
      if (query.isEmpty) {
        filteredArchivedStudents.value = archivedStudents.toList();
      } else {
        filteredArchivedStudents.value = archivedStudents.where((student) {
          final name = (student['name'] as String? ?? '').toLowerCase();
          final id = (student['id'] as int? ?? 0).toString().toLowerCase();
          return name.contains(query) || id.contains(query);
        }).toList();
      }
    }
  }

  void onSearchTextChanged(String text) {
    searchText.value = text;
  }
}