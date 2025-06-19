import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/repositories/attendance/attendance_select/attendance_select_repository.dart';





class AttendanceSelectController extends GetxController {
  final AttendanceSelectRepository _attendanceSelectRepository = AttendanceSelectRepository(
    DatabaseHelper.instance,
  );

  final isLoading = false.obs;
  final RxMap<String, List<Grade>> availableGrades = <String, List<Grade>>{}.obs; 

  // A data específica selecionada pelo DatePicker (padrão: hoje)
  final Rx<DateTime> selectedPickerDate = DateTime.now().obs;

  // currentWeekStartDate é um getter derivado da selectedPickerDate, sempre será a segunda-feira
  Rx<DateTime> get currentWeekStartDate => _getMondayOfThisWeek(selectedPickerDate.value).obs;


  @override
  void onInit() {
    loadAvailableGrades(); 
    super.onInit();
  }

  // Carrega os horários ativos para o ano da semana selecionada
  Future<void> loadAvailableGrades() async {
    try {
      isLoading.value = true;
      
      int yearForFilter = currentWeekStartDate.value.year; // O ano para o filtro vem da data de início da semana

      final fetchedGrades = await _attendanceSelectRepository.getAllGradesForSelection(
        year: yearForFilter,
        activeStatus: true, 
      );

      final groupedGrades = <String, List<Grade>>{};
      for (final gradeItem in fetchedGrades) {
        final key = gradeItem.dayOfWeek.toString(); 
        groupedGrades.putIfAbsent(key, () => []).add(gradeItem);
      }
      
      groupedGrades.forEach((day, gradeList) {
        gradeList.sort((a, b) => a.startTimeTotalMinutes.compareTo(b.startTimeTotalMinutes));
      });

      availableGrades.assignAll(groupedGrades);
    } catch (e) {
      Get.dialog(CustomErrorDialog(title: 'Erro', message: 'Erro ao carregar horários para chamada: ${e.toString()}'));
    } finally {
      isLoading.value = false;
    }
  }

  // Getter para o ano que será exibido na AppBar
  int get selectedFilterYear => currentWeekStartDate.value.year;

  // Getter para o final da semana (Sexta-feira)
  DateTime get currentWeekEndDate {
    return currentWeekStartDate.value.add(const Duration(days: 4)); // Segunda + 4 dias = Sexta
  }

  // Método para atualizar a data selecionada (do DatePicker) e recarregar
  void updateSelectedDate(DateTime date) {
    selectedPickerDate.value = date;
    loadAvailableGrades(); 
  }

  // Métodos de navegação semanal
  void goToPreviousWeek() {
    selectedPickerDate.value = currentWeekStartDate.value.subtract(const Duration(days: 7));
    loadAvailableGrades(); 
  }

  void goToNextWeek() {
    selectedPickerDate.value = currentWeekStartDate.value.add(const Duration(days: 7));
    loadAvailableGrades();
  }

  // Helper para obter a segunda-feira da semana de uma data
  static DateTime _getMondayOfThisWeek(DateTime date) {
    int daysToSubtract = date.weekday - 1; 
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysToSubtract));
  }
}