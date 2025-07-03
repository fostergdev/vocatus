import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:vocatus/app/modules/reports/reports_controller.dart';
import 'package:intl/intl.dart';

class StudentOccurrencesReportPage extends GetView<ReportsController> {
  const StudentOccurrencesReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final String studentName = arguments?['studentName'] ?? 'Aluno';
    final int studentId = arguments?['studentId'] ?? 0;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ocorrências - $studentName',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary, 
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha:0.9), 
                colorScheme.primary, 
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
        iconTheme: IconThemeData(color: colorScheme.onPrimary), 
        actions: [
          IconButton(
            icon: Icon(Icons.file_download, color: colorScheme.onPrimary), 
            onPressed: () {
              _showExportOptions(context, colorScheme, textTheme); 
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.getStudentOccurrencesDetails(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary), 
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error, 
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar relatório',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.error, 
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant, 
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final occurrencesData = snapshot.data ?? [];

          if (occurrencesData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_very_satisfied, 
                    size: 64,
                    color: colorScheme.tertiary.withValues(alpha:0.4), 
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma ocorrência registrada!',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.tertiary, 
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Este aluno não possui ocorrências registradas.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant.withValues(alpha:0.7), 
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(occurrencesData, colorScheme, textTheme), 
                const SizedBox(height: 16),
                _buildOccurrencesList(occurrencesData, colorScheme, textTheme), 
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Map<String, dynamic>> occurrencesData, ColorScheme colorScheme, TextTheme textTheme) {
    final totalOccurrences = occurrencesData.length;
    final occurrencesByType = <String, int>{};
    
    for (var occurrence in occurrencesData) {
      final type = occurrence['occurrence_type']?.toString() ?? 'Geral';
      occurrencesByType[type] = (occurrencesByType[type] ?? 0) + 1;
    }

    final mostCommonType = occurrencesByType.isEmpty 
        ? 'Nenhuma'
        : occurrencesByType.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surface, 
      surfaceTintColor: colorScheme.primaryContainer, 
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
                    color: colorScheme.secondary.withValues(alpha:0.1), 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.summarize,
                    color: colorScheme.secondary, 
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Resumo de Ocorrências',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface, 
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total',
                    totalOccurrences.toString(),
                    Icons.report_problem,
                    colorScheme.error, 
                    colorScheme, textTheme, 
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Mais Comum',
                    mostCommonType,
                    Icons.trending_up,
                    _getOccurrenceTypeColor(mostCommonType, colorScheme), 
                    colorScheme, textTheme, 
                  ),
                ),
              ],
            ),
            if (occurrencesByType.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Por Tipo:',
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface, 
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: occurrencesByType.entries.map((entry) {
                  Color typeColor = _getOccurrenceTypeColor(entry.key, colorScheme); 
                  return Chip(
                    label: Text(
                      '${entry.key}: ${entry.value}',
                      style: textTheme.labelMedium?.copyWith(fontSize: 12, color: typeColor), 
                    ),
                    backgroundColor: typeColor.withValues(alpha:0.1), 
                    side: BorderSide(
                      color: typeColor.withValues(alpha:0.3), 
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1), 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha:0.3), 
          width: 1,
        ),
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
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color, 
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant, 
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOccurrencesList(List<Map<String, dynamic>> occurrencesData, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surface, 
      surfaceTintColor: colorScheme.primaryContainer, 
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico de Ocorrências',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, 
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: occurrencesData.length,
              separatorBuilder: (context, index) => Divider(color: colorScheme.outlineVariant), 
              itemBuilder: (context, index) {
                final occurrence = occurrencesData[index];
                final occurrenceDate = DateTime.tryParse(occurrence['occurrence_date'] ?? '') ?? DateTime.now();
                final formattedDate = DateFormat('dd/MM/yyyy').format(occurrenceDate);
                final type = occurrence['occurrence_type']?.toString() ?? 'Geral';
                final color = _getOccurrenceTypeColor(type, colorScheme); 

                return ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha:0.1), 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getOccurrenceIcon(type),
                      color: color, 
                      size: 20,
                    ),
                  ),
                  title: Text(
                    type,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface, 
                    ),
                  ),
                  subtitle: Text(
                    formattedDate,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), 
                  ),
                  trailing: Container( 
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (occurrence['description'] != null) ...[
                            Text(
                              'Descrição:',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: colorScheme.onSurface, 
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              occurrence['description'].toString(),
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant, 
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Row(
                            children: [
                              Icon(
                                Icons.school,
                                size: 16,
                                color: colorScheme.onSurfaceVariant, 
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Turma: ${occurrence['class_name'] ?? 'Não informada'}',
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant, 
                                ),
                              ),
                            ],
                          ),
                          if (occurrence['discipline_name'] != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.book,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant, 
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Disciplina: ${occurrence['discipline_name']}',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant, 
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getOccurrenceTypeColor(String type, ColorScheme colorScheme) {
    switch (type.toLowerCase()) {
      case 'comportamento':
        return colorScheme.error; 
      case 'saude':
        return colorScheme.secondary; 
      case 'atraso':
        return colorScheme.tertiary; 
      case 'material':
        return colorScheme.primary; 
      default:
        return colorScheme.onSurfaceVariant; 
    }
  }

  IconData _getOccurrenceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'comportamento':
        return Icons.psychology;
      case 'saúde':
        return Icons.local_hospital;
      case 'atraso':
        return Icons.access_time;
      case 'material':
        return Icons.inventory;
      default:
        return Icons.info;
    }
  }

  void _showExportOptions(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant, 
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Exportar Relatório',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, 
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: colorScheme.error), 
              title: Text('Exportar como PDF', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)), 
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Exportar PDF',
                  'Funcionalidade em desenvolvimento',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: colorScheme.tertiaryContainer, 
                  colorText: colorScheme.onTertiaryContainer, 
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: colorScheme.tertiary), 
              title: Text('Exportar como Excel', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)), 
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Exportar Excel',
                  'Funcionalidade em desenvolvimento',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: colorScheme.tertiaryContainer,
                  colorText: colorScheme.onTertiaryContainer,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: colorScheme.primary), 
              title: Text('Compartilhar', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)), 
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Compartilhar',
                  'Funcionalidade em desenvolvimento',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: colorScheme.tertiaryContainer,
                  colorText: colorScheme.onTertiaryContainer,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}