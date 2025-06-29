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
        return 'SEG';
      case 2:
        return 'TER';
      case 3:
        return 'QUA';
      case 4:
        return 'QUI';
      case 5:
        return 'SEX';
      case 6:
        return 'SÁB';
      case 0: // Sunday is 0 in Dart's DateTime.weekday
        return 'DOM';
      default:
        return 'Desconhecido';
    }
  }

  // Define a ordem dos dias a serem exibidos (Segunda a Sexta)
  final List<int> _displayDayOrder = const [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    // Calcula a largura da coluna de dia dinamicamente
    final double screenWidth = MediaQuery.of(context).size.width;
    // Define a largura da coluna para os cards de aula dentro das abas
    double columnWidth = screenWidth * 0.9; // Ocupa a maior parte da tela

    // Define larguras mínimas e máximas para a coluna dos cards
    const double minColumnWidth = 280.0;
    const double maxColumnWidth = 400.0; // Limite para tablets/desktops

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
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Constants.primaryColor.withValues(alpha: .9),
                Constants.primaryColor,
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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today, // Ícone de calendário
              color: Colors.white,
              size: 24,
            ),
            onPressed: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: controller.selectedPickerDate.value,
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
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
          // A seção de Padding que continha os botões de navegação e o seletor de data foi removida daqui.
          
          // Seção de Abas para os Dias da Semana
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
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
                        color: Colors.grey.shade400,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nenhum horário agendado para esta semana no ano ${controller.selectedFilterYear}.',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tente selecionar um ano diferente ou uma semana com aulas.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // Cria a lista de abas (os dias da semana)
              final List<Tab> dayTabs = _displayDayOrder.map((dayOfWeek) {
                final DateTime dayDate = controller.currentWeekStartDate.value.add(Duration(days: dayOfWeek - 1));
                return Tab(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDayName(dayOfWeek),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('dd/MM').format(dayDate),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                );
              }).toList();

              // Determina o índice inicial da aba (ex: hoje)
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
                      color: Colors.grey.shade100, // Cor de fundo para o TabBar
                      child: TabBar(
                        isScrollable: true, // Permite rolar as abas se houver muitos dias
                        labelColor: Constants.primaryColor,
                        unselectedLabelColor: Colors.grey.shade600,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Constants.primaryColor.withValues(alpha: .1), // Indicador de aba selecionada
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
                          return _buildDayColumn(dayOfWeek, gradesForDay, dayDate, columnWidth);
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
    double columnWidth, // Largura recebida para o card
  ) {
    return Center( // Centraliza a coluna dentro da aba
      child: Container(
        width: columnWidth, // Usa a largura dinâmica calculada
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .25),
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
                    _getDayName(dayOfWeek),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM').format(date),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            Expanded(
              child: gradesForDay.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            color: Colors.grey.shade400,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sem aulas',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
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
                        return _buildGradeCard(grade, date, hasAttendance);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeCard(Grade grade, DateTime date, bool hasAttendance) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: hasAttendance
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.purple.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${Grade.formatTimeDisplay(grade.startTimeOfDay)} - ${Grade.formatTimeDisplay(grade.endTimeOfDay)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade600,
                    ),
                  ),
                ],
              ),
              if (grade.discipline != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.subject, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        grade.discipline!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
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
                      color: hasAttendance ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasAttendance ? 'feita' : 'pendente',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: hasAttendance ? Colors.green : Colors.orange,
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
