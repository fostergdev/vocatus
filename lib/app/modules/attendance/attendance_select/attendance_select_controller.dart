import 'dart:developer'; // Importar para usar log
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/repositories/attendance/attendance_select/attendance_select_repository.dart';

class AttendanceSelectController extends GetxController {
  final AttendanceSelectRepository _attendanceSelectRepository =
      AttendanceSelectRepository(DatabaseHelper.instance);

  final isLoading = false.obs;
  final RxMap<String, List<Grade>> availableGrades =
      <String, List<Grade>>{}.obs;

  final RxMap<int, bool> gradeAttendanceStatus = <int, bool>{}.obs;

  final Rx<DateTime> selectedPickerDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).obs;

  Rx<DateTime> get currentWeekStartDate =>
      _getMondayOfThisWeek(selectedPickerDate.value).obs;

  @override
  void onInit() {
    log('AttendanceSelectController.onInit - Inicializando controller.', name: 'AttendanceSelectController');
    loadAvailableGrades();
    super.onInit();
    log('AttendanceSelectController.onInit - Controller inicializado. Chamada inicial a loadAvailableGrades.', name: 'AttendanceSelectController');
  }

  Future<void> loadAvailableGrades() async {
    log('AttendanceSelectController.loadAvailableGrades - Iniciando carregamento de horários disponíveis para seleção.', name: 'AttendanceSelectController');
    try {
      isLoading.value = true;
      gradeAttendanceStatus.clear();
      log('AttendanceSelectController.loadAvailableGrades - Status de carregamento ativado e status de presença de horários limpo.', name: 'AttendanceSelectController');

      int yearForFilter = selectedPickerDate.value.year;
      final DateTime weekStartDate = _getMondayOfThisWeek(selectedPickerDate.value);
      log('AttendanceSelectController.loadAvailableGrades - Ano para filtro: $yearForFilter, Início da semana: $weekStartDate.', name: 'AttendanceSelectController');

      log('AttendanceSelectController.loadAvailableGrades - Chamando repository para obter todos os horários para seleção.', name: 'AttendanceSelectController');
      final fetchedGrades = await _attendanceSelectRepository
          .getAllGradesForSelection(year: yearForFilter, activeStatus: true);
      log('AttendanceSelectController.loadAvailableGrades - ${fetchedGrades.length} horários obtidos do repository.', name: 'AttendanceSelectController');

      final groupedGrades = <String, List<Grade>>{};
      log('AttendanceSelectController.loadAvailableGrades - Verificando status de presença e agrupando horários por dia da semana.', name: 'AttendanceSelectController');
      for (final gradeItem in fetchedGrades) {
        bool attendanceExistsInThisWeek = false;

        // Verificando presença para cada dia da semana (Segunda a Sexta)
        for (int i = 0; i < 5; i++) {
          final DateTime specificDayInWeek = weekStartDate.add(Duration(days: i));
          // Verifica se o dia da semana do gradeItem corresponde ao dia específico da semana
          // E também se o dia da semana atual não é Sábado (6) ou Domingo (7 ou 0)
          if (gradeItem.dayOfWeek == specificDayInWeek.weekday && specificDayInWeek.weekday >= 1 && specificDayInWeek.weekday <= 5) {
             log('AttendanceSelectController.loadAvailableGrades - Verificando presença para o horário ID: ${gradeItem.id} no dia: ${specificDayInWeek.toIso8601String().substring(0,10)}', name: 'AttendanceSelectController');
            final bool attendanceOnSpecificDay = await _attendanceSelectRepository
                .hasAttendanceForGradeAndDate(
                  gradeItem.id!,
                  specificDayInWeek,
                );
            if (attendanceOnSpecificDay) {
              attendanceExistsInThisWeek = true;
              log('AttendanceSelectController.loadAvailableGrades - Presença encontrada para o horário ID: ${gradeItem.id} no dia ${specificDayInWeek.weekday}.', name: 'AttendanceSelectController');
              break; // Se já encontrou uma presença na semana, não precisa verificar os outros dias para este horário
            }
          }
        }
        gradeAttendanceStatus[gradeItem.id!] = attendanceExistsInThisWeek;
        
        final key = gradeItem.dayOfWeek.toString();
        groupedGrades.putIfAbsent(key, () => []).add(gradeItem);
      }
      log('AttendanceSelectController.loadAvailableGrades - Status de presença de todos os horários verificado.', name: 'AttendanceSelectController');

      log('AttendanceSelectController.loadAvailableGrades - Ordenando horários dentro de cada dia.', name: 'AttendanceSelectController');
      groupedGrades.forEach((day, gradeList) {
        gradeList.sort(
          (a, b) => a.startTimeTotalMinutes.compareTo(b.startTimeTotalMinutes),
        );
      });

      availableGrades.assignAll(groupedGrades);
      log('AttendanceSelectController.loadAvailableGrades - Horários disponíveis atualizados com sucesso.', name: 'AttendanceSelectController');
    } catch (e, s) { // Captura o stack trace
      log('AttendanceSelectController.loadAvailableGrades - Erro ao carregar horários para chamada: $e', name: 'AttendanceSelectController', error: e, stackTrace: s); // Loga com stack trace
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro',
          message: 'Erro ao carregar horários para chamada: ${e.toString()}',
        ),
      );
      log('AttendanceSelectController.loadAvailableGrades - Diálogo de erro exibido.', name: 'AttendanceSelectController');
    } finally {
      isLoading.value = false;
      log('AttendanceSelectController.loadAvailableGrades - Finalizando loadAvailableGrades. isLoading = false.', name: 'AttendanceSelectController');
    }
  }

  // Já possui logs implícitos através do loadAvailableGrades()
  void updateSelectedDate(DateTime date) {
    log('AttendanceSelectController.updateSelectedDate - Data selecionada alterada para: ${date.toIso8601String().substring(0,10)}.', name: 'AttendanceSelectController');
    selectedPickerDate.value = DateTime(date.year, date.month, date.day);
    loadAvailableGrades();
    log('AttendanceSelectController.updateSelectedDate - Chamou loadAvailableGrades para a nova data.', name: 'AttendanceSelectController');
  }

  void goToPreviousWeek() {
    log('AttendanceSelectController.goToPreviousWeek - Navegando para a semana anterior.', name: 'AttendanceSelectController');
    selectedPickerDate.value = DateTime(
      currentWeekStartDate.value.year,
      currentWeekStartDate.value.month,
      currentWeekStartDate.value.day,
    ).subtract(const Duration(days: 7));
    loadAvailableGrades();
    log('AttendanceSelectController.goToPreviousWeek - Chamou loadAvailableGrades para a semana anterior.', name: 'AttendanceSelectController');
  }

  Future<void> goToNextWeek() async { // Retorna Future<void> pois await é usado
    log('AttendanceSelectController.goToNextWeek - Navegando para a próxima semana.', name: 'AttendanceSelectController');
    selectedPickerDate.value = DateTime(
      currentWeekStartDate.value.year,
      currentWeekStartDate.value.month,
      currentWeekStartDate.value.day,
    ).add(const Duration(days: 7));
    await loadAvailableGrades(); // <--- Usando await aqui
    log('AttendanceSelectController.goToNextWeek - Chamou loadAvailableGrades para a próxima semana.', name: 'AttendanceSelectController');
  }

  static DateTime _getMondayOfThisWeek(DateTime date) {
    // log('AttendanceSelectController._getMondayOfThisWeek - Calculando segunda-feira da semana para a data: ${date.toIso8601String().substring(0,10)}.', name: 'AttendanceSelectController'); // Demasiado verboso para loop
    int daysToSubtract = date.weekday - 1; // 1 = Monday, 7 = Sunday
    // if date.weekday is 0 (Sunday), daysToSubtract will be -1.
    // In Dart, weekday for Sunday is 7, not 0. So no change needed for Sunday.
    // If your Date object's weekday for Sunday is 0, then:
    // if (date.weekday == 0) daysToSubtract = 6; else daysToSubtract = date.weekday - 1;
    // Assuming 1-7 (Monday-Sunday) mapping from DateTime.weekday
    if (daysToSubtract < 0) { // Should not happen if weekday is 1-7, but as a safeguard.
       daysToSubtract = 0; // If somehow it's before Monday, stay on current day
    }
    final monday = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: daysToSubtract));
    // log('AttendanceSelectController._getMondayOfThisWeek - Segunda-feira da semana: ${monday.toIso8601String().substring(0,10)}.', name: 'AttendanceSelectController'); // Demasiado verboso para loop
    return monday;
  }
  
  // Getter para selectedFilterYear
  // Não precisa de logs, pois é apenas um getter
  int get selectedFilterYear => currentWeekStartDate.value.year;

  // Getter para currentWeekEndDate
  // Não precisa de logs, pois é apenas um getter
  DateTime get currentWeekEndDate {
    final endDate = currentWeekStartDate.value.add(const Duration(days: 4)); // Adiciona 4 dias para chegar à sexta-feira (Segunda + 4 = Sexta)
    return DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );
  }
}