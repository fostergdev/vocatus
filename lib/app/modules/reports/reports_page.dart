import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/modules/reports/reports_controller.dart';
import 'package:vocatus/app/models/grade.dart';


class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Relatórios de Turmas', // Consistent title for the class-focused page
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
            final years =
                controller.yearsByTab[0] ?? []; // Always use tab 0 for classes
            if (years.isEmpty) {
              return IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () {
                  // Show dialog if no years are available
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Sem relatórios'),
                      content: const Text(
                        'Não há relatórios de turmas disponíveis para filtro por ano.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(), // Use Get.back() for navigation
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
                      controller.onYearSelected(
                        0, // Always pass 0 for classes tab
                        year,
                      );
                    },
                  ),
              ],
            );
          }),
        ],
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
                  hintText: 'Buscar turmas...', // Hint text specific to classes
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
            child: Obx(() {
              final data = controller.filteredReportClasses;
              if (data.isEmpty && controller.searchText.value.isNotEmpty) {
                return const Center(
                  child: Text('Nenhuma turma encontrada com este nome/ID.'),
                );
              } else if (data.isEmpty) {
                return Center(
                  child: Text(
                    'Nenhum relatório de turmas para o ano ${controller.selectedFilterYear.value}.',
                  ),
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
                      subtitle: Text(
                        isActive ? 'Ativa' : 'Inativa',
                        style: TextStyle(
                          color: isActive
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 8,
                            bottom: 0,
                          ),
                          child: Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(
                                  Icons.assignment_turned_in,
                                  color: Colors.white,
                                ),
                                label: const Text('Chamadas'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(fontSize: 14),
                                ),
                                onPressed: () {
                                  // Navigate to the attendance report page
                                  Get.toNamed(
                                    '/reports/attendance-report', // Use the named route constant
                                    arguments: {
                                      'classId': classe.id,
                                      'className': classe.name,
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                         
                            ],
                          ),
                        ),
                        const Divider(indent: 16, endIndent: 16),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: classe.schedules.isEmpty
                              ? const Text(
                                  'Nenhum horário ou disciplina cadastrado para esta turma.',
                                )
                              : Column(
                                  children: classe.schedules.map((
                                    gradeSchedule,
                                  ) {
                                    return Card(
                                      elevation: 1,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        leading: Icon(
                                          Icons.schedule,
                                          color: Colors.purple.shade400,
                                        ),
                                        title: Text(
                                          _getDayName(gradeSchedule.dayOfWeek),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${Grade.formatTimeDisplay(gradeSchedule.startTimeOfDay)} às ${Grade.formatTimeDisplay(gradeSchedule.endTimeOfDay)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        trailing: Text(
                                          gradeSchedule.discipline?.name ??
                                              'Não especificada',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return 'Desconhecido';
    }
  }
}