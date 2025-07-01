import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart'; // Pode ser removido se primaryColor não for mais usado
import 'package:vocatus/app/modules/reports/reports_controller.dart';

class StudentUnifiedReportPage extends GetView<ReportsController> {
  const StudentUnifiedReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final student = Get.arguments as Map<String, dynamic>;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            student['name'],
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary, // Usando cor dinâmica
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.9), // Usando cor dinâmica
                  colorScheme.primary, // Usando cor dinâmica
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
          iconTheme: IconThemeData(color: colorScheme.onPrimary), // Usando cor dinâmica
          bottom: TabBar(
            labelColor: colorScheme.onPrimary, // Usando cor dinâmica
            unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7), // Usando cor dinâmica
            indicatorColor: colorScheme.onPrimary, // Usando cor dinâmica
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.checklist),
                text: 'Frequência',
              ),
              Tab(
                icon: Icon(Icons.report_problem),
                text: 'Ocorrências',
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface, // Usando cor dinâmica
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1), // Usando cor dinâmica
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: colorScheme.primary.withOpacity(0.1), // Usando cor dinâmica
                        child: Icon(
                          Icons.person,
                          color: colorScheme.primary, // Usando cor dinâmica
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student['name'],
                              style: textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface, // Usando cor dinâmica
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Turma: ${student['class_name'] ?? 'Não informada'}',
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant, // Usando cor dinâmica
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          context, // Passando o contexto
                          icon: Icons.checklist,
                          title: 'Frequência',
                          value: '${student['attendance_percentage'] ?? '0.0'}%',
                          color: Colors.green, // Cores específicas para status podem ser mantidas
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryItem(
                          context, // Passando o contexto
                          icon: Icons.report_problem,
                          title: 'Ocorrências',
                          value: '${student['total_occurrences'] ?? 0}',
                          color: Colors.orange, // Cores específicas para status podem ser mantidas
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAttendanceTab(context, student), // Passando o contexto
                  _buildOccurrencesTab(context, student), // Passando o contexto
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, // Adicionado BuildContext
    {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Mantendo opacidade com cor específica
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)), // Mantendo opacidade com cor específica
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color, // Mantendo cor específica
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color, // Mantendo cor específica
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: color.withOpacity(0.8), // Mantendo opacidade com cor específica
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(BuildContext context, Map<String, dynamic> student) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return FutureBuilder(
      future: controller.loadStudentAttendanceHistory(student['id']),
      builder: (context, snapshot) {
        return Obx(() {
          if (controller.isLoadingStudentAttendance.value) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary), // Usando cor dinâmica
            );
          }

          final attendanceHistory = controller.studentAttendanceHistory;

          if (attendanceHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist_outlined,
                    size: 80,
                    color: colorScheme.onSurface.withOpacity(0.3), // Usando cor dinâmica
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nenhum histórico de frequência encontrado.',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      color: colorScheme.onSurface.withOpacity(0.6), // Usando cor dinâmica
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attendanceHistory.length,
            itemBuilder: (context, index) {
              final attendance = attendanceHistory[index];
              final isPresent = attendance['status'] == 'presente';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: colorScheme.surface, // Usando cor dinâmica
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), // Cores específicas
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPresent ? Icons.check_circle : Icons.cancel,
                      color: isPresent ? Colors.green : Colors.red, // Cores específicas
                    ),
                  ),
                  title: Text(
                    attendance['date'] ?? 'Data não informada',
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Status: ${isPresent ? 'Presente' : 'Ausente'}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: isPresent ? Colors.green.shade600 : Colors.red.shade600, // Cores específicas
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: attendance['class_name'] != null
                      ? Chip(
                          label: Text(
                            attendance['class_name'],
                            style: textTheme.bodySmall?.copyWith(fontSize: 12),
                          ),
                          backgroundColor: colorScheme.primary.withOpacity(0.1), // Usando cor dinâmica
                        )
                      : null,
                ),
              );
            },
          );
        });
      },
    );
  }

  Widget _buildOccurrencesTab(BuildContext context, Map<String, dynamic> student) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return FutureBuilder(
      future: controller.loadStudentOccurrencesHistory(student['id']),
      builder: (context, snapshot) {
        return Obx(() {
          if (controller.isLoadingStudentOccurrences.value) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary), // Usando cor dinâmica
            );
          }

          final occurrencesHistory = controller.studentOccurrencesHistory;

          if (occurrencesHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_problem_outlined,
                    size: 80,
                    color: colorScheme.onSurface.withOpacity(0.3), // Usando cor dinâmica
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nenhuma ocorrência encontrada.',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      color: colorScheme.onSurface.withOpacity(0.6), // Usando cor dinâmica
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: occurrencesHistory.length,
            itemBuilder: (context, index) {
              final occurrence = occurrencesHistory[index];
              final severity = occurrence['severity'] ?? 'baixa';
              Color severityColor = Colors.green; // Cores específicas para severidade

              switch (severity.toLowerCase()) {
                case 'alta':
                  severityColor = Colors.red;
                  break;
                case 'média':
                case 'media':
                  severityColor = Colors.orange;
                  break;
                default:
                  severityColor = Colors.green;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: colorScheme.surface, // Usando cor dinâmica
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: severityColor.withOpacity(0.1), // Cores específicas
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.report_problem,
                              color: severityColor, // Cores específicas
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  occurrence['title'] ?? 'Ocorrência',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  occurrence['date'] ?? 'Data não informada',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant, // Usando cor dinâmica
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: severityColor.withOpacity(0.1), // Cores específicas
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: severityColor.withOpacity(0.3)), // Cores específicas
                            ),
                            child: Text(
                              severity.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                color: severityColor, // Cores específicas
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (occurrence['description'] != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          occurrence['description'],
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant, // Usando cor dinâmica
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (occurrence['class_name'] != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Chip(
                            label: Text(
                              occurrence['class_name'],
                              style: textTheme.bodySmall?.copyWith(fontSize: 12),
                            ),
                            backgroundColor: colorScheme.primary.withOpacity(0.1), // Usando cor dinâmica
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }
}