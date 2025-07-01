import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/homework.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/repositories/homework/homework_repository.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'dart:developer';

class HomeworkController extends GetxController {
  final HomeworkRepository _homeworkRepository = HomeworkRepository(
    DatabaseHelper.instance,
  );

  final Classe currentClasse = Get.arguments as Classe;

  final isLoading = false.obs;
  final homeworks = <Homework>[].obs;
  final availableDisciplines = <Discipline>[].obs;

  final titleEC = TextEditingController();
  final descriptionEC = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final selectedDiscipline = Rx<Discipline?>(null);
  final selectedDueDate = Rx<DateTime?>(null);
  final selectedStatus = Rx<HomeworkStatus>(HomeworkStatus.pending);

  final filterStatus = Rx<HomeworkStatus?>(null);
  final showOverdueOnly = false.obs;
  final showTodayOnly = false.obs;
  final showUpcomingOnly = false.obs;

  @override
  void onInit() {
    log('HomeworkController.onInit - Inicializando controller para turma: ${currentClasse.name}', name: 'HomeworkController');
    loadHomeworks();
    loadAvailableDisciplines();
    super.onInit();
  }

  @override
  void onClose() {
    log('HomeworkController.onClose - Limpando recursos do controller', name: 'HomeworkController');
    titleEC.dispose();
    descriptionEC.dispose();
    super.onClose();
  }

  Future<void> loadHomeworks() async {
    log('HomeworkController.loadHomeworks - Iniciando carregamento de tarefas', name: 'HomeworkController');
    
    try {
      isLoading.value = true;
      List<Homework> fetchedHomeworks;

      if (showOverdueOnly.value) {
        log('HomeworkController.loadHomeworks - Carregando apenas tarefas em atraso', name: 'HomeworkController');
        fetchedHomeworks = await _homeworkRepository.getOverdueHomeworks(classeId: currentClasse.id);
      } else if (showTodayOnly.value) {
        log('HomeworkController.loadHomeworks - Carregando apenas tarefas de hoje', name: 'HomeworkController');
        fetchedHomeworks = await _homeworkRepository.getTodayHomeworks(classeId: currentClasse.id);
      } else if (showUpcomingOnly.value) {
        log('HomeworkController.loadHomeworks - Carregando apenas tarefas próximas', name: 'HomeworkController');
        fetchedHomeworks = await _homeworkRepository.getUpcomingHomeworks(classeId: currentClasse.id);
      } else if (filterStatus.value != null) {
        log('HomeworkController.loadHomeworks - Carregando tarefas filtradas por status: ${filterStatus.value!.name}', name: 'HomeworkController');
        fetchedHomeworks = await _homeworkRepository.getHomeworksByStatus(filterStatus.value!, classeId: currentClasse.id);
      } else {
        log('HomeworkController.loadHomeworks - Carregando todas as tarefas da turma', name: 'HomeworkController');
        fetchedHomeworks = await _homeworkRepository.getHomeworksByClasseId(currentClasse.id!);
      }

      homeworks.assignAll(fetchedHomeworks);
      log('HomeworkController.loadHomeworks - Tarefas carregadas com sucesso. Total: ${fetchedHomeworks.length}', name: 'HomeworkController');
    } catch (e, s) {
      log('HomeworkController.loadHomeworks - Erro ao carregar tarefas: $e', name: 'HomeworkController', error: e, stackTrace: s);
      Get.dialog(CustomErrorDialog(
        title: 'Erro ao Carregar Tarefas',
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAvailableDisciplines() async {
    log('HomeworkController.loadAvailableDisciplines - Iniciando carregamento de disciplinas disponíveis', name: 'HomeworkController');
    
    try {
      final disciplines = await _homeworkRepository.getAvailableDisciplines(classeId: currentClasse.id);
      availableDisciplines.assignAll(disciplines);
      log('HomeworkController.loadAvailableDisciplines - Disciplinas carregadas com sucesso. Total: ${disciplines.length}', name: 'HomeworkController');
    } catch (e, s) {
      log('HomeworkController.loadAvailableDisciplines - Erro ao carregar disciplinas: $e', name: 'HomeworkController', error: e, stackTrace: s);
      Get.dialog(CustomErrorDialog(
        title: 'Erro ao Carregar Disciplinas',
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createHomework() async {
    if (!formKey.currentState!.validate()) {
      log('HomeworkController.createHomework - Validação do formulário falhou', name: 'HomeworkController');
      return;
    }

    if (selectedDueDate.value == null) {
      log('HomeworkController.createHomework - Data de entrega não selecionada', name: 'HomeworkController');
      Get.dialog(CustomErrorDialog(
        title: 'Data de Entrega',
        message: 'Selecione uma data de entrega para a tarefa.',
      ));
      return;
    }

    if (currentClasse.id == null) {
      log('HomeworkController.createHomework - ID da turma atual é nulo', name: 'HomeworkController');
      Get.dialog(CustomErrorDialog(
        title: 'Erro',
        message: 'ID da turma atual é nulo. Não foi possível criar tarefa.',
      ));
      return;
    }

    log('HomeworkController.createHomework - Iniciando criação de tarefa: ${titleEC.text}', name: 'HomeworkController');

    try {
      isLoading.value = true;

      final homework = Homework(
        classeId: currentClasse.id!,
        disciplineId: selectedDiscipline.value?.id,
        title: titleEC.text.trim(),
        description: descriptionEC.text.trim().isEmpty ? null : descriptionEC.text.trim(),
        dueDate: selectedDueDate.value!,
        assignedDate: DateTime.now(),
        status: selectedStatus.value,
      );

      await _homeworkRepository.createHomework(homework);
      log('HomeworkController.createHomework - Tarefa criada com sucesso', name: 'HomeworkController');
      
      await loadHomeworks();
      clearForm();
      Get.back();
      
      Get.snackbar(
        'Sucesso',
        'Tarefa criada com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, s) {
      log('HomeworkController.createHomework - Erro ao criar tarefa: $e', name: 'HomeworkController', error: e, stackTrace: s);
      Get.dialog(CustomErrorDialog(
        title: 'Erro ao Criar Tarefa',
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateHomework(Homework homework) async {
    log('HomeworkController.updateHomework - Iniciando atualização de tarefa ID: ${homework.id}', name: 'HomeworkController');

    try {
      isLoading.value = true;
      await _homeworkRepository.updateHomework(homework);
      log('HomeworkController.updateHomework - Tarefa atualizada com sucesso', name: 'HomeworkController');
      
      await loadHomeworks();
      
      Get.snackbar(
        'Sucesso',
        'Tarefa atualizada com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, s) {
      log('HomeworkController.updateHomework - Erro ao atualizar tarefa: $e', name: 'HomeworkController', error: e, stackTrace: s);
      Get.dialog(CustomErrorDialog(
        title: 'Erro ao Atualizar Tarefa',
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteHomework(Homework homework) async {
    if (homework.id == null) {
      log('HomeworkController.deleteHomework - ID da tarefa é nulo', name: 'HomeworkController');
      Get.dialog(CustomErrorDialog(
        title: 'Erro',
        message: 'ID da tarefa é nulo. Não foi possível excluir.',
      ));
      return;
    }

    log('HomeworkController.deleteHomework - Iniciando exclusão de tarefa ID: ${homework.id}', name: 'HomeworkController');

    try {
      isLoading.value = true;
      await _homeworkRepository.deleteHomework(homework.id!);
      log('HomeworkController.deleteHomework - Tarefa excluída com sucesso', name: 'HomeworkController');
      
      await loadHomeworks();
      
      Get.snackbar(
        'Sucesso',
        'Tarefa excluída com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, s) {
      log('HomeworkController.deleteHomework - Erro ao excluir tarefa: $e', name: 'HomeworkController', error: e, stackTrace: s);
      Get.dialog(CustomErrorDialog(
        title: 'Erro ao Excluir Tarefa',
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsCompleted(Homework homework) async {
    log('HomeworkController.markAsCompleted - Marcando tarefa como concluída ID: ${homework.id}', name: 'HomeworkController');
    
    final updatedHomework = homework.copyWith(status: HomeworkStatus.completed);
    await updateHomework(updatedHomework);
  }

  Future<void> markAsPending(Homework homework) async {
    log('HomeworkController.markAsPending - Marcando tarefa como pendente ID: ${homework.id}', name: 'HomeworkController');
    
    final updatedHomework = homework.copyWith(status: HomeworkStatus.pending);
    await updateHomework(updatedHomework);
  }

  Future<void> markAsCancelled(Homework homework) async {
    log('HomeworkController.markAsCancelled - Marcando tarefa como cancelada ID: ${homework.id}', name: 'HomeworkController');
    
    final updatedHomework = homework.copyWith(status: HomeworkStatus.cancelled);
    await updateHomework(updatedHomework);
  }

  void setFilterStatus(HomeworkStatus? status) {
    log('HomeworkController.setFilterStatus - Alterando filtro de status para: ${status?.name ?? "todos"}', name: 'HomeworkController');
    
    filterStatus.value = status;
    showOverdueOnly.value = false;
    showTodayOnly.value = false;
    showUpcomingOnly.value = false;
    loadHomeworks();
  }

  void setFilterOverdue(bool value) {
    log('HomeworkController.setFilterOverdue - Alterando filtro de atraso para: $value', name: 'HomeworkController');
    
    showOverdueOnly.value = value;
    if (value) {
      filterStatus.value = null;
      showTodayOnly.value = false;
      showUpcomingOnly.value = false;
    }
    loadHomeworks();
  }

  void setFilterToday(bool value) {
    log('HomeworkController.setFilterToday - Alterando filtro de hoje para: $value', name: 'HomeworkController');
    
    showTodayOnly.value = value;
    if (value) {
      filterStatus.value = null;
      showOverdueOnly.value = false;
      showUpcomingOnly.value = false;
    }
    loadHomeworks();
  }

  void setFilterUpcoming(bool value) {
    log('HomeworkController.setFilterUpcoming - Alterando filtro de próximas para: $value', name: 'HomeworkController');
    
    showUpcomingOnly.value = value;
    if (value) {
      filterStatus.value = null;
      showOverdueOnly.value = false;
      showTodayOnly.value = false;
    }
    loadHomeworks();
  }

  void clearAllFilters() {
    log('HomeworkController.clearAllFilters - Limpando todos os filtros', name: 'HomeworkController');
    
    filterStatus.value = null;
    showOverdueOnly.value = false;
    showTodayOnly.value = false;
    showUpcomingOnly.value = false;
    loadHomeworks();
  }

  void prepareEditHomework(Homework homework) {
    log('HomeworkController.prepareEditHomework - Preparando edição de tarefa ID: ${homework.id}', name: 'HomeworkController');
    
    titleEC.text = homework.title;
    descriptionEC.text = homework.description ?? '';
    selectedDiscipline.value = homework.discipline;
    selectedDueDate.value = homework.dueDate;
    selectedStatus.value = homework.status;
  }

  void clearForm() {
    log('HomeworkController.clearForm - Limpando formulário', name: 'HomeworkController');
    
    titleEC.clear();
    descriptionEC.clear();
    selectedDiscipline.value = null;
    selectedDueDate.value = null;
    selectedStatus.value = HomeworkStatus.pending;
  }

  String getStatusDisplayName(HomeworkStatus status) {
    switch (status) {
      case HomeworkStatus.pending:
        return 'Pendente';
      case HomeworkStatus.completed:
        return 'Concluída';
      case HomeworkStatus.cancelled:
        return 'Cancelada';
    }
  }

  Color getStatusColor(HomeworkStatus status) {
    switch (status) {
      case HomeworkStatus.pending:
        return Colors.orange;
      case HomeworkStatus.completed:
        return Colors.green;
      case HomeworkStatus.cancelled:
        return Colors.red;
    }
  }

  bool isOverdue(Homework homework) {
    if (homework.status != HomeworkStatus.pending) return false;
    final today = DateTime.now();
    final dueDate = DateTime(homework.dueDate.year, homework.dueDate.month, homework.dueDate.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    return dueDate.isBefore(todayDate);
  }

  bool isDueToday(Homework homework) {
    final today = DateTime.now();
    final dueDate = homework.dueDate;
    return today.year == dueDate.year && 
           today.month == dueDate.month && 
           today.day == dueDate.day;
  }

  String formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDate = DateTime(date.year, date.month, date.day);

    if (dueDate == today) {
      return 'Hoje';
    } else if (dueDate == tomorrow) {
      return 'Amanhã';
    } else if (dueDate.isBefore(today)) {
      final difference = today.difference(dueDate).inDays;
      return 'Atrasado há $difference dia(s)';
    } else {
      final difference = dueDate.difference(today).inDays;
      return 'Em $difference dia(s)';
    }
  }
}
