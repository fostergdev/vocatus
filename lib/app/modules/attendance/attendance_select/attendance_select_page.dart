import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/constants/constants.dart'; // Mantenha, mas ajuste seu conteúdo
import 'package:vocatus/app/models/grade.dart';
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
            style: textTheme.titleLarge?.copyWith( // Usar titleLarge do tema
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary, // Texto da AppBar (contrasta com primary)
            ),
          ),
        ),
        centerTitle: true,
        // O `backgroundColor` da AppBar já está definido no `main.dart`
        // para usar `settingsController.primaryColor.value`.
        // A flexibilidade aqui é boa, mas o gradiente pode sobrepor a cor dinâmica.
        // Se quiser manter o gradiente, certifique-se de que ele use `colorScheme.primary`.
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.9), // Usa a cor primária do tema
                colorScheme.primary, // Usa a cor primária do tema
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
        // Ícones da AppBar
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Cor dos ícones da AppBar
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: colorScheme.onPrimary, // Cor do ícone do calendário
              size: 24,
            ),
            onPressed: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: controller.selectedPickerDate.value,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                // Customizações de cores do DatePicker
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: colorScheme, // Usa o colorScheme do app
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary, // Cor dos botões de texto (ex: Cancelar, OK)
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
                return Center(child: CircularProgressIndicator(color: colorScheme.primary)); // Indicador com cor primária
              }

              final bool hasGradesForAnyDisplayedDay = _displayDayOrder.any(
                (day) => (controller.availableGrades[day.toString()] ?? []).isNotEmpty,
              );

              if (!hasGradesForAnyDisplayedDay) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sentiment_dissatisfied,
                        color: colorScheme.onSurfaceVariant, // Cor do ícone
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nenhum horário agendado para esta semana no ano ${controller.selectedFilterYear}.',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant, // Cor do texto
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tente selecionar um ano diferente ou uma semana com aulas.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.8), // Cor do texto
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
                        style: textTheme.bodySmall, // Estilo de texto menor
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
                    // TabBar para os dias da semana
                    Container(
                      color: colorScheme.surfaceVariant, // Cor de fundo para o TabBar
                      child: TabBar(
                        isScrollable: true,
                        labelColor: colorScheme.primary, // Cor da aba selecionada
                        unselectedLabelColor: colorScheme.onSurfaceVariant, // Cor da aba não selecionada
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: colorScheme.primary.withOpacity(0.1), // Indicador de aba selecionada
                        ),
                        tabs: dayTabs,
                      ),
                    ),
                    
                    // TabBarView para exibir o conteúdo de cada dia
                    Expanded(
                      child: TabBarView(
                        children: _displayDayOrder.map((dayOfWeek) {
                          final gradesForDay = controller.availableGrades[dayOfWeek.toString()] ?? [];
                          final DateTime dayDate = controller.currentWeekStartDate.value.add(Duration(days: dayOfWeek - 1));
                          return _buildDayColumn(dayOfWeek, gradesForDay, dayDate, columnWidth, colorScheme, textTheme);
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
    List<Grade> gradesForDay,
    DateTime date,
    double columnWidth,
    ColorScheme colorScheme, // Passe o ColorScheme
    TextTheme textTheme, // Passe o TextTheme
  ) {
    return Center(
      child: Container(
        width: columnWidth,
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: colorScheme.surface, // Fundo do card do dia
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.2), // Sombra do card
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
                      color: colorScheme.primary, // Cor do nome do dia
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM').format(date),
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), // Cor da data
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant), // Cor do Divider
            Expanded(
              child: gradesForDay.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.6), // Cor do ícone
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sem aulas',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant.withOpacity(0.7), // Cor do texto
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: gradesForDay.length,
                      itemBuilder: (context, index) {
                        final grade = gradesForDay[index];
                        final bool hasAttendance =
                            controller.gradeAttendanceStatus[grade.id!] ?? false;
                        return _buildGradeCard(grade, date, hasAttendance, colorScheme, textTheme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeCard(
    Grade grade,
    DateTime date,
    bool hasAttendance,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Definindo as cores específicas para status
    final Color statusDoneColor = Colors.green; // Verde para "feita"
    final Color statusPendingColor = Colors.orange; // Laranja para "pendente"
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceVariant,
      surfaceTintColor: colorScheme.primaryContainer,
      child: InkWell(
        onTap: () {
          Get.toNamed(
            '/attendance/register',
            arguments: {'grade': grade, 'date': date},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                grade.classe?.name ?? 'N/A',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: hasAttendance
                      ? statusDoneColor // Verde para "feita" 
                      : statusPendingColor, // Laranja para "pendente"
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
                    '${Grade.formatTimeDisplay(grade.startTimeOfDay)} - ${Grade.formatTimeDisplay(grade.endTimeOfDay)}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (grade.discipline != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.subject, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        grade.discipline!.name,
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
                      color: hasAttendance ? statusDoneColor : statusPendingColor, // Verde/Laranja
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasAttendance ? 'feita' : 'pendente',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasAttendance ? statusDoneColor : statusPendingColor, // Verde/Laranja
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