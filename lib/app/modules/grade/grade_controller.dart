import 'dart:developer'; // Importar o package developer para usar log
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/repositories/grade/grade_repository.dart';
// import 'package:collection/collection.dart';

enum ClasseFilterStatus { active, archived, all }

class GradesController extends GetxController {
  final GradeRepository _gradeRepository = GradeRepository(
    DatabaseHelper.instance,
  );

  final isLoading = false.obs;
  final RxMap<String, List<Grade>> grades = <String, List<Grade>>{}.obs;

  final Rx<Classe?> selectedFilterClasse = Rx<Classe?>(null);
  final Rx<Discipline?> selectedFilterDiscipline = Rx<Discipline?>(null);
  final Rx<int?> selectedFilterDayOfWeek = Rx<int?>(null);
  final RxBool showOnlyActiveGrades = true.obs;

  final RxInt selectedFilterYear = DateTime.now().year.obs;

  final RxList<Classe> availableClasses = <Classe>[].obs;
  final RxList<Discipline> availableDisciplines = <Discipline>[].obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formEditKey = GlobalKey<FormState>();

  final Rx<Classe?> selectedClasseForForm = Rx<Classe?>(null);
  final Rx<Discipline?> selectedDisciplineForForm = Rx<Discipline?>(null);
  final RxInt selectedDayOfWeekForForm = 1.obs;
  final Rx<TimeOfDay> startTimeForForm = TimeOfDay.now().obs;
  final Rx<TimeOfDay> endTimeForForm = TimeOfDay.now().obs;

  final RxInt selectedYearForForm = DateTime.now().year.obs;
  final RxList<Classe> filteredClassesForForm = <Classe>[].obs;

  @override
  void onInit() {
    log('GradesController.onInit - Inicializando controller.', name: 'GradesController');
    loadClassesAndDisciplinesForFilters();
    loadAllGrades();
    loadFilteredClassesForForm(
      selectedYearForForm.value,
    ); 
    super.onInit();
    log('GradesController.onInit - Controller inicializado. Chamadas iniciais concluídas.', name: 'GradesController');
  }

  Future<void> loadAllGrades() async {
    log('GradesController.loadAllGrades - Iniciando carregamento de todos os horários.', name: 'GradesController');
    try {
      isLoading.value = true;
      log('GradesController.loadAllGrades - Chamando repository para obter horários.', name: 'GradesController');
      final fetchedGrades = await _gradeRepository.getAllGrades(
        classeId: selectedFilterClasse.value?.id,
        disciplineId: selectedFilterDiscipline.value?.id,
        dayOfWeek: selectedFilterDayOfWeek.value,
        activeStatus: showOnlyActiveGrades.value,
        year: selectedFilterYear.value,
      );

      log('GradesController.loadAllGrades - ${fetchedGrades.length} horários obtidos. Agrupando por dia da semana.', name: 'GradesController');
      final groupedGrades = <String, List<Grade>>{};
      for (final grade in fetchedGrades) {
        final key = grade.dayOfWeek.toString();
        groupedGrades.putIfAbsent(key, () => []).add(grade);
      }

      groupedGrades.forEach((day, gradeList) {
        gradeList.sort(
          (a, b) => a.startTimeTotalMinutes.compareTo(b.startTimeTotalMinutes),
        );
      });

      grades.assignAll(groupedGrades);
      log('GradesController.loadAllGrades - Horários agrupados e ordenados. Lista de grades atualizada.', name: 'GradesController');
    } catch (e, s) { // Captura o stack trace
      log('GradesController.loadAllGrades - Erro ao carregar horários: $e', name: 'GradesController', error: e, stackTrace: s); // Log com stack trace
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro',
          message: 'Erro ao carregar horários: ${e.toString()}',
        ),
      );
      log('GradesController.loadAllGrades - Diálogo de erro exibido.', name: 'GradesController');
    } finally {
      isLoading.value = false;
      log('GradesController.loadAllGrades - Finalizando loadAllGrades. isLoading = false.', name: 'GradesController');
    }
  }

  Future<void> loadClassesAndDisciplinesForFilters() async {
    log('GradesController.loadClassesAndDisciplinesForFilters - Iniciando carregamento de classes e disciplinas para filtros.', name: 'GradesController');
    try {
      log('GradesController.loadClassesAndDisciplinesForFilters - Chamando repository para obter classes ativas.', name: 'GradesController');
      final classes = await _gradeRepository.getAllActiveClasses();
      availableClasses.assignAll(classes);
      log('GradesController.loadClassesAndDisciplinesForFilters - ${classes.length} classes ativas carregadas.', name: 'GradesController');

      log('GradesController.loadClassesAndDisciplinesForFilters - Chamando repository para obter disciplinas.', name: 'GradesController');
      final disciplines = await _gradeRepository.getAllDisciplines();
      availableDisciplines.assignAll(disciplines);
      log('GradesController.loadClassesAndDisciplinesForFilters - ${disciplines.length} disciplinas carregadas.', name: 'GradesController');
      log('GradesController.loadClassesAndDisciplinesForFilters - Carregamento de filtros concluído com sucesso.', name: 'GradesController');
    } catch (e, s) { // Captura o stack trace
      log('GradesController.loadClassesAndDisciplinesForFilters - Erro ao carregar dados de filtro: $e', name: 'GradesController', error: e, stackTrace: s); // Log com stack trace
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro',
          message: 'Erro ao carregar dados de filtro: ${e.toString()}',
        ),
      );
      log('GradesController.loadClassesAndDisciplinesForFilters - Diálogo de erro exibido.', name: 'GradesController');
    }
  }

  Future<void> loadFilteredClassesForForm(int year) async {
    log('GradesController.loadFilteredClassesForForm - Iniciando carregamento de turmas filtradas para o formulário (Ano: $year).', name: 'GradesController');
    try {
      log('GradesController.loadFilteredClassesForForm - Chamando repository para obter classes ativas para o ano.', name: 'GradesController');
      final classes = await _gradeRepository.getAllActiveClasses(year);
      filteredClassesForForm.assignAll(
        classes.where((c) => c.schoolYear == year).toList(),
      );
      log('GradesController.loadFilteredClassesForForm - ${filteredClassesForForm.length} turmas filtradas para o formulário.', name: 'GradesController');

      if (selectedClasseForForm.value != null &&
          !filteredClassesForForm.contains(selectedClasseForForm.value)) {
        log('GradesController.loadFilteredClassesForForm - Turma selecionada no formulário não está mais disponível no filtro, redefinindo.', name: 'GradesController');
        selectedClasseForForm.value = null;
      }
      if (filteredClassesForForm.length == 1 &&
          selectedClasseForForm.value == null) {
        log('GradesController.loadFilteredClassesForForm - Apenas uma turma disponível no filtro, selecionando automaticamente.', name: 'GradesController');
        selectedClasseForForm.value = filteredClassesForForm.first;
      }
      log('GradesController.loadFilteredClassesForForm - Carregamento de turmas para o formulário concluído com sucesso.', name: 'GradesController');
    } catch (e, s) { // Captura o stack trace
      log('GradesController.loadFilteredClassesForForm - Erro ao carregar turmas para o formulário: $e', name: 'GradesController', error: e, stackTrace: s); // Log com stack trace
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro',
          message: 'Erro ao carregar turmas para o formulário: ${e.toString()}',
        ),
      );
      log('GradesController.loadFilteredClassesForForm - Diálogo de erro exibido.', name: 'GradesController');
    }
  }

  Future<void> createGrade(Grade grade) async {
    log('GradesController.createGrade - Iniciando criação de novo horário.', name: 'GradesController');
    try {
      isLoading.value = true;
      if (selectedClasseForForm.value?.id == null) {
        log('GradesController.createGrade - Erro: Turma não selecionada para o horário.', name: 'GradesController');
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message: 'Selecione uma turma para o horário.',
          ),
        );
        log('GradesController.createGrade - Diálogo de erro exibido (turma não selecionada).', name: 'GradesController');
        return;
      }

      final newGrade = Grade(
        classeId: selectedClasseForForm.value!.id!,
        disciplineId: selectedDisciplineForForm.value?.id,
        dayOfWeek: selectedDayOfWeekForForm.value,
        startTimeTotalMinutes: Grade.timeOfDayToInt(startTimeForForm.value),
        endTimeTotalMinutes: Grade.timeOfDayToInt(endTimeForForm.value),
        gradeYear: selectedYearForForm.value,
      );
      log('GradesController.createGrade - Dados do novo horário: ${newGrade.toMap()}', name: 'GradesController');

      log('GradesController.createGrade - Chamando repository para criar horário.', name: 'GradesController');
      await _gradeRepository.createGrade(newGrade);
      log('GradesController.createGrade - Horário criado com sucesso. Recarregando todos os horários.', name: 'GradesController');
      await loadAllGrades();
      resetAddGradeFields();
      log('GradesController.createGrade - Horário criado, lista recarregada e campos redefinidos com sucesso.', name: 'GradesController');
    } catch (e, s) { // Captura o stack trace
      log('GradesController.createGrade - Erro ao adicionar horário: $e', name: 'GradesController', error: e, stackTrace: s); // Log com stack trace
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro ao Adicionar Horário',
          message: e.toString(),
        ),
      );
      log('GradesController.createGrade - Diálogo de erro exibido.', name: 'GradesController');
    } finally {
      isLoading.value = false;
      log('GradesController.createGrade - Finalizando createGrade. isLoading = false.', name: 'GradesController');
    }
  }

  Future<void> updateGrade(Grade grade) async {
    log('GradesController.updateGrade - Iniciando atualização do horário ID: ${grade.id}.', name: 'GradesController');
    try {
      isLoading.value = true;
      if (grade.id == null) {
        log('GradesController.updateGrade - Erro: ID do horário é nulo para atualização.', name: 'GradesController');
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message: 'ID do horário é nulo. Não foi possível atualizar.',
          ),
        );
        log('GradesController.updateGrade - Diálogo de erro exibido (ID nulo).', name: 'GradesController');
        return;
      }
      if (selectedClasseForForm.value?.id == null) {
        log('GradesController.updateGrade - Erro: Turma não selecionada no formulário de edição.', name: 'GradesController');
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message: 'Selecione uma turma para o horário.',
          ),
        );
        log('GradesController.updateGrade - Diálogo de erro exibido (turma não selecionada).', name: 'GradesController');
        return;
      }

      final updatedGrade = grade.copyWith(
        classeId: selectedClasseForForm.value!.id!,
        disciplineId: selectedDisciplineForForm.value?.id,
        dayOfWeek: selectedDayOfWeekForForm.value,
        startTimeTotalMinutes: Grade.timeOfDayToInt(startTimeForForm.value),
        endTimeTotalMinutes: Grade.timeOfDayToInt(endTimeForForm.value),
      );
      log('GradesController.updateGrade - Dados atualizados do horário: ${updatedGrade.toMap()}', name: 'GradesController');

      log('GradesController.updateGrade - Chamando repository para atualizar horário.', name: 'GradesController');
      await _gradeRepository.updateGrade(updatedGrade);
      log('GradesController.updateGrade - Horário atualizado com sucesso. Recarregando todos os horários.', name: 'GradesController');
      await loadAllGrades();
      resetEditGradeFields();
      log('GradesController.updateGrade - Horário atualizado, lista recarregada e campos redefinidos com sucesso.', name: 'GradesController');
    } catch (e, s) { // Captura o stack trace
      log('GradesController.updateGrade - Erro ao atualizar horário: $e', name: 'GradesController', error: e, stackTrace: s); // Log com stack trace
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro ao Atualizar Horário',
          message: e.toString(),
        ),
      );
      log('GradesController.updateGrade - Diálogo de erro exibido.', name: 'GradesController');
    } finally {
      isLoading.value = false;
      log('GradesController.updateGrade - Finalizando updateGrade. isLoading = false.', name: 'GradesController');
    }
  }

  Future<void> toggleGradeStatus(Grade grade) async {
    log('GradesController.toggleGradeStatus - Iniciando toggle de status para horário ID: ${grade.id}, Ativo: ${grade.active}.', name: 'GradesController');
    try {
      isLoading.value = true;
      if (grade.id == null) {
        log('GradesController.toggleGradeStatus - Erro: ID do horário é nulo para mudar o status.', name: 'GradesController');
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message: 'ID do horário é nulo. Não foi possível mudar o status.',
          ),
        );
        log('GradesController.toggleGradeStatus - Diálogo de erro exibido (ID nulo).', name: 'GradesController');
        return;
      }
      log('GradesController.toggleGradeStatus - Chamando repository para mudar status do horário.', name: 'GradesController');
      await _gradeRepository.toggleGradeActiveStatus(grade);
      log('GradesController.toggleGradeStatus - Status do horário alterado com sucesso. Recarregando todos os horários.', name: 'GradesController');
      await loadAllGrades();
      log('GradesController.toggleGradeStatus - Horários recarregados com sucesso após toggle.', name: 'GradesController');
    } catch (e, s) { // Captura o stack trace
      log('GradesController.toggleGradeStatus - Erro ao mudar status do horário: $e', name: 'GradesController', error: e, stackTrace: s); // Log com stack trace
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro ao Mudar Status do Horário',
          message: e.toString(),
        ),
      );
      log('GradesController.toggleGradeStatus - Diálogo de erro exibido.', name: 'GradesController');
    } finally {
      isLoading.value = false;
      log('GradesController.toggleGradeStatus - Finalizando toggleGradeStatus. isLoading = false.', name: 'GradesController');
    }
  }

  Future<void> resetAddGradeFields() async {
    log('GradesController.resetAddGradeFields - Redefinindo campos para adicionar novo horário.', name: 'GradesController');
    selectedClasseForForm.value = null;
    selectedDisciplineForForm.value = null;
    selectedDayOfWeekForForm.value = 1;
    startTimeForForm.value = TimeOfDay.now();
    endTimeForForm.value = TimeOfDay.now();
    selectedYearForForm.value = DateTime.now().year;
    log('GradesController.resetAddGradeFields - Chamando loadFilteredClassesForForm após redefinição.', name: 'GradesController');
    await loadFilteredClassesForForm(selectedYearForForm.value);
    log('GradesController.resetAddGradeFields - Campos redefinidos e turmas filtradas recarregadas.', name: 'GradesController');
  } 

  Future<void> fillEditGradeFields(Grade grade) async {
    log('GradesController.fillEditGradeFields - Preenchendo campos para edição do horário ID: ${grade.id}.', name: 'GradesController');
    selectedYearForForm.value = grade.classe?.schoolYear ?? DateTime.now().year;
    log('GradesController.fillEditGradeFields - Carregando classes filtradas para o ano ${selectedYearForForm.value}.', name: 'GradesController');
    await loadFilteredClassesForForm(selectedYearForForm.value);
    
    selectedClasseForForm.value = filteredClassesForForm.firstWhereOrNull(
      (c) => c.id == grade.classeId,
    );
    log('GradesController.fillEditGradeFields - Classe para o formulário preenchida: ${selectedClasseForForm.value?.name ?? 'N/A'}.', name: 'GradesController');

    selectedDisciplineForForm.value = availableDisciplines.firstWhereOrNull(
      (d) => d.id == grade.disciplineId,
    );
    log('GradesController.fillEditGradeFields - Disciplina para o formulário preenchida: ${selectedDisciplineForForm.value?.name ?? 'N/A'}.', name: 'GradesController');

    selectedDayOfWeekForForm.value = grade.dayOfWeek;
    startTimeForForm.value = grade.startTimeOfDay;
    endTimeForForm.value = grade.endTimeOfDay;
    log('GradesController.fillEditGradeFields - Dia e horários preenchidos. Preenchimento de edição concluído.', name: 'GradesController');
  }

  void resetEditGradeFields() {
    log('GradesController.resetEditGradeFields - Redefinindo campos de edição do horário.', name: 'GradesController');
    selectedClasseForForm.value = null;
    selectedDisciplineForForm.value = null;
    selectedDayOfWeekForForm.value = 1;
    startTimeForForm.value = TimeOfDay.now();
    endTimeForForm.value = TimeOfDay.now();
    selectedYearForForm.value = DateTime.now().year;
    log('GradesController.resetEditGradeFields - Chamando loadFilteredClassesForForm após redefinição.', name: 'GradesController');
    loadFilteredClassesForForm(selectedYearForForm.value);
    log('GradesController.resetEditGradeFields - Campos redefinidos e turmas filtradas recarregadas.', name: 'GradesController');
  }

  void resetFilterFields() {
    log('GradesController.resetFilterFields - Redefinindo campos de filtro.', name: 'GradesController');
    selectedFilterClasse.value = null;
    selectedFilterDiscipline.value = null;
    selectedFilterDayOfWeek.value = null;
    showOnlyActiveGrades.value = true;
    selectedFilterYear.value = DateTime.now().year;
    log('GradesController.resetFilterFields - Campos de filtro redefinidos.', name: 'GradesController');
  }
}