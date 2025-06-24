import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/models/grade.dart';
import './attendance_select_controller.dart';

class AttendanceSelectPage extends GetView<AttendanceSelectController> {
  const AttendanceSelectPage({super.key});

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Segunda';
      case 2:
        return 'Terça';
      case 3:
        return 'Quarta';
      case 4:
        return 'Quinta';
      case 5:
        return 'Sexta';
      case 6:
        return 'Sábado';
      case 0:
        return 'Domingo';
      default:
        return 'Desconhecido';
    }
  }

  final List<int> _displayDayOrder = const [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            '${controller.selectedFilterYear}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Constants.primaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Obx(() {
              final String startDate = DateFormat(
                'dd/MM',
              ).format(controller.currentWeekStartDate.value);
              final String endDate = DateFormat(
                'dd/MM',
              ).format(controller.currentWeekEndDate);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Button for previous week
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.purple,
                    ),
                    onPressed: controller.goToPreviousWeek,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedPickerDate.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 5),
                        ),
                      );
                      if (pickedDate != null) {
                        controller.updateSelectedDate(pickedDate);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.purple,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$startDate - $endDate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Button for next week
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.purple,
                    ),
                    onPressed: controller.goToNextWeek,
                  ),
                ],
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final bool hasGradesForAnyDisplayedDay = _displayDayOrder.any(
                (day) => (controller.availableGrades[day.toString()] ?? [])
                    .isNotEmpty,
              );

              if (!hasGradesForAnyDisplayedDay) {
                return Center(
                  child: Text(
                    'Nenhum horário agendado para esta semana no ano ${controller.selectedFilterYear}.',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _displayDayOrder.map((dayOfWeek) {
                    final gradesForDay =
                        controller.availableGrades[dayOfWeek.toString()] ?? [];
                    final DateTime dayDate = controller
                        .currentWeekStartDate
                        .value
                        .add(Duration(days: dayOfWeek - 1));
                    return _buildDayColumn(dayOfWeek, gradesForDay, dayDate);
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(
    int dayOfWeek,
    List<Grade> gradesForDay,
    DateTime date,
  ) {
    return Container(
      width: 180,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  _getDayName(dayOfWeek),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Constants.primaryColor,
                  ),
                ),
                Text(
                  DateFormat('dd/MM').format(date),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: gradesForDay.isEmpty
                ? Center(
                    child: Text(
                      'Sem aulas',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    itemCount: gradesForDay.length,
                    itemBuilder: (context, index) {
                      final grade = gradesForDay[index];
                      final bool hasAttendance =
                          controller.gradeAttendanceStatus[grade.id!] ?? false;
                      return _buildGradeCard(grade, date, hasAttendance);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(Grade grade, DateTime date, bool hasAttendance) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            '/attendance/register',
            arguments: {'grade': grade, 'date': date},
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${grade.classe?.name ?? 'N/A'} ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: hasAttendance
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${Grade.formatTimeDisplay(grade.startTimeOfDay)} - ${Grade.formatTimeDisplay(grade.endTimeOfDay)}',
                style: TextStyle(fontSize: 12, color: Colors.purple.shade700),
              ),
              if (grade.discipline != null)
                Text(
                  grade.discipline!.name,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(
                      hasAttendance ? Icons.check_circle : Icons.warning,
                      color: hasAttendance ? Colors.green : Colors.red,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
