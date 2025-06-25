// reports_page.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/modules/reports/reports_controller.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/models/grade.dart';

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Relatórios',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Constants.primaryColor,
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Obx(() {
              final tabIndex = controller.selectedTabIndex.value;
              final years = controller.yearsByTab[tabIndex] ?? [];
              if (years.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () {
                    String tabName;
                    switch (tabIndex) {
                      case 0:
                        tabName = 'turmas';
                        break;
                      case 1:
                        tabName = 'alunos';
                        break;
                      default:
                        tabName = '';
                    }
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sem relatórios'),
                        content: Text('Não há relatórios para $tabName disponíveis para filtro por ano.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return CustomPopupMenu(
                textAlign: TextAlign.center,
                iconColor: Colors.white,
                icon: Icons.calendar_today,
                items: [
                  for (var year in years)
                    CustomPopupMenuItem(
                      label: year.toString(),
                      onTap: () {
                        controller.selectedFilterYear.value = year;
                        controller.onYearSelected(tabIndex, year);
                      },
                    ),
                ],
              );
            }),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            onTap: (index) {
              controller.onTabChanged(index);
            },
            tabs: const [
              Tab(
                text: 'Turmas',
                icon: Icon(Icons.class_, color: Colors.white),
              ),
              Tab(
                text: 'Alunos',
                icon: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => TextField(
                  controller: controller.searchInputController,
                  onChanged: controller.onSearchTextChanged,
                  decoration: InputDecoration(
                    hintText: controller.selectedTabIndex.value == 0
                        ? 'Buscar turmas...'
                        : 'Buscar alunos...',
                    hintStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: controller.searchText.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              controller.searchText.value = '';
                              controller.searchInputController.clear();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87, fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Obx(() {
                    final data = controller.filteredReportClasses;
                    if (data.isEmpty &&
                        controller.searchText.value.isNotEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma turma encontrada com este nome/ID.',
                        ),
                      );
                    } else if (data.isEmpty) {
                      return Center(
                        child: Text('Nenhum relatório de turmas para o ano ${controller.selectedFilterYear.value}.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final classe = data[index];
                        final bool isActive = classe.active ?? false;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            collapsedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple.shade100,
                              child: Icon(
                                Icons.class_,
                                color: Colors.purple.shade800,
                              ),
                            ),
                            title: Text(
                              classe.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text('ID: ${classe.id ?? ''}'),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    isActive ? 'Ativa' : 'Inativa',
                                    style: TextStyle(
                                      color: isActive ? Colors.green.shade800 : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              const Divider(indent: 16, endIndent: 16),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (classe.schedules.isEmpty)
                                      const Text(
                                        'Nenhum horário ou disciplina cadastrado para esta turma.',
                                      )
                                    else
                                      ...classe.schedules.map((gradeSchedule) {
                                        return Card(
                                          elevation: 2,
                                          margin: const EdgeInsets.only(bottom: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 16),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.schedule,
                                                  color: Colors.purple.shade400,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        _getDayName(gradeSchedule.dayOfWeek),
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${Grade.formatTimeDisplay(gradeSchedule.startTimeOfDay)} às ${Grade.formatTimeDisplay(gradeSchedule.endTimeOfDay)}',
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        gradeSchedule.discipline?.name ?? 'Não especificada',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.assignment_turned_in,
                                                    color: Colors.purple,
                                                  ),
                                                  tooltip: 'Relatório de Chamadas desta disciplina',
                                                  onPressed: () {
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                  Obx(() {
                    final data = controller.filteredArchivedStudents;
                    if (data.isEmpty &&
                        controller.searchText.value.isNotEmpty) {
                      return const Center(
                        child: Text('Nenhum aluno encontrado com este nome.'),
                      );
                    } else if (data.isEmpty) {
                      return Center(
                        child: Text('Nenhum relatório de alunos para o ano ${controller.selectedFilterYear.value}.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final student = data[index];
                        final String? classNames = student['class_names'] as String?;
                        final List<String> studentClasses = classNames?.split(',').map((e) => e.trim()).toList() ?? [];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'ID: ${student['id'] ?? ''}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.purple,
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.insert_chart_outlined,
                                        color: Colors.purple,
                                        size: 26,
                                      ),
                                      onPressed: () {
                                        Get.toNamed(
                                          '/report_student_details',
                                          arguments: student['id'],
                                        );
                                      },
                                      tooltip: 'Relatório',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Nome: ${student['name'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Registro: ${student['created_at'] != null && student['created_at'].toString().isNotEmpty ? (() {
                                          final dt = DateTime.tryParse(student['created_at'].toString());
                                          return dt != null ? DateFormat('dd-MM-yyyy \'às\' HH:mm:ss').format(dt) : student['created_at'].toString();
                                        })() : 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (studentClasses.isNotEmpty) ...[
                                  Text(
                                    'Turmas: ${studentClasses.join(', ')}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1: return 'Segunda-feira';
      case 2: return 'Terça-feira';
      case 3: return 'Quarta-feira';
      case 4: return 'Quinta-feira';
      case 5: return 'Sexta-feira';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return 'Desconhecido';
    }
  }
}