import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/schedule.dart';
import 'package:vocatus/app/repositories/schedule/schedule_repository.dart';


enum ClasseFilterStatus { active, archived, all }

class ScheduleController extends GetxController {
  final ScheduleRepository _scheduleRepository = ScheduleRepository(
    DatabaseHelper.instance,
  );

  final isLoading = false.obs;
  final RxMap<String, List<Schedule>> schedules = <String, List<Schedule>>{}.obs;

  final Rx<Classe?> selectedFilterClasse = Rx<Classe?>(null);
  final Rx<Discipline?> selectedFilterDiscipline = Rx<Discipline?>(null);
  final Rx<int?> selectedFilterDayOfWeek = Rx<int?>(null);
  final RxBool showOnlyActiveSchedules = true.obs;

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
    loadAllSchedules();
    loadFilteredClassesForForm(
      selectedYearForForm.value,
    ); 
    super.onInit();
  }

  Future<void> loadAllSchedules() async {
    try {
      isLoading.value = true;
      final fetchedSchedules = await _scheduleRepository.getAllSchedules(
        classeId: selectedFilterClasse.value?.id,
        disciplineId: selectedFilterDiscipline.value?.id,
        dayOfWeek: selectedFilterDayOfWeek.value,
        activeStatus: showOnlyActiveSchedules.value,
        year: selectedFilterYear.value,
      );

      final groupedSchedules = <String, List<Schedule>>{};
      for (final schedule in fetchedSchedules) {
        final key = schedule.dayOfWeek.toString();
        groupedSchedules.putIfAbsent(key, () => []).add(schedule);
      }

      groupedSchedules.forEach((day, scheduleList) {
        scheduleList.sort(
          (a, b) => a.startTimeTotalMinutes.compareTo(b.startTimeTotalMinutes),
        );
      });

      schedules.assignAll(groupedSchedules);
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
      final classes = await _scheduleRepository.getAllActiveClasses();
      availableClasses.assignAll(classes);

      final disciplines = await _scheduleRepository.getAllDisciplines();
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
      final classes = await _scheduleRepository.getAllActiveClasses(year);
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

  Future<void> createSchedule(Schedule schedule) async {
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

      final newSchedule = Schedule(
        classeId: selectedClasseForForm.value!.id!,
        disciplineId: selectedDisciplineForForm.value?.id,
        dayOfWeek: selectedDayOfWeekForForm.value,
        startTimeTotalMinutes: Schedule.timeOfDayToInt(startTimeForForm.value),
        endTimeTotalMinutes: Schedule.timeOfDayToInt(endTimeForForm.value),
        scheduleYear: selectedYearForForm.value,
      );

      await _scheduleRepository.createSchedule(newSchedule);
      await loadAllSchedules();
      resetAddScheduleFields();
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

  Future<void> updateSchedule(Schedule schedule) async {
    try {
      isLoading.value = true;
      if (schedule.id == null) {
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

      final updatedSchedule = schedule.copyWith(
        classeId: selectedClasseForForm.value!.id!,
        disciplineId: selectedDisciplineForForm.value?.id,
        dayOfWeek: selectedDayOfWeekForForm.value,
        startTimeTotalMinutes: Schedule.timeOfDayToInt(startTimeForForm.value),
        endTimeTotalMinutes: Schedule.timeOfDayToInt(endTimeForForm.value),
      );

      await _scheduleRepository.updateSchedule(updatedSchedule);
      await loadAllSchedules();
      resetEditScheduleFields();
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

  Future<void> toggleScheduleStatus(Schedule schedule) async {
    try {
      isLoading.value = true;
      if (schedule.id == null) {
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message: 'ID do horário é nulo. Não foi possível mudar o status.',
          ),
        );
        return;
      }
      await _scheduleRepository.toggleScheduleActiveStatus(schedule);
      await loadAllSchedules();
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

  Future<void> resetAddScheduleFields() async {
    selectedClasseForForm.value = null;
    selectedDisciplineForForm.value = null;
    selectedDayOfWeekForForm.value = 1;
    startTimeForForm.value = TimeOfDay.now();
    endTimeForForm.value = TimeOfDay.now();
    selectedYearForForm.value = DateTime.now().year;
    await loadFilteredClassesForForm(selectedYearForForm.value);
  } 

  Future<void> fillEditScheduleFields(Schedule schedule) async {
    selectedYearForForm.value = schedule.classe?.schoolYear ?? DateTime.now().year;
    await loadFilteredClassesForForm(selectedYearForForm.value);
    
    selectedClasseForForm.value = filteredClassesForForm.firstWhereOrNull(
      (c) => c.id == schedule.classeId,
    );

    selectedDisciplineForForm.value = availableDisciplines.firstWhereOrNull(
      (d) => d.id == schedule.disciplineId,
    );

    selectedDayOfWeekForForm.value = schedule.dayOfWeek;
    startTimeForForm.value = schedule.startTimeOfDay;
    endTimeForForm.value = schedule.endTimeOfDay;
  }

  void resetEditScheduleFields() {
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
    showOnlyActiveSchedules.value = true;
    selectedFilterYear.value = DateTime.now().year;
  }
}