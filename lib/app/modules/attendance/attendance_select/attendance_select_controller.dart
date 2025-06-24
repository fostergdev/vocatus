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
    loadAvailableGrades();
    super.onInit();
  }

  Future<void> loadAvailableGrades() async {
    try {
      isLoading.value = true;
      gradeAttendanceStatus.clear();

      int yearForFilter = selectedPickerDate.value.year;

      final DateTime weekStartDate = _getMondayOfThisWeek(selectedPickerDate.value);

      final fetchedGrades = await _attendanceSelectRepository
          .getAllGradesForSelection(year: yearForFilter, activeStatus: true);

      final groupedGrades = <String, List<Grade>>{};
      for (final gradeItem in fetchedGrades) {
        bool attendanceExistsInThisWeek = false;

        for (int i = 0; i < 5; i++) {
          final DateTime specificDayInWeek = weekStartDate.add(Duration(days: i));
          if (gradeItem.dayOfWeek == specificDayInWeek.weekday) {
            final bool attendanceOnSpecificDay = await _attendanceSelectRepository
                .hasAttendanceForGradeAndDate(
                  gradeItem.id!,
                  specificDayInWeek,
                );
            if (attendanceOnSpecificDay) {
              attendanceExistsInThisWeek = true;
              break;
            }
          }
        }
        gradeAttendanceStatus[gradeItem.id!] = attendanceExistsInThisWeek;

        final key = gradeItem.dayOfWeek.toString();
        groupedGrades.putIfAbsent(key, () => []).add(gradeItem);
      }

      groupedGrades.forEach((day, gradeList) {
        gradeList.sort(
          (a, b) => a.startTimeTotalMinutes.compareTo(b.startTimeTotalMinutes),
        );
      });

      availableGrades.assignAll(groupedGrades);
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro',
          message: 'Erro ao carregar horários para chamada: ${e.toString()}',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  int get selectedFilterYear => currentWeekStartDate.value.year;

  DateTime get currentWeekEndDate {
    final endDate = currentWeekStartDate.value.add(const Duration(days: 4));
    return DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );
  }

  void updateSelectedDate(DateTime date) {
    selectedPickerDate.value = DateTime(date.year, date.month, date.day);
    loadAvailableGrades();
  }

  void goToPreviousWeek() {
    selectedPickerDate.value = DateTime(
      currentWeekStartDate.value.year,
      currentWeekStartDate.value.month,
      currentWeekStartDate.value.day,
    ).subtract(const Duration(days: 7));
    loadAvailableGrades();
  }

  void goToNextWeek() async {
    selectedPickerDate.value = DateTime(
      currentWeekStartDate.value.year,
      currentWeekStartDate.value.month,
      currentWeekStartDate.value.day,
    ).add(const Duration(days: 7));
    await loadAvailableGrades();
  }

  static DateTime _getMondayOfThisWeek(DateTime date) {
    int daysToSubtract = date.weekday - 1;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: daysToSubtract));
  }
}
