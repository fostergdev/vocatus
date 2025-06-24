import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import './history_controller.dart';
import 'package:intl/intl.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Histórico',
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
                        title: const Text('Sem histórico'),
                        content: Text('Não há histórico para $tabName.'),
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
                    final data = controller.filteredArchivedClasses;
                    if (data.isEmpty &&
                        controller.searchText.value.isNotEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma turma encontrada com este nome/ID.',
                        ),
                      );
                    } else if (data.isEmpty) {
                      return const Center(
                        child: Text('Nenhum histórico de turmas.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final classe = data[index];
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
                                      'ID: ${classe['id'] ?? ''}',
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
                                          '/report_classe_details',
                                          arguments: classe['id'],
                                        );
                                      },
                                      tooltip: 'Relatório',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Nome: ${classe['name'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 4),
                                Text(
                                  'Registro: ${classe['created_at'] != null && classe['created_at'].toString().isNotEmpty ? (() {
                                          final dt = DateTime.tryParse(classe['created_at'].toString());
                                          return dt != null ? DateFormat('dd-MM-yyyy \'às\' HH:mm:ss').format(dt) : classe['created_at'].toString();
                                        })() : 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
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
                      return const Center(
                        child: Text('Nenhum histórico de alunos.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final student = data[index];
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
}
