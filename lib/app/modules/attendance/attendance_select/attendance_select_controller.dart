import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/models/schedule.dart';
import 'package:vocatus/app/repositories/attendance/attendance_select/attendance_select_repository.dart';

class AttendanceSelectController extends GetxController {
  final AttendanceSelectRepository _attendanceSelectRepository =
      AttendanceSelectRepository(DatabaseHelper.instance);

  final isLoading = false.obs;
  final RxMap<String, List<Schedule>> availableSchedules =
      <String, List<Schedule>>{}.obs;

  final RxMap<int, bool> scheduleAttendanceStatus = <int, bool>{}.obs;

  final Rx<DateTime> selectedPickerDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).obs;

  Rx<DateTime> get currentWeekStartDate =>
      _getMondayOfThisWeek(selectedPickerDate.value).obs;

  @override
  void onInit() {
    loadAvailableSchedules();
    super.onInit();
  }

  Future<void> loadAvailableSchedules() async {
    try {
      isLoading.value = true;
      scheduleAttendanceStatus.clear();

      int yearForFilter = selectedPickerDate.value.year;
      final DateTime weekStartDate = _getMondayOfThisWeek(selectedPickerDate.value);

      final fetchedSchedules = await _attendanceSelectRepository
          .getAllSchedulesForSelection(year: yearForFilter, activeStatus: true);

      final groupedSchedules = <String, List<Schedule>>{};
      for (final scheduleItem in fetchedSchedules) {
        bool attendanceExistsInThisWeek = false;

        
        for (int i = 0; i < 5; i++) {
          final DateTime specificDayInWeek = weekStartDate.add(Duration(days: i));
          
          
          if (scheduleItem.dayOfWeek == specificDayInWeek.weekday && specificDayInWeek.weekday >= 1 && specificDayInWeek.weekday <= 5) {
            final bool attendanceOnSpecificDay = await _attendanceSelectRepository
                .hasAttendanceForScheduleAndDate(
                  scheduleItem.id!,
                  specificDayInWeek,
                );
            if (attendanceOnSpecificDay) {
              attendanceExistsInThisWeek = true;
              break; 
            }
          }
        }
        scheduleAttendanceStatus[scheduleItem.id!] = attendanceExistsInThisWeek;
        
        final key = scheduleItem.dayOfWeek.toString();
        groupedSchedules.putIfAbsent(key, () => []).add(scheduleItem);
      }

      groupedSchedules.forEach((day, scheduleList) {
        scheduleList.sort(
          (a, b) => a.startTimeTotalMinutes.compareTo(b.startTimeTotalMinutes),
        );
      });

      availableSchedules.assignAll(groupedSchedules);
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

  void updateSelectedDate(DateTime date) {
    selectedPickerDate.value = DateTime(date.year, date.month, date.day);
    loadAvailableSchedules();
  }

  void goToPreviousWeek() {
    selectedPickerDate.value = DateTime(
      currentWeekStartDate.value.year,
      currentWeekStartDate.value.month,
      currentWeekStartDate.value.day,
    ).subtract(const Duration(days: 7));
    loadAvailableSchedules();
  }

  Future<void> goToNextWeek() async {
    selectedPickerDate.value = DateTime(
      currentWeekStartDate.value.year,
      currentWeekStartDate.value.month,
      currentWeekStartDate.value.day,
    ).add(const Duration(days: 7));
    await loadAvailableSchedules();
  }

  static DateTime _getMondayOfThisWeek(DateTime date) {
    int daysToSubtract = date.weekday - 1; 
    
    
    
    
    
    if (daysToSubtract < 0) { 
       daysToSubtract = 0; 
    }
    final monday = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: daysToSubtract));
    return monday;
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
}