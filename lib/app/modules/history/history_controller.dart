import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/repositories/history/history_repository.dart';

class HistoryController extends GetxController {
  final selectedTabIndex = 0.obs;
  final selectedFilterYear = 0.obs;
  final yearsByTab = <int, List<int>>{}.obs;

  final archivedClasses = <Map<String, dynamic>>[].obs;
  final archivedStudents = <Map<String, dynamic>>[].obs;

  final filteredArchivedClasses = <Map<String, dynamic>>[].obs;
  final filteredArchivedStudents = <Map<String, dynamic>>[].obs;

  final searchText = ''.obs;

  late final TextEditingController searchInputController;

  final HistoryRepository _repository = HistoryRepository();

  @override
  void onInit() {
    super.onInit();
    searchInputController = TextEditingController();
    loadYears();
    debounce(searchText, (_) => filterLists(), time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }

  Future<void> loadYears() async {
    final yearsMap = await _repository.getMinMaxYearsByTable();
    yearsByTab[0] = yearsMap['classes'] ?? [];
    yearsByTab[1] = yearsMap['students'] ?? [];
    final initialYears = yearsByTab[0] ?? [];
    if (initialYears.isNotEmpty) {
      selectedFilterYear.value = initialYears.first;
      readClasses(year: initialYears.first);
    }
  }

  void onTabChanged(int index) {
    selectedTabIndex.value = index;
    final years = yearsByTab[index] ?? [];
    if (years.isNotEmpty) {
      selectedFilterYear.value = years.first;
      onYearSelected(index, years.first);
    }
    searchText.value = '';
    searchInputController.clear();
  }

  void onYearSelected(int tabIndex, int year) {
    selectedFilterYear.value = year;
    switch (tabIndex) {
      case 0:
        readClasses(year: year);
        break;
      case 1:
        readStudents(year: year);
        break;
    }
    searchText.value = '';
    searchInputController.clear();
  }

  Future<void> readClasses({required int year}) async {
    archivedClasses.value = await _repository.getArchivedClassesByYear(year);
    if (selectedTabIndex.value == 0) {
      filterLists();
    }
  }

  Future<void> readStudents({required int year}) async {
    archivedStudents.value = await _repository.getArchivedStudentsByYear(year);
    if (selectedTabIndex.value == 1) {
      filterLists();
    }
  }

  void filterLists() {
    final query = searchText.value.toLowerCase().trim();

    if (selectedTabIndex.value == 0) {
      if (query.isEmpty) {
        filteredArchivedClasses.value = archivedClasses.toList();
      } else {
        filteredArchivedClasses.value = archivedClasses.where((classe) {
          final name = (classe['name'] as String? ?? '').toLowerCase();
          final id = (classe['id'] as int? ?? 0).toString().toLowerCase();
          return name.contains(query) || id.contains(query);
        }).toList();
      }
    } else {
      if (query.isEmpty) {
        filteredArchivedStudents.value = archivedStudents.toList();
      } else {
        filteredArchivedStudents.value = archivedStudents.where((student) {
          final name = (student['name'] as String? ?? '').toLowerCase();
          return name.contains(query);
        }).toList();
      }
    }
  }

  void onSearchTextChanged(String text) {
    searchText.value = text;
  }
}