import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './reports_controller.dart';

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return Text(
            controller.classe.value.name,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          );
        }),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAttendanceCard(context),
          const SizedBox(height: 16),
          _buildOccurrencesCard(context),
          const SizedBox(height: 16),
          _buildHomeworkCard(context),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isLoading = controller.isLoadingAttendances.value;
      final percentage = controller.attendancePercentage.value;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequência da Turma',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (isLoading)
                const LinearProgressIndicator()
              else ...[
                Row(
                  children: [
                    Text(
                      '${controller.getTotalAttendances()} aulas registradas',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.green.shade700,
                  ),
                  minHeight: 10,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${percentage.toStringAsFixed(1)}% de presença',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => Get.toNamed(
                    '/reports/attendance-grid-report',
                    arguments: controller.classe.value,
                  ),
                  icon: Icon(Icons.bar_chart, color: colorScheme.primary),
                  label: Text(
                    'Relatório de Frequência',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOccurrencesCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isLoading = controller.isLoadingOccurrences.value;
      final counts = controller.occurrenceCountByType;
      final total = counts.values.fold(0, (sum, item) => sum + item);

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ocorrências por Tipo',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),
              if (isLoading)
                const LinearProgressIndicator()
              else if (total == 0)
                const Text('Nenhuma ocorrência registrada.')
              else
                _buildBarChart(context, counts, total),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.bar_chart, color: colorScheme.primary),
                  label: Text(
                    'Relatório de Ocorrências',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildOccurrenceBars(
    BuildContext context,
    Map<String, int> counts,
    int total,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final Map<String, IconData> iconMap = {
      'comportamento': Icons.group,
      'saude': Icons.healing,
      'atraso': Icons.schedule,
      'material': Icons.book,
      'geral': Icons.info,
      'outros': Icons.more_horiz,
    };

    return counts.entries.map((entry) {
      final percentage = total > 0 ? entry.value / total : 0.0;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(
              iconMap[entry.key] ?? Icons.help,
              size: 20,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key.capitalizeFirst} (${entry.value})',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade300,
                    minHeight: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildBarChart(
    BuildContext context,
    Map<String, int> counts,
    int total,
  ) {
    return Column(children: _buildOccurrenceBars(context, counts, total));
  }

  Widget _buildHomeworkCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isLoading = controller.isLoadingHomeworks.value;

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tarefas de Casa',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (isLoading)
                const LinearProgressIndicator()
              else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.assignment,
                    color: colorScheme.primary,
                    size: 40,
                  ),
                  title: Text('Total de Tarefas'),
                  subtitle: Text(
                    '${controller.getTotalHomeworks()} tarefas propostas',
                  ),
                ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.bar_chart, color: colorScheme.primary),
                  label: Text(
                    'Relatório de Tarefas',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
