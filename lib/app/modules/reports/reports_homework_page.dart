import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/modules/reports/reports_controller.dart';

class ReportsHomeworkPage extends GetView<ReportsController> {
  const ReportsHomeworkPage({super.key});

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatório de Tarefas',
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
        if (controller.isLoadingHomeworks.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.homeworks.isEmpty) {
          return const Center(
            child: Text('Nenhuma tarefa de casa encontrada.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: controller.homeworks.length,
          itemBuilder: (context, index) {
            final homework = controller.homeworks[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: ListTile(
                title: Text(
                  homework['title'] ?? 'Sem Título',
                  style: textTheme.titleMedium,
                ),
                subtitle: Text(
                  '${homework['description']?.isNotEmpty == true ? homework['description'] : 'Sem descrição'}\nEntrega: ${_formatDate(homework['due_date'])}',
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
