import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart'; 
import 'package:vocatus/app/models/classe.dart';
import './reports_controller.dart';

class ClassUnifiedReportPage extends GetView<ReportsController> {
  const ClassUnifiedReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Classe classe = Get.arguments as Classe;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (classe.id != null) {
        controller.loadAttendanceReport(classe.id!);
        controller.loadOccurrencesReport(classe.id!);
        controller.loadHomeworkReport(classe.id!);
      }
    });

    return Obx(() {
      final bool hasAnyOccurrences = controller.occurrencesData.isNotEmpty;
      final bool hasAnyHomework = controller.homeworkData.isNotEmpty;
      
      final bool hasAnyAttendance = controller.attendanceReportData.isNotEmpty;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            classe.name,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimary,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.9),
                  colorScheme.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
        ),
        body: _buildPageContent(
          context,
          classe,
          colorScheme,
          textTheme,
          hasAnyOccurrences,
          hasAnyHomework,
          hasAnyAttendance,
        ),
      );
    });
  }

  
  List<CustomPopupMenuItem> _buildAppBarMenuItems(
    BuildContext context,
    bool hasAnyOccurrences,
    bool hasAnyHomework,
    bool hasAnyAttendance,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final List<CustomPopupMenuItem> appBarMenuItems = [];
    if (hasAnyOccurrences) {
      appBarMenuItems.add(
        CustomPopupMenuItem(
          label: 'Ver Todas Ocorrências (${controller.occurrencesData.length})',
          icon: Icons.error_outline,
          onTap: () => _showOccurrencesDialog(
            context,
            controller.occurrencesData,
            colorScheme,
            textTheme,
          ),
        ),
      );
    }
    if (hasAnyHomework) {
      appBarMenuItems.add(
        CustomPopupMenuItem(
          label: 'Ver Todas Tarefas de Casa (${controller.homeworkData.length})',
          icon: Icons.assignment,
          onTap: () => _showHomeworkDialog(
            context,
            controller.homeworkData,
            colorScheme,
            textTheme,
          ),
        ),
      );
    }
    if (hasAnyAttendance) {
      
      final Map<int, Map<String, dynamic>> groupedAttendances = {};
      for (final record in controller.attendanceReportData) {
        final attendanceId = record['attendance_id'] as int?;
        if (attendanceId != null && !groupedAttendances.containsKey(attendanceId)) {
          groupedAttendances[attendanceId] = record; 
        }
      }
      appBarMenuItems.add(
        CustomPopupMenuItem(
          label: 'Ver Todas Chamadas (${groupedAttendances.length})', 
          icon: Icons.check_circle_outline,
          onTap: () => _showAttendanceDialog(
            context,
            controller.attendanceReportData,
            colorScheme,
            textTheme,
          ),
        ),
      );
    }
    return appBarMenuItems;
  }

  
  Widget _buildPageContent(
    BuildContext context,
    Classe classe,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool hasAnyOccurrences,
    bool hasAnyHomework,
    bool hasAnyAttendance,
  ) {
    return Obx(() {
      if (controller.isLoadingAttendance.value ||
          controller.isLoadingOccurrences.value ||
          controller.isLoadingHomework.value) {
        return Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        );
      }

      final List<Widget> preListButtons = [];

      if (hasAnyOccurrences) {
        preListButtons.add(
          _buildActionButton(
            context,
            Icons.error_outline,
            colorScheme.error,
            () => _showOccurrencesDialog(
              context,
              controller.occurrencesData,
              colorScheme,
              textTheme,
            ),
            controller.occurrencesData.length,
            colorScheme,
          ),
        );
      }
      if (hasAnyHomework) {
        preListButtons.add(
          _buildActionButton(
            context,
            Icons.assignment,
            colorScheme.secondary,
            () => _showHomeworkDialog(
              context,
              controller.homeworkData,
              colorScheme,
              textTheme,
            ),
            controller.homeworkData.length,
            colorScheme,
          ),
        );
      }
      if (hasAnyAttendance) {
        
        final Map<int, Map<String, dynamic>> groupedAttendances = {};
        for (final record in controller.attendanceReportData) {
          final attendanceId = record['attendance_id'] as int?;
          if (attendanceId != null && !groupedAttendances.containsKey(attendanceId)) {
            groupedAttendances[attendanceId] = record;
          }
        }
        preListButtons.add(
          _buildActionButton(
            context,
            Icons.how_to_reg,
            colorScheme.tertiary,
            () => _showAttendanceDialog(
              context,
              controller.attendanceReportData,
              colorScheme,
              textTheme,
            ),
            groupedAttendances.length, 
            colorScheme,
          ),
        );
      }

      if (controller.attendanceReportData.isEmpty &&
          controller.occurrencesData.isEmpty &&
          controller.homeworkData.isEmpty) {
        return _buildEmptyState(colorScheme, textTheme);
      }

      return Column(
        children: [
          if (preListButtons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.start,
                children: preListButtons,
              ),
            ),
          Expanded(
            child: _buildAttendanceList(classe, colorScheme, textTheme),
          ),
        ],
      );
    });
  }

  
  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    int count,
    ColorScheme colorScheme,
  ) {
    return Tooltip(
      message: _getButtonTooltip(icon, count), 
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(10), 
            child: Icon(
              icon,
              size: 24, 
              color: color, 
            ),
          ),
        ),
      ),
    );
  }

  
  String _getButtonTooltip(IconData icon, int count) {
    if (icon == Icons.error_outline) {
      return 'Ver Ocorrências ($count)';
    } else if (icon == Icons.assignment) {
      return 'Ver Tarefas ($count)';
    } else if (icon == Icons.how_to_reg) {
      return 'Ver Chamadas ($count)'; 
    }
    return '';
  }

  
  Widget _buildAttendanceList(
    Classe classe,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final Map<String, List<Map<String, dynamic>>> occurrencesByDate = {};
    for (final occurrence in controller.occurrencesData) {
      final date = occurrence['date']?.toString();
      if (date != null) {
        if (!occurrencesByDate.containsKey(date)) {
          occurrencesByDate[date] = [];
        }
        occurrencesByDate[date]!.add(occurrence);
      }
    }

    final Map<String, List<Map<String, dynamic>>> homeworkByDueDate = {};
    for (final homework in controller.homeworkData) {
      final date = homework['due_date']?.toString();
      if (date != null) {
        if (!homeworkByDueDate.containsKey(date)) {
          homeworkByDueDate[date] = [];
        }
        homeworkByDueDate[date]!.add(homework);
      }
    }

    final Map<int, Map<String, dynamic>> groupedAttendances = {};
    for (final record in controller.attendanceReportData) {
      final attendanceId = record['attendance_id'] as int?;
      if (attendanceId == null) continue;

      if (!groupedAttendances.containsKey(attendanceId)) {
        final date = record['date']?.toString() ?? '';
        final currentOccurrences = occurrencesByDate[date] ?? [];
        final hasOccurrences = currentOccurrences.isNotEmpty;

        final currentHomework = homeworkByDueDate[date] ?? [];
        final hasHomework = currentHomework.isNotEmpty;

        groupedAttendances[attendanceId] = {
          'id': attendanceId,
          'date': date,
          'content': record['content'] ?? 'Sem conteúdo',
          'class_name': record['class_name'] ?? 'N/A',
          'discipline_name': record['discipline_name'] ?? 'N/A',
          'start_time': record['start_time'] ?? '--:--',
          'end_time': record['end_time'] ?? '--:--',
          'has_occurrences': hasOccurrences,
          'occurrences_count': currentOccurrences.length,
          'occurrences_list': currentOccurrences,
          'has_homework': hasHomework,
          'homework_count': currentHomework.length,
          'homework_list': currentHomework,
          'students': [],
        };
      }

      (groupedAttendances[attendanceId]!['students'] as List).add({
        'student_id': record['student_id'],
        'student_name': record['student_name'] ?? 'Nome não informado',
        'status': record['status'] ?? 'N',
      });
    }

    final sortedAttendances = groupedAttendances.values.toList()
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['date']) ?? DateTime.now();
        final dateB = DateTime.tryParse(b['date']) ?? DateTime.now();
        final dateCompare = dateA.compareTo(dateB);
        if (dateCompare != 0) return dateCompare;
        return (a['start_time'] as String).compareTo(b['start_time'] as String);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedAttendances.length,
      itemBuilder: (context, index) {
        final attendance = sortedAttendances[index];
        return _buildAttendanceCard(context, attendance, colorScheme, textTheme);
      },
    );
  }

  
  Widget _buildAttendanceCard(
    BuildContext context,
    Map<String, dynamic> attendance,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final DateTime date =
        DateTime.tryParse(attendance['date']) ?? DateTime.now();
    final String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final String startTime = attendance['start_time'];
    final String endTime = attendance['end_time'];
    final String className = attendance['class_name'];
    final String disciplineName = attendance['discipline_name'];
    final String content = attendance['content'];

    final List<Map<String, dynamic>> students = (attendance['students'] as List)
        .cast<Map<String, dynamic>>();

    final presentCount = students.where((s) => s['status'] == 'P').length;
    final totalStudents = students.length;
    final attendancePercentage = totalStudents > 0
        ? (presentCount / totalStudents * 100).round()
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    formattedDate,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$startTime - $endTime',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    disciplineName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Turma: $className'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: colorScheme.surfaceVariant,
                  labelStyle: textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: attendancePercentage / 100,
              backgroundColor: colorScheme.surfaceVariant,
              color: _getPercentageColor(attendancePercentage, colorScheme),
              minHeight: 6,
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$attendancePercentage% de presença',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        children: [
          if (content.isNotEmpty && content != 'Sem conteúdo' ||
              students.isNotEmpty)
            Divider(
              height: 24,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: colorScheme.outlineVariant,
            ),
          if (content.isNotEmpty && content != 'Sem conteúdo')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conteúdo abordado:',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          ...students.map(
            (student) => _buildStudentItem(student, colorScheme, textTheme),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  
  Color _getPercentageColor(int percentage, ColorScheme colorScheme) {
    if (percentage >= 75) return colorScheme.tertiary;
    if (percentage >= 50) return colorScheme.primary;
    return colorScheme.error;
  }

  
  Widget _buildStudentItem(
    Map<String, dynamic> record,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final String studentName = record['student_name'];
    final String status = record['status'];

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (status == 'P') {
      statusColor = colorScheme.tertiary;
      statusText = 'Presente';
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'F') {
      statusColor = colorScheme.error;
      statusText = 'Ausente';
      statusIcon = Icons.cancel_rounded;
    } else {
      statusColor = colorScheme.onSurfaceVariant;
      statusText = 'N/A';
      statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(statusIcon, color: statusColor, size: 24),
        title: Text(
          studentName,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            statusText,
            style: textTheme.labelMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  
  void _showOccurrencesDialog(
    BuildContext context,
    List<Map<String, dynamic>> occurrences,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: colorScheme.error),
              const SizedBox(width: 8),
              Text(
                'Ocorrências Registradas',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: occurrences.isEmpty
              ? Text(
                  'Nenhuma ocorrência encontrada para esta turma.',
                  style: textTheme.bodyMedium,
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: occurrences.length,
                    itemBuilder: (context, index) {
                      final occurrence = occurrences[index];
                      final String studentName =
                          occurrence['student_name'] ?? 'Aluno não informado';
                      final String type =
                          occurrence['type'] ?? 'Tipo não informado';
                      final String description =
                          occurrence['description'] ?? 'Sem descrição';
                      final String date = occurrence['date'] != null
                          ? DateFormat('dd/MM/yyyy').format(
                              DateTime.tryParse(occurrence['date']) ??
                                  DateTime.now(),
                            )
                          : 'N/A';
                      final String time = (occurrence['time'] as String?) ??
                          (DateTime.tryParse(occurrence['date'])
                              ?.toLocal()
                              .toString()
                              .substring(11, 16)) ??
                          'N/A';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: colorScheme.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$studentName - $type',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Data: $date às $time',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Fechar',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  
  void _showHomeworkDialog(
    BuildContext context,
    List<Map<String, dynamic>> homeworks,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.assignment, color: colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Tarefas de Casa',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: homeworks.isEmpty
              ? Text(
                  'Nenhuma tarefa de casa encontrada para esta turma.',
                  style: textTheme.bodyMedium,
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: homeworks.length,
                    itemBuilder: (context, index) {
                      final homework = homeworks[index];
                      final String title = homework['title'] ?? 'Sem título';
                      final String description =
                          homework['description'] ?? 'Sem descrição';
                      final String disciplineName =
                          homework['discipline_name'] ?? 'N/A';
                      final String dueDate =
                          homework['due_date_formatted'] ?? 'N/A';
                      final String assignedDate =
                          homework['assigned_date_formatted'] ?? 'N/A';
                      final String status = homework['status'] ?? 'pending';

                      Color statusColor;
                      String statusText;
                      switch (status.toLowerCase()) {
                        case 'pending':
                          statusColor = colorScheme.error;
                          statusText = 'Pendente';
                          break;
                        case 'completed':
                          statusColor = colorScheme.tertiary;
                          statusText = 'Concluído';
                          break;
                        default:
                          statusColor = colorScheme.onSurfaceVariant;
                          statusText = 'Status Desconhecido';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: statusColor.withOpacity(0.5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$title (${disciplineName})',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Data de Atribuição: $assignedDate',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Data de Entrega: $dueDate',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Chip(
                                  label: Text(statusText),
                                  backgroundColor: statusColor.withOpacity(0.2),
                                  labelStyle: textTheme.labelSmall?.copyWith(color: statusColor),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Fechar',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  
  void _showAttendanceDialog(
    BuildContext context,
    List<Map<String, dynamic>> attendances,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    
    final Map<int, Map<String, dynamic>> groupedAttendances = {};
    for (final record in attendances) {
      final attendanceId = record['attendance_id'] as int?;
      if (attendanceId == null) continue;

      if (!groupedAttendances.containsKey(attendanceId)) {
        groupedAttendances[attendanceId] = {
          'id': attendanceId,
          'date': record['date']?.toString() ?? '',
          'content': record['content'] ?? 'Sem conteúdo',
          'class_name': record['class_name'] ?? 'N/A',
          'discipline_name': record['discipline_name'] ?? 'N/A',
          'start_time': record['start_time'] ?? '--:--',
          'end_time': record['end_time'] ?? '--:--',
          'students': [],
        };
      }
      (groupedAttendances[attendanceId]!['students'] as List).add({
        'student_id': record['student_id'],
        'student_name': record['student_name'] ?? 'Nome não informado',
        'status': record['status'] ?? 'N',
      });
    }

    
    final sortedAttendances = groupedAttendances.values.toList()
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['date']) ?? DateTime.now();
        final dateB = DateTime.tryParse(b['date']) ?? DateTime.now();
        final dateCompare = dateA.compareTo(dateB);
        if (dateCompare != 0) return dateCompare;
        return (a['start_time'] as String).compareTo(b['start_time'] as String);
      });

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.how_to_reg, color: colorScheme.tertiary),
              const SizedBox(width: 8),
              Text(
                'Chamadas Registradas',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: attendances.isEmpty
              ? Text(
                  'Nenhuma chamada encontrada para esta turma.',
                  style: textTheme.bodyMedium,
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: sortedAttendances.length,
                    itemBuilder: (context, index) {
                      final attendance = sortedAttendances[index];
                      final DateTime date =
                          DateTime.tryParse(attendance['date']) ?? DateTime.now();
                      final String formattedDate =
                          DateFormat('dd/MM/yyyy').format(date);
                      final String startTime = attendance['start_time'];
                      final String endTime = attendance['end_time'];
                      final String disciplineName = attendance['discipline_name'];
                      final List<Map<String, dynamic>> students =
                          (attendance['students'] as List).cast<Map<String, dynamic>>();

                      final presentCount = students.where((s) => s['status'] == 'P').length;
                      final totalStudents = students.length;
                      final attendancePercentage = totalStudents > 0
                          ? (presentCount / totalStudents * 100).round()
                          : 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: colorScheme.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                disciplineName,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Data: $formattedDate (${startTime} - ${endTime})',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: attendancePercentage / 100,
                                backgroundColor: colorScheme.surfaceVariant,
                                color: _getPercentageColor(attendancePercentage, colorScheme),
                                minHeight: 4,
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '$attendancePercentage% de presença',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (students.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Alunos:',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                ...students.map((student) => Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                      child: Text(
                                        '${student['student_name']} - ${_getStatusText(student['status'])}',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    )),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Fechar',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  
  String _getStatusText(String status) {
    if (status == 'P') return 'Presente';
    if (status == 'F') return 'Ausente';
    return 'N/A';
  }

  
  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.how_to_reg,
            size: 80,
            color: colorScheme.onSurfaceVariant.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum registro encontrado',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Não há chamadas, ocorrências ou tarefas de casa registradas para esta turma.',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}