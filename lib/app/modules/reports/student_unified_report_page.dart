import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/modules/reports/reports_controller.dart';

class StudentUnifiedReportPage extends GetView<ReportsController> {
  const StudentUnifiedReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final student = Get.arguments as Map<String, dynamic>;
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            student['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
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
                        backgroundColor: Constants.primaryColor.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.person,
                          color: Constants.primaryColor,
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Turma: ${student['class_name'] ?? 'Não informada'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
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
                          icon: Icons.checklist,
                          title: 'Frequência',
                          value: '${student['attendance_percentage'] ?? '0.0'}%',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryItem(
                          icon: Icons.report_problem,
                          title: 'Ocorrências',
                          value: '${student['total_occurrences'] ?? 0}',
                          color: Colors.orange,
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
                  _buildAttendanceTab(student),
                  _buildOccurrencesTab(student),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(Map<String, dynamic> student) {
    return FutureBuilder(
      future: controller.loadStudentAttendanceHistory(student['id']),
      builder: (context, snapshot) {
        return Obx(() {
          if (controller.isLoadingStudentAttendance.value) {
            return const Center(
              child: CircularProgressIndicator(color: Constants.primaryColor),
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
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nenhum histórico de frequência encontrado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
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
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPresent ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPresent ? Icons.check_circle : Icons.cancel,
                      color: isPresent ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    attendance['date'] ?? 'Data não informada',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Status: ${isPresent ? 'Presente' : 'Ausente'}',
                    style: TextStyle(
                      color: isPresent ? Colors.green.shade600 : Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: attendance['class_name'] != null
                      ? Chip(
                          label: Text(
                            attendance['class_name'],
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Constants.primaryColor.withValues(alpha: 0.1),
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

  Widget _buildOccurrencesTab(Map<String, dynamic> student) {
    return FutureBuilder(
      future: controller.loadStudentOccurrencesHistory(student['id']),
      builder: (context, snapshot) {
        return Obx(() {
          if (controller.isLoadingStudentOccurrences.value) {
            return const Center(
              child: CircularProgressIndicator(color: Constants.primaryColor),
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
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nenhuma ocorrência encontrada.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
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
              Color severityColor = Colors.green;
              
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
                              color: severityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.report_problem,
                              color: severityColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  occurrence['title'] ?? 'Ocorrência',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  occurrence['date'] ?? 'Data não informada',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: severityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: severityColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              severity.toUpperCase(),
                              style: TextStyle(
                                color: severityColor,
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
                          style: TextStyle(
                            color: Colors.grey.shade700,
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
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Constants.primaryColor.withValues(alpha: 0.1),
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