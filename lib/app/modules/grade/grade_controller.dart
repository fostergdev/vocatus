import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/repositories/grade/grade_repository.dart';

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
    loadClassesAndDisciplinesForFilters();
    loadAllGrades();
    loadFilteredClassesForForm(selectedYearForForm.value);
    super.onInit();
  }

  Future<void> loadAllGrades() async {
    try {
      isLoading.value = true;
      final fetchedGrades = await _gradeRepository.getAllGrades(
        classeId: selectedFilterClasse.value?.id,
        disciplineId: selectedFilterDiscipline.value?.id,
        dayOfWeek: selectedFilterDayOfWeek.value,
        activeStatus: showOnlyActiveGrades.value,
        year: selectedFilterYear.value,
      );

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
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro',
          message: 'Erro ao carregar horários: ${e.toString()}',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadClassesAndDisciplinesForFilters() async {
    try {
      final classes = await _gradeRepository.getAllActiveClasses();
      availableClasses.assignAll(classes);
      final disciplines = await _gradeRepository.getAllDisciplines();
      availableDisciplines.assignAll(disciplines);
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro',
          message: 'Erro ao carregar dados de filtro: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadFilteredClassesForForm(int year) async {
    try {
      final classes = await _gradeRepository.getAllActiveClasses(year);
      filteredClassesForForm.assignAll(
        classes.where((c) => c.schoolYear == year).toList(),
      );
      if (selectedClasseForForm.value != null &&
          !filteredClassesForForm.contains(selectedClasseForForm.value)) {
        selectedClasseForForm.value = null;
      }
      if (filteredClassesForForm.length == 1 &&
          selectedClasseForForm.value == null) {
        selectedClasseForForm.value = filteredClassesForForm.first;
      }
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro',
          message: 'Erro ao carregar turmas para o formulário: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> createGrade(Grade grade) async {
    try {
      isLoading.value = true;
      if (selectedClasseForForm.value?.id == null) {
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message: 'Selecione uma turma para o horário.',
          ),
        );
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

      await _gradeRepository.createGrade(newGrade);
      await loadAllGrades();
      resetAddGradeFields();
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro ao Adicionar Horário',
          message: e.toString(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGrade(Grade grade) async {
    try {
      isLoading.value = true;
      if (grade.id == null) {
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message: 'ID do horário é nulo. Não foi possível atualizar.',
          ),
        );
        return;
      }
      if (selectedClasseForForm.value?.id == null) {
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message: 'Selecione uma turma para o horário.',
          ),
        );
        return;
      }

      final updatedGrade = grade.copyWith(
        classeId: selectedClasseForForm.value!.id!,
        disciplineId: selectedDisciplineForForm.value?.id,
        dayOfWeek: selectedDayOfWeekForForm.value,
        startTimeTotalMinutes: Grade.timeOfDayToInt(startTimeForForm.value),
        endTimeTotalMinutes: Grade.timeOfDayToInt(endTimeForForm.value),
      );

      await _gradeRepository.updateGrade(updatedGrade);
      await loadAllGrades();
      resetEditGradeFields();
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro ao Atualizar Horário',
          message: e.toString(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleGradeStatus(Grade grade) async {
    try {
      isLoading.value = true;
      if (grade.id == null) {
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message: 'ID do horário é nulo. Não foi possível mudar o status.',
          ),
        );
        return;
      }
      await _gradeRepository.toggleGradeActiveStatus(grade);
      await loadAllGrades();
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro ao Mudar Status do Horário',
          message: e.toString(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetAddGradeFields() {
    selectedClasseForForm.value = null;
    selectedDisciplineForForm.value = null;
    selectedDayOfWeekForForm.value = 1;
    startTimeForForm.value = TimeOfDay.now();
    endTimeForForm.value = TimeOfDay.now();
    selectedYearForForm.value = DateTime.now().year;
    loadFilteredClassesForForm(selectedYearForForm.value);
  }

  // No GradesController
  Future<void> fillEditGradeFields(Grade grade) async {
    selectedYearForForm.value = grade.classe?.schoolYear ?? DateTime.now().year;
    await loadFilteredClassesForForm(selectedYearForForm.value);
    selectedClasseForForm.value = filteredClassesForForm.firstWhereOrNull(
      (c) => c.id == grade.classeId,
    );
    selectedDisciplineForForm.value = availableDisciplines.firstWhereOrNull(
      (d) => d.id == grade.disciplineId,
    );
    selectedDayOfWeekForForm.value = grade.dayOfWeek;
    startTimeForForm.value = grade.startTimeOfDay;
    endTimeForForm.value = grade.endTimeOfDay;
  }

  void resetEditGradeFields() {
    selectedClasseForForm.value = null;
    selectedDisciplineForForm.value = null;
    selectedDayOfWeekForForm.value = 1;
    startTimeForForm.value = TimeOfDay.now();
    endTimeForForm.value = TimeOfDay.now();
    selectedYearForForm.value = DateTime.now().year;
    loadFilteredClassesForForm(selectedYearForForm.value);
  }

  void resetFilterFields() {
    selectedFilterClasse.value = null;
    selectedFilterDiscipline.value = null;
    selectedFilterDayOfWeek.value = null;
    showOnlyActiveGrades.value = true;
    selectedFilterYear.value = DateTime.now().year;
  }
}
