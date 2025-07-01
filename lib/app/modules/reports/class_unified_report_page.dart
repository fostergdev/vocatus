import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/models/classe.dart';
import './reports_controller.dart';

class ClassUnifiedReportPage extends GetView<ReportsController> {
  const ClassUnifiedReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Classe classe = Get.arguments as Classe;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (classe.id != null) {
        controller.loadAttendanceReport(classe.id!);
        controller.loadOccurrencesReport(
          classe.id!,
        );
        log(
          'Carregando dados para turma ${classe.id}',
          name: 'ClassUnifiedReportPage',
        );
      }
    });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Relatórios - ${classe.name}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Constants.primaryColor.withValues(alpha: 0.9),
                  Constants.primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.how_to_reg, size: 20), text: 'Presença'),
              Tab(
                icon: Icon(Icons.analytics, size: 20),
                text: 'Média da Turma',
              ),
              Tab(
                icon: Icon(Icons.report_problem, size: 20),
                text: 'Ocorrências',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAttendanceTab(classe),
            _buildClassAverageTab(classe),
            _buildOccurrencesTab(classe),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTab(Classe classe) {
    return Obx(() {
      if (controller.isLoadingAttendance.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Carregando registros de presença...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      if (controller.attendanceReportData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.how_to_reg, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Nenhum registro de presença',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta turma ainda não possui chamadas registradas.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      final Map<String, List<Map<String, dynamic>>> groupedByDate = {};
      for (final record in controller.attendanceReportData) {
        final String date = record['date']?.toString() ?? '';
        if (date.isNotEmpty) {
          if (!groupedByDate.containsKey(date)) {
            groupedByDate[date] = [];
          }
          groupedByDate[date]!.add(record);
        }
      }

      final sortedDates = groupedByDate.keys.toList()
        ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final records = groupedByDate[date]!;
          return _buildDateCard(date, records);
        },
      );
    });
  }

  Widget _buildDateCard(String dateStr, List<Map<String, dynamic>> records) {
    final DateTime date = DateTime.parse(dateStr);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(date);

    final int presentCount = records
        .where((r) => r['status'] == 'A')
        .length;
    final int absentCount = records
        .where((r) => r['status'] == 'P')
        .length;
    final int totalStudents = records.length;

    final String content = records.first['content']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Constants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.calendar_today,
            color: Constants.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          formattedDate,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMiniStat('Presentes', presentCount, Colors.green),
                const SizedBox(height: 4),
                _buildMiniStat('Ausentes', absentCount, Colors.red),
                const SizedBox(height: 4),
                _buildMiniStat('Total', totalStudents, Colors.blue),
              ],
            ),
          ],
        ),
        children: [
          if (content.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Conteúdo da Aula:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(content, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          ...records.map((record) => _buildStudentItem(record)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStudentItem(Map<String, dynamic> record) {
    final String studentName =
        record['student_name']?.toString() ?? 'Nome não informado';
    final String status = record['status']?.toString() ?? 'N';

    Color statusColor = status == 'A'
        ? Colors.green
        : status == 'P'
        ? Colors.red
        : Colors.grey;
    String statusText = status == 'A'
        ? 'Presente'
        : status == 'P'
        ? 'Ausente'
        : 'N/A';
    IconData statusIcon = status == 'A'
        ? Icons.check_circle
        : status == 'P'
        ? Icons.cancel
        : Icons.help;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              studentName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassAverageTab(Classe classe) {
    return Obx(() {
      if (controller.isLoadingAttendance.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final attendanceData = controller.attendanceReportData;
      final uniqueStudents = attendanceData
          .map((a) => a['student_name'])
          .toSet();
      final uniqueDates = attendanceData.map((a) => a['date']).toSet();

      final totalPresences = attendanceData
          .where((a) => a['status'] == 'A')
          .length;
      final totalAbsences = attendanceData
          .where((a) => a['status'] == 'P')
          .length;
      final totalRecords = attendanceData.length;

      final double attendancePercentage = totalRecords > 0
          ? (totalPresences / totalRecords) * 100
          : 0.0;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: Constants.primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Resumo da Turma',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total de Alunos',
                            uniqueStudents.length.toString(),
                            Icons.person,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Aulas Realizadas',
                            uniqueDates.length.toString(),
                            Icons.calendar_today,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pie_chart, color: Colors.orange, size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Frequência Geral',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              attendancePercentage >= 75
                                  ? Colors.green
                                  : attendancePercentage >= 50
                                  ? Colors.orange
                                  : Colors.red,
                              (attendancePercentage >= 75
                                      ? Colors.green
                                      : attendancePercentage >= 50
                                      ? Colors.orange
                                      : Colors.red)
                                  .withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${attendancePercentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Frequência',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              totalPresences.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text(
                              'Presenças',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              totalAbsences.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const Text(
                              'Ausências',
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (uniqueStudents.isNotEmpty)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.purple, size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'Frequência por Aluno',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...uniqueStudents.map((studentName) {
                        final studentRecords = attendanceData.where(
                          (a) => a['student_name'] == studentName,
                        );
                        final studentPresences = studentRecords
                            .where((a) => a['status'] == 'A')
                            .length;
                        final studentTotal = studentRecords.length;
                        final studentPercentage = studentTotal > 0
                            ? (studentPresences / studentTotal) * 100
                            : 0.0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      studentName.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${studentPercentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: studentPercentage >= 75
                                          ? Colors.green
                                          : studentPercentage >= 50
                                          ? Colors.orange
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: studentPercentage / 100,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  studentPercentage >= 75
                                      ? Colors.green
                                      : studentPercentage >= 50
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOccurrencesTab(Classe classe) {
    return Obx(() {
      log('🔍 Building occurrences tab. Data count: ${controller.occurrencesData.length}', 
          name: 'ClassUnifiedReportPage');
      
      if (controller.isLoadingOccurrences.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Carregando ocorrências...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      if (controller.occurrencesData.isEmpty) {
        log('⚠️ No occurrences data available', name: 'ClassUnifiedReportPage');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.report_problem, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Nenhuma ocorrência registrada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta turma ainda não possui ocorrências registradas.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      final Map<String, List<Map<String, dynamic>>> groupedByDate = {};
      for (final occurrence in controller.occurrencesData) {
        final String date = occurrence['date']?.toString() ?? '';
        log('📆 Processing occurrence with date: $date', name: 'ClassUnifiedReportPage');
        
        if (date.isNotEmpty) {
          if (!groupedByDate.containsKey(date)) {
            groupedByDate[date] = [];
          }
          groupedByDate[date]!.add(occurrence);
        } else {
          log('⚠️ Found occurrence with empty date', name: 'ClassUnifiedReportPage');
        }
      }

      final sortedDates = groupedByDate.keys.toList()
        ..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
      
      log('📅 Datas ordenadas (crescente): ${sortedDates.join(", ")}', name: 'ClassUnifiedReportPage');

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final occurrences = groupedByDate[date]!;
          return _buildOccurrenceDateCard(date, occurrences);
        },
      );
    });
  }

  Widget _buildOccurrenceDateCard(
    String dateStr,
    List<Map<String, dynamic>> occurrences,
  ) {
    final DateTime date = DateTime.parse(dateStr);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Constants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.calendar_today,
            color: Constants.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          formattedDate,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          '${occurrences.length} ocorrência${occurrences.length != 1 ? 's' : ''}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        children: [
          ...occurrences.map((occurrence) => _buildOccurrenceItem(occurrence)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOccurrenceItem(Map<String, dynamic> occurrence) {
    final String studentName =
        occurrence['student_name']?.toString() ?? 'Turma Toda';
    final String description = occurrence['description']?.toString() ?? '';
    final String type = occurrence['type']?.toString() ?? 'Geral';
    final bool isGeneral = occurrence['is_general'] == 1;

    Color typeColor;
    IconData typeIcon;

    switch (type.toUpperCase()) {
      case 'DISCIPLINAR':
      case 'COMPORTAMENTO':
        typeColor = Colors.red;
        typeIcon = Icons.psychology;
        break;
      case 'PEDAGOGICA':
        typeColor = Colors.blue;
        typeIcon = Icons.school;
        break;
      case 'SAUDE':
        typeColor = Colors.green;
        typeIcon = Icons.local_hospital;
        break;
      case 'ATRASO':
        typeColor = Colors.orange;
        typeIcon = Icons.access_time;
        break;
      case 'MATERIAL':
        typeColor = Colors.purple;
        typeIcon = Icons.inventory;
        break;
      default:
        if (isGeneral) {
          typeColor = Colors.blue;
          typeIcon = Icons.info;
        } else {
          typeColor = Colors.orange;
          typeIcon = Icons.person;
        }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: typeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
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
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    typeIcon,
                    size: 20,
                    color: typeColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.capitalize!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isGeneral ? 'Ocorrência Geral da Turma' : studentName,
                        style: TextStyle(
                          fontSize: 14,
                          color: isGeneral ? Colors.blue[600] : Colors.grey[600],
                          fontWeight: isGeneral ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(occurrence['date'].toString())),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
