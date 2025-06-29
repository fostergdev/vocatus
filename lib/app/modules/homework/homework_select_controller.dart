import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/repositories/classes/classes_repository.dart';
import 'dart:developer';

class HomeworkSelectController extends GetxController {
  final ClasseRepository _classeRepository = ClasseRepository(
    DatabaseHelper.instance,
  );

  final isLoading = false.obs;
  final classes = <Classe>[].obs;
  final filteredClasses = <Classe>[].obs;
  final searchController = TextEditingController();
  final selectedYear = DateTime.now().year.obs;

  @override
  void onInit() {
    log('HomeworkSelectController.onInit - Inicializando controller de seleção de turmas para homework', name: 'HomeworkSelectController');
    loadClasses();
    super.onInit();
  }

  @override
  void onClose() {
    log('HomeworkSelectController.onClose - Limpando recursos do controller', name: 'HomeworkSelectController');
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadClasses() async {
    try {
      isLoading.value = true;
      log('HomeworkSelectController.loadClasses - Carregando turmas ativas para seleção', name: 'HomeworkSelectController');
      
      final result = await _classeRepository.readClasses(
        year: selectedYear.value,
        active: true,
      );
      
      classes.value = result;
      _applySearchFilter();
      
      log('HomeworkSelectController.loadClasses - ${result.length} turmas carregadas com sucesso', name: 'HomeworkSelectController');
    } catch (e) {
      log('HomeworkSelectController.loadClasses - Erro ao carregar turmas: $e', name: 'HomeworkSelectController');
      Get.snackbar(
        'Erro',
        'Erro ao carregar turmas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void searchClasses(String query) {
    searchController.text = query;
    _applySearchFilter();
  }

  void _applySearchFilter() {
    if (searchController.text.isEmpty) {
      filteredClasses.value = classes.toList();
    } else {
      filteredClasses.value = classes
          .where((classe) => classe.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }
  }

  void selectClasse(Classe classe) {
    log('HomeworkSelectController.selectClasse - Navegando para homework da turma: ${classe.name}', name: 'HomeworkSelectController');
    Get.toNamed('/homework/home', arguments: classe);
  }

  void changeYear(int year) {
    selectedYear.value = year;
    loadClasses();
  }

  List<int> getAvailableYears() {
    final currentYear = DateTime.now().year;
    return [
      currentYear - 2,
      currentYear - 1,
      currentYear,
      currentYear + 1,
    ];
  }

  String getYearDisplayText(int year) {
    final currentYear = DateTime.now().year;
    if (year == currentYear) {
      return '$year (Atual)';
    } else if (year < currentYear) {
      return '$year (Anterior)';
    } else {
      return '$year (Próximo)';
    }
  }
}
