// app/controllers/classes_controller.dart

import 'dart:developer'; // Importar o package developer para usar log
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
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

  final RxInt selectedYear = RxInt(DateTime.now().year); // Parece não ser usado diretamente, mas mantido.

  final classeEditNameEC = TextEditingController();
  final formEditKey = GlobalKey<FormState>();

  @override
  void onInit() {
    log('ClassesController.onInit - Inicializando controller.', name: 'ClassesController');
    readClasses(
      active: showOnlyActiveClasses.value,
      year: selectedFilterYear.value,
    );
    super.onInit();
    log('ClassesController.onInit - Controller inicializado. Chamada inicial a readClasses.', name: 'ClassesController');
  }

  Future<void> createClasse(Classe classe) async {
    log('ClassesController.createClasse - Tentando criar nova turma: ${classe.name} (${classe.schoolYear}).', name: 'ClassesController');
    try {
      isLoading.value = true;
      log('ClassesController.createClasse - Chamando repository para criar turma.', name: 'ClassesController');
      await _classeRepository.createClasse(classe);
      log('ClassesController.createClasse - Turma criada no repository. Recarregando lista de turmas...', name: 'ClassesController');
      await readClasses(
        active: showOnlyActiveClasses.value,
        year: selectedFilterYear.value,
      );
      log('ClassesController.createClasse - Turma criada e lista de turmas recarregada com sucesso.', name: 'ClassesController');
    } catch (e, s) { // <-- Já está capturando o stack trace 's'
      log('ClassesController.createClasse - Erro ao criar turma: $e', name: 'ClassesController', error: e, stackTrace: s); // <-- Já está usando 'stackTrace: s'
      String userMessage = 'Erro desconhecido ao criar turma.';
      if (e is String) {
        userMessage = e;
        log('ClassesController.createClasse - Erro é String: $userMessage', name: 'ClassesController');
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
        log('ClassesController.createClasse - Erro formatado: $userMessage', name: 'ClassesController');
      }
      Get.dialog(CustomErrorDialog(title: 'Erro', message: userMessage));
      log('ClassesController.createClasse - Diálogo de erro exibido.', name: 'ClassesController');
    } finally {
      isLoading.value = false;
      log('ClassesController.createClasse - Finalizando createClasse. isLoading = false.', name: 'ClassesController');
    }
  }

  Future<void> readClasses({bool? active, int? year}) async {
    log('ClassesController.readClasses - Iniciando leitura de turmas.', name: 'ClassesController');
    log('ClassesController.readClasses - Filtros recebidos: active=$active, year=$year.', name: 'ClassesController');
    isLoading.value = true;
    try {
      final filterActive = active ?? showOnlyActiveClasses.value;
      final filterYear = year ?? selectedFilterYear.value;
      log('ClassesController.readClasses - Filtros efetivos: active=$filterActive, year=$filterYear.', name: 'ClassesController');

      log('ClassesController.readClasses - Chamando repository para ler turmas.', name: 'ClassesController');
      final fetchedClasses = await _classeRepository.readClasses(
        active: filterActive,
        year: filterYear,
      );
      classes.value = fetchedClasses;
      log('ClassesController.readClasses - ${fetchedClasses.length} turmas lidas com sucesso e atualizadas na lista observável.', name: 'ClassesController');
    } catch (e, s) { // <-- Já está capturando o stack trace 's'
      log('ClassesController.readClasses - Erro ao ler turmas: $e', name: 'ClassesController', error: e, stackTrace: s); // <-- Já está usando 'stackTrace: s'
      String userMessage = 'Erro ao carregar turmas.';
      if (e is String) {
        userMessage = e;
        log('ClassesController.readClasses - Erro é String: $userMessage', name: 'ClassesController');
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
        log('ClassesController.readClasses - Erro formatado: $userMessage', name: 'ClassesController');
      }
      Get.dialog(CustomErrorDialog(title: 'Erro', message: userMessage));
      log('ClassesController.readClasses - Diálogo de erro exibido.', name: 'ClassesController');
    } finally {
      isLoading.value = false;
      log('ClassesController.readClasses - Finalizando readClasses. isLoading = false.', name: 'ClassesController');
    }
  }

  Future<void> updateClasse(Classe classe) async {
    log('ClassesController.updateClasse - Tentando atualizar turma: ID=${classe.id}, Nome=${classe.name}.', name: 'ClassesController');
    isLoading.value = true;
    try {
      log('ClassesController.updateClasse - Chamando repository para atualizar turma.', name: 'ClassesController');
      await _classeRepository.updateClasse(classe);
      log('ClassesController.updateClasse - Turma atualizada no repository. Recarregando lista de turmas...', name: 'ClassesController');
      await readClasses(
        active: showOnlyActiveClasses.value,
        year: selectedFilterYear.value,
      );
      classeEditNameEC.clear();
      log('ClassesController.updateClasse - Turma atualizada e lista recarregada com sucesso. Campo de edição limpo.', name: 'ClassesController');
    } catch (e, s) { // <-- Já está capturando o stack trace 's'
      log('ClassesController.updateClasse - Erro ao atualizar turma: $e', name: 'ClassesController', error: e, stackTrace: s); // <-- Já está usando 'stackTrace: s'
      String userMessage = 'Erro desconhecido ao atualizar turma.';
      if (e is String) {
        userMessage = e;
        log('ClassesController.updateClasse - Erro é String: $userMessage', name: 'ClassesController');
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
        log('ClassesController.updateClasse - Erro formatado: $userMessage', name: 'ClassesController');
      }
      Get.dialog(CustomErrorDialog(title: 'Erro', message: userMessage));
      log('ClassesController.updateClasse - Diálogo de erro exibido.', name: 'ClassesController');
    } finally {
      isLoading.value = false;
      log('ClassesController.updateClasse - Finalizando updateClasse. isLoading = false.', name: 'ClassesController');
    }
  }

  Future<void> archiveClasse(Classe classe) async {
    log('ClassesController.archiveClasse - Tentando arquivar turma: ID=${classe.id}, Nome=${classe.name}.', name: 'ClassesController');
    isLoading.value = true;
    try {
      log('ClassesController.archiveClasse - Chamando repository para arquivar turma e alunos associados.', name: 'ClassesController');
      await _classeRepository.archiveClasseAndStudents(classe);
      log('ClassesController.archiveClasse - Turma e alunos arquivados no repository. Recarregando lista de turmas...', name: 'ClassesController');
      await readClasses(
        active: showOnlyActiveClasses.value,
        year: selectedFilterYear.value,
      );
      Get.back(); // Volta da tela/diálogo de confirmação, se houver
      log('ClassesController.archiveClasse - Turma arquivada e lista recarregada com sucesso. Retornando da navegação.', name: 'ClassesController');
    } catch (e, s) { // <-- Já está capturando o stack trace 's'
      log('ClassesController.archiveClasse - Erro ao arquivar turma: $e', name: 'ClassesController', error: e, stackTrace: s); // <-- Já está usando 'stackTrace: s'
      String userMessage = 'Erro ao arquivar turma e alunos.';
      if (e is String) {
        userMessage = e;
        log('ClassesController.archiveClasse - Erro é String: $userMessage', name: 'ClassesController');
      } else {
        userMessage = e.toString().replaceAll('Exception: ', '');
        log('ClassesController.archiveClasse - Erro formatado: $userMessage', name: 'ClassesController');
      }
      Get.dialog(CustomErrorDialog(title: 'Erro', message: userMessage));
      log('ClassesController.archiveClasse - Diálogo de erro exibido.', name: 'ClassesController');
    } finally {
      isLoading.value = false;
      log('ClassesController.archiveClasse - Finalizando archiveClasse. isLoading = false.', name: 'ClassesController');
    }
  }

  Future<void> toggleClasseActiveStatus(Classe classe) async {
    log('ClassesController.toggleClasseActiveStatus - Verificando status da turma para toggle: ID=${classe.id}, Ativa=${classe.active}.', name: 'ClassesController');
    if (classe.active ?? true) {
      log('ClassesController.toggleClasseActiveStatus - Turma está ativa, chamando archiveClasse para desativar.', name: 'ClassesController');
      await archiveClasse(classe);
    } else {
      log('ClassesController.toggleClasseActiveStatus - Turma já está inativa/arquivada. Exibindo mensagem de que não pode ser reativada.', name: 'ClassesController');
      Get.dialog(CustomErrorDialog(title: 'Ação Inválida', message: 'Não é possível reativar uma turma arquivada.'));
      log('ClassesController.toggleClasseActiveStatus - Diálogo de "Ação Inválida" exibido.', name: 'ClassesController');
    }
    log('ClassesController.toggleClasseActiveStatus - Finalizando toggleClasseActiveStatus.', name: 'ClassesController');
  }
}