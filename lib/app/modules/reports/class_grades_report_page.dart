import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart'; // Keep, but remember no primaryColor here
import 'package:vocatus/app/modules/reports/reports_controller.dart';

class ClassGradesReportPage extends GetView<ReportsController> {
  final int classId;
  final String className;

  const ClassGradesReportPage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notas - $className',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary, // AppBar title color
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.9), // Uses theme's primary color
                colorScheme.primary, // Uses theme's primary color
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
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // AppBar icon color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: colorScheme.primary.withOpacity(0.5), // Icon color, subtly linked to primary
            ),
            const SizedBox(height: 20),
            Text(
              'Relatório de Notas da Turma',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant, // Text color
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Esta funcionalidade está em desenvolvimento.\nEm breve você poderá visualizar o desempenho acadêmico da turma.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant.withOpacity(0.8), // Text color
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary), // Icon color
              label: Text('Voltar', style: TextStyle(color: colorScheme.onPrimary)), // Text color
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, // Button background color
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}