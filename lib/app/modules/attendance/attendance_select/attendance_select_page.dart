import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/constants/constants.dart'; 
import 'package:vocatus/app/models/schedule.dart';
import './attendance_select_controller.dart';

class AttendanceSelectPage extends GetView<AttendanceSelectController> {
  const AttendanceSelectPage({super.key});

  final List<int> _displayDayOrder = const [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final double screenWidth = MediaQuery.of(context).size.width;
    double columnWidth = screenWidth * 0.9;
    const double minColumnWidth = 280.0;
    const double maxColumnWidth = 400.0;

    if (columnWidth < minColumnWidth) {
      columnWidth = minColumnWidth;
    } else if (columnWidth > maxColumnWidth) {
      columnWidth = maxColumnWidth;
    }

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            '${controller.selectedFilterYear}',
            style: textTheme.titleLarge?.copyWith( 
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary, 
            ),
          ),
        ),
        centerTitle: true,
        
        
        
        
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha:0.9), 
                colorScheme.primary, 
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        
        iconTheme: IconThemeData(color: colorScheme.onPrimary), 
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: colorScheme.onPrimary, 
              size: 24,
            ),
            onPressed: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: controller.selectedPickerDate.value,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: colorScheme, 
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary, 
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                controller.updateSelectedDate(pickedDate);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary)); 
              }

              final bool hasSchedulesForAnyDisplayedDay = _displayDayOrder.any(
                (day) => (controller.availableSchedules[day.toString()] ?? []).isNotEmpty,
              );

              if (!hasSchedulesForAnyDisplayedDay) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sentiment_dissatisfied,
                        color: colorScheme.onSurfaceVariant, 
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nenhum horário agendado para esta semana no ano ${controller.selectedFilterYear}.',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant, 
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tente selecionar um ano diferente ou uma semana com aulas.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha:0.8), 
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final List<Tab> dayTabs = _displayDayOrder.map((dayOfWeek) {
                final DateTime dayDate = controller.currentWeekStartDate.value.add(Duration(days: dayOfWeek - 1));
                return Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Constants.getDayName(dayOfWeek),
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd/MM').format(dayDate),
                        style: textTheme.bodySmall, 
                      ),
                    ],
                  ),
                );
              }).toList();

              int initialIndex = 0;
              final today = DateTime.now();
              for (int i = 0; i < _displayDayOrder.length; i++) {
                final dayDate = controller.currentWeekStartDate.value.add(Duration(days: _displayDayOrder[i] - 1));
                if (dayDate.year == today.year &&
                    dayDate.month == today.month &&
                    dayDate.day == today.day) {
                  initialIndex = i;
                  break;
                }
              }

              return DefaultTabController(
                length: _displayDayOrder.length,
                initialIndex: initialIndex,
                child: Column(
                  children: [
                    
                    Container(
                      color: colorScheme.surfaceContainerHighest, 
                      child: TabBar(
                        isScrollable: true,
                        labelColor: colorScheme.primary, 
                        unselectedLabelColor: colorScheme.onSurfaceVariant, 
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colorScheme.primary.withValues(alpha:0.1), 
                        ),
                        tabs: dayTabs,
                      ),
                    ),
                    
                    
                    Expanded(
                      child: TabBarView(
                        children: _displayDayOrder.map((dayOfWeek) {
                          final schedulesForDay = controller.availableSchedules[dayOfWeek.toString()] ?? [];
                          final DateTime dayDate = controller.currentWeekStartDate.value.add(Duration(days: dayOfWeek - 1));
                          return _buildDayColumn(dayOfWeek, schedulesForDay, dayDate, columnWidth, colorScheme, textTheme);
                        }).toList(),
                      ),
                    ),
                  ],
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
    List<Schedule> schedulesForDay,
    DateTime date,
    double columnWidth,
    ColorScheme colorScheme, 
    TextTheme textTheme, 
  ) {
    return Center(
      child: Container(
        width: columnWidth,
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: colorScheme.surface, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha:0.2), 
              blurRadius: 8,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    Constants.getDayName(dayOfWeek),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary, 
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM').format(date),
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), 
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant), 
            Expanded(
              child: schedulesForDay.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            color: colorScheme.onSurfaceVariant.withValues(alpha:0.6), 
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sem aulas',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(alpha:0.7), 
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: schedulesForDay.length,
                      itemBuilder: (context, index) {
                        final schedule = schedulesForDay[index];
                        final bool hasAttendance =
                            controller.scheduleAttendanceStatus[schedule.id!] ?? false;
                        return _buildScheduleCard(schedule, date, hasAttendance, colorScheme, textTheme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(
    Schedule schedule,
    DateTime date,
    bool hasAttendance,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    
    final Color statusDoneColor = Colors.green; 
    final Color statusPendingColor = Colors.orange; 
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceContainerHighest,
      surfaceTintColor: colorScheme.primaryContainer,
      child: InkWell(
        onTap: () {
          Get.toNamed(
            '/attendance/register',
            arguments: {'schedule': schedule, 'date': date},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.classe?.name ?? 'N/A',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasAttendance
                      ? statusDoneColor 
                      : statusPendingColor, 
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${Schedule.formatTimeDisplay(schedule.startTimeOfDay)} - ${Schedule.formatTimeDisplay(schedule.endTimeOfDay)}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (schedule.discipline != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.subject, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        schedule.discipline!.name,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      hasAttendance
                          ? Icons.check_circle_rounded
                          : Icons.pending_rounded,
                      color: hasAttendance ? statusDoneColor : statusPendingColor, 
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasAttendance ? 'feita' : 'pendente',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasAttendance ? statusDoneColor : statusPendingColor, 
                      ),
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