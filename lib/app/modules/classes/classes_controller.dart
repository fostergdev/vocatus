

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/repositories/classes/classes_repository.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';

class ClassesController extends GetxController {
  final ClasseRepository _classeRepository;

  ClassesController() : _classeRepository = ClasseRepository(DatabaseHelper.instance);

  final isLoading = false.obs;
  final classes = <Classe>[].obs;

  final classeDescriptionEC = TextEditingController();
  final classeNameEC = TextEditingController();
  final classeSchoolYearEC = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final formKey = GlobalKey<FormState>();

  final RxInt selectedFilterYear = DateTime.now().year.obs;
  final RxBool showOnlyActiveClasses = true.obs;

  final RxInt selectedYear = RxInt(DateTime.now().year); 

  final classeEditNameEC = TextEditingController();
  final formEditKey = GlobalKey<FormState>();

  @override
  void onInit() {
    readClasses(
      active: showOnlyActiveClasses.value,
      year: selectedFilterYear.value,
    );
    super.onInit();
  }

  Future<void> createClasse(Classe classe) async {
    try {
      isLoading.value = true;
      await _classeRepository.createClasse(classe);
      await readClasses(
        active: showOnlyActiveClasses.value,
        year: selectedFilterYear.value,
      );
    } catch (e, s) {
      String userMessage = 'Erro desconhecido ao criar turma.';
      if (e is String) {
        userMessage = e;
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
      }
      Get.dialog(CustomErrorDialog(title: 'Erro', message: userMessage));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> readClasses({bool? active, int? year}) async {
    isLoading.value = true;
    try {
      final filterActive = active ?? showOnlyActiveClasses.value;
      final filterYear = year ?? selectedFilterYear.value;

      final fetchedClasses = await _classeRepository.readClasses(
        active: filterActive,
        year: filterYear,
      );
      classes.value = fetchedClasses;
    } catch (e, s) {
      String userMessage = 'Erro ao carregar turmas.';
      if (e is String) {
        userMessage = e;
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
      }
      Get.dialog(CustomErrorDialog(title: 'Erro', message: userMessage));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateClasse(Classe classe) async {
    isLoading.value = true;
    try {
      await _classeRepository.updateClasse(classe);
      await readClasses(
        active: showOnlyActiveClasses.value,
        year: selectedFilterYear.value,
      );
      classeEditNameEC.clear();
    } catch (e, s) {
      String userMessage = 'Erro desconhecido ao atualizar turma.';
      if (e is String) {
        userMessage = e;
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
      }
      Get.dialog(CustomErrorDialog(title: 'Erro', message: userMessage));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> archiveClasse(Classe classe) async {
    isLoading.value = true;
    try {
      await _classeRepository.archiveClasseAndStudents(classe);
      await readClasses(
        active: showOnlyActiveClasses.value,
        year: selectedFilterYear.value,
      );
      Get.back(); 
    } catch (e, s) {
      String userMessage = 'Erro ao arquivar turma e alunos.';
      if (e is String) {
        userMessage = e;
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
      }
      Get.dialog(CustomErrorDialog(title: 'Erro', message: userMessage));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleClasseActiveStatus(Classe classe) async {
    if (classe.active ?? true) {
      await archiveClasse(classe);
    } else {
      Get.dialog(CustomErrorDialog(title: 'Ação Inválida', message: 'Não é possível reativar uma turma arquivada.'));
    }
  }
}