import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import './reports_controller.dart';

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
          backgroundColor: Colors.purple.shade800,
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            CustomPopupMenu(
              textAlign: TextAlign.center,
              iconColor: Colors.white,
              icon: Icons.calendar_today,
              items: [
                for (var year in List.generate(
                  5,
                  (i) => DateTime.now().year - i,
                ))
                  CustomPopupMenuItem(
                    label: year.toString(),
                    onTap: () {
                      controller.onYearSelected(
                        year,
                      );
                    },
                  ),
              ],
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            onTap: (index) {},
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
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar turmas...',
                  hintStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0,
                  ),
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 18),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Obx(() {
                    if (controller.classesReport.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum relatório de turma encontrado para este ano.',
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: controller.classesReport.length,
                      itemBuilder: (context, index) {
                        final classReport = controller.classesReport[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
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
                              classReport.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text('ID: ${classReport.id}'),
                            children: [
                              const Divider(indent: 16, endIndent: 16),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /* Text(
                                      'Horários e Disciplinas:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8), */
                                    if (classReport.schedules.isEmpty)
                                      const Text(
                                        'Nenhum horário ou disciplina cadastrado para esta turma.',
                                      )
                                    else
                                      ...classReport.schedules.map((schedule) {
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
                                                        schedule.dayOfWeekName,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${schedule.startTime} às ${schedule.endTime}',
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      Text(
                                                        schedule.disciplineName ?? 'Não especificada',
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
                                                    // Abrir relatório de chamadas desta disciplina/horário
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
                  const Center(
                    child: Text('Relatórios de Alunos em desenvolvimento.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
