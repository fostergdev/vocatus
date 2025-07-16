import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/modules/reports/reports_controller.dart';

class ReportsOccurrencesPage extends GetView<ReportsController> {
  const ReportsOccurrencesPage({super.key});

  String _formatDate(String? date) {
    if (date == null) return 'Sem data';
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date; // Return original string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatório de Ocorrências',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Obx(() {
        if (controller.isLoadingOccurrences.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final occurrencesByType = controller.occurrencesByType;

        if (occurrencesByType.isEmpty) {
          return const Center(child: Text('Nenhuma ocorrência encontrada.'));
        }

        final sortedKeys = occurrencesByType.keys.toList()..sort();

        return ListView.builder(
          itemCount: sortedKeys.length,
          itemBuilder: (context, index) {
            final type = sortedKeys[index];
            final occurrences = occurrencesByType[type]!;

            return ExpansionTile(
              title: Text(
                type,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: occurrences.map((occurrence) {
                return ListTile(
                  title: Text(
                    occurrence['student_name'] ?? 'Nome não encontrado',
                  ),
                  subtitle: Text(
                    '${occurrence['description'] ?? 'Sem descrição'}\n${_formatDate(occurrence['occurrence_date'])}',
                  ),
                );
              }).toList(),
            );
          },
        );
      }),
    );
  }
}
