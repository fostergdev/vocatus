import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart'; // Mantenha, mas já sem primaryColor
import 'package:vocatus/app/modules/reports/reports_controller.dart';

class ClassOccurrencesReportPage extends GetView<ReportsController> {
  final int classId;
  final String className;

  const ClassOccurrencesReportPage({
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
          'Ocorrências - $className',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary, // Cor do texto da AppBar
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.9), // Usa a cor primária do tema
                colorScheme.primary, // Usa a cor primária do tema
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
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Cor dos ícones da AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction, // Ícone de construção
              size: 80,
              color: colorScheme.secondary.withOpacity(0.6), // Cor do ícone, relacionada à cor secundária do tema
            ),
            const SizedBox(height: 20),
            Text(
              'Relatório de Ocorrências da Turma',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant, // Cor do texto
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Esta funcionalidade está em desenvolvimento.\nEm breve você poderá visualizar todas as ocorrências da turma.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant.withOpacity(0.8), // Cor do texto
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary), // Cor do ícone
              label: Text('Voltar', style: TextStyle(color: colorScheme.onPrimary)), // Cor do texto
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, // Fundo do botão
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}