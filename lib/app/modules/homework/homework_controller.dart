import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/homework.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/repositories/homework/homework_repository.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';

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
    loadHomeworks();
    loadAvailableDisciplines();
    super.onInit();
  }

  @override
  void onClose() {
    titleEC.dispose();
    descriptionEC.dispose();
    super.onClose();
  }

  Future<void> loadHomeworks() async {
    try {
      isLoading.value = true;
      List<Homework> fetchedHomeworks;

      if (showOverdueOnly.value) {
        fetchedHomeworks = await _homeworkRepository.getOverdueHomeworks(classeId: currentClasse.id);
      } else if (showTodayOnly.value) {
        fetchedHomeworks = await _homeworkRepository.getTodayHomeworks(classeId: currentClasse.id);
      } else if (showUpcomingOnly.value) {
        fetchedHomeworks = await _homeworkRepository.getUpcomingHomeworks(classeId: currentClasse.id);
      } else if (filterStatus.value != null) {
        fetchedHomeworks = await _homeworkRepository.getHomeworksByStatus(filterStatus.value!, classeId: currentClasse.id);
      } else {
        fetchedHomeworks = await _homeworkRepository.getHomeworksByClasseId(currentClasse.id!);
      }

      homeworks.assignAll(fetchedHomeworks);
    } catch (e, s) {
      Get.dialog(CustomErrorDialog(
        title: 'Erro ao Carregar Tarefas',
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAvailableDisciplines() async {
    try {
      final disciplines = await _homeworkRepository.getAvailableDisciplines(classeId: currentClasse.id);
      availableDisciplines.assignAll(disciplines);
    } catch (e, s) {
      Get.dialog(CustomErrorDialog(
        title: 'Erro ao Carregar Disciplinas',
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> createHomework() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDueDate.value == null) {
      Get.dialog(CustomErrorDialog(
        title: 'Data de Entrega',
        message: 'Selecione uma data de entrega para a tarefa.',
      ));
      return;
    }

    if (currentClasse.id == null) {
      Get.dialog(CustomErrorDialog(
        title: 'Erro',
        message: 'ID da turma atual é nulo. Não foi possível criar tarefa.',
      ));
      return;
    }

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
      Get.dialog(CustomErrorDialog(
        title: 'Erro ao Criar Tarefa',
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateHomework(Homework homework) async {
    try {
      isLoading.value = true;
      await _homeworkRepository.updateHomework(homework);
      
      await loadHomeworks();
      
      Get.snackbar(
        'Sucesso',
        'Tarefa atualizada com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, s) {
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
      Get.dialog(CustomErrorDialog(
        title: 'Erro',
        message: 'ID da tarefa é nulo. Não foi possível excluir.',
      ));
      return;
    }

    try {
      isLoading.value = true;
      await _homeworkRepository.deleteHomework(homework.id!);
      
      await loadHomeworks();
      
      Get.snackbar(
        'Sucesso',
        'Tarefa excluída com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e, s) {
      Get.dialog(CustomErrorDialog(
        title: 'Erro ao Excluir Tarefa',
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsCompleted(Homework homework) async {
    final updatedHomework = homework.copyWith(status: HomeworkStatus.completed);
    await updateHomework(updatedHomework);
  }

  Future<void> markAsPending(Homework homework) async {
    final updatedHomework = homework.copyWith(status: HomeworkStatus.pending);
    await updateHomework(updatedHomework);
  }

  Future<void> markAsCancelled(Homework homework) async {
    final updatedHomework = homework.copyWith(status: HomeworkStatus.cancelled);
    await updateHomework(updatedHomework);
  }

  void setFilterStatus(HomeworkStatus? status) {
    filterStatus.value = status;
    showOverdueOnly.value = false;
    showTodayOnly.value = false;
    showUpcomingOnly.value = false;
    loadHomeworks();
  }

  void setFilterOverdue(bool value) {
    showOverdueOnly.value = value;
    if (value) {
      filterStatus.value = null;
      showTodayOnly.value = false;
      showUpcomingOnly.value = false;
    }
    loadHomeworks();
  }

  void setFilterToday(bool value) {
    showTodayOnly.value = value;
    if (value) {
      filterStatus.value = null;
      showOverdueOnly.value = false;
      showUpcomingOnly.value = false;
    }
    loadHomeworks();
  }

  void setFilterUpcoming(bool value) {
    showUpcomingOnly.value = value;
    if (value) {
      filterStatus.value = null;
      showOverdueOnly.value = false;
      showTodayOnly.value = false;
    }
    loadHomeworks();
  }

  void clearAllFilters() {
    filterStatus.value = null;
    showOverdueOnly.value = false;
    showTodayOnly.value = false;
    showUpcomingOnly.value = false;
    loadHomeworks();
  }

  void prepareEditHomework(Homework homework) {
    titleEC.text = homework.title;
    descriptionEC.text = homework.description ?? '';
    selectedDiscipline.value = homework.discipline;
    selectedDueDate.value = homework.dueDate;
    selectedStatus.value = homework.status;
  }

  void clearForm() {
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
