import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/constants/constants.dart'; // Mantenha, mas já sem primaryColor
import 'package:vocatus/app/modules/reports/reports_controller.dart';

class StudentAttendanceReportPage extends GetView<ReportsController> {
  const StudentAttendanceReportPage({super.key});

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
          'Frequência - $studentName',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary, // Texto da AppBar
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
        actions: [
          IconButton(
            icon: Icon(Icons.file_download, color: colorScheme.onPrimary), // Cor do ícone
            onPressed: () {
              _showExportOptions(context, colorScheme, textTheme); // Passa theme
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.getStudentAttendanceDetails(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary), // Cor do tema
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
                    color: colorScheme.error, // Cor do ícone de erro
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar relatório',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.error, // Cor do texto de erro
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant, // Cor do texto
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final attendanceData = snapshot.data ?? [];

          if (attendanceData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor do ícone
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum registro de presença encontrado',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant, // Cor do texto
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Este aluno ainda não possui registros de chamada.',
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7), // Cor do texto
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
                _buildSummaryCard(attendanceData, colorScheme, textTheme), // Passa theme
                const SizedBox(height: 16),
                _buildAttendanceList(attendanceData, colorScheme, textTheme), // Passa theme
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Map<String, dynamic>> attendanceData, ColorScheme colorScheme, TextTheme textTheme) {
    final totalClasses = attendanceData.length;
    // Ajustado para 'P' para presente e 'A' para ausente, conforme suas convenções
    final totalPresent = attendanceData.where((a) => a['presence'] == 1).length; // Supondo 1 = presente
    final totalAbsent = attendanceData.where((a) => a['presence'] == 0).length; // Supondo 0 = ausente
    final attendancePercentage = totalClasses > 0
        ? (totalPresent / totalClasses * 100)
        : 0.0;
    
    // Mapeamento para garantir que a cor da frequência seja do tema
    Color attendanceColor = _getAttendanceColor(attendancePercentage, colorScheme);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surface, // Fundo do Card
      surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
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
                    color: colorScheme.primary.withOpacity(0.1), // Fundo do ícone
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.summarize,
                    color: colorScheme.primary, // Cor do ícone
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Resumo de Frequência',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface, // Cor do texto
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total de Aulas',
                    totalClasses.toString(),
                    Icons.class_,
                    colorScheme.secondary, // Cor do tema
                    colorScheme, textTheme, // Passa theme
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Frequência',
                    '${attendancePercentage.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    attendanceColor, // Cor dinâmica da frequência
                    colorScheme, textTheme, // Passa theme
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Presenças',
                    totalPresent.toString(),
                    Icons.check_circle,
                    colorScheme.tertiary, // Cor para presenças (verde)
                    colorScheme, textTheme, // Passa theme
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Faltas',
                    totalAbsent.toString(),
                    Icons.cancel,
                    colorScheme.error, // Cor para faltas (vermelho)
                    colorScheme, textTheme, // Passa theme
                  ),
                ),
              ],
            ),
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
        color: color.withOpacity(0.1), // Fundo suave da cor
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2), // Borda suave da cor
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color, // Ícone com a cor
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color, // Valor com a cor
            ),
          ),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant, // Label com cor neutra
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double attendance, ColorScheme colorScheme) {
    if (attendance >= 90) return colorScheme.tertiary; // Verde
    if (attendance >= 75) return colorScheme.secondary; // Laranja/Amarelo
    return colorScheme.error; // Vermelho
  }

  Widget _buildAttendanceList(List<Map<String, dynamic>> attendanceData, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surface, // Fundo do Card
      surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Histórico de Presenças',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, // Cor do título
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attendanceData.length,
              separatorBuilder: (context, index) => Divider(color: colorScheme.outlineVariant), // Separador
              itemBuilder: (context, index) {
                final attendance = attendanceData[index];
                final isPresent = attendance['presence'] == 1; // Supondo 1 = presente
                final date = DateTime.tryParse(attendance['date'] ?? '') ?? DateTime.now();
                final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                
                // Mapeamento de status para cores do ColorScheme
                Color thematicStatusColor = isPresent ? colorScheme.tertiary : colorScheme.error;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: thematicStatusColor.withOpacity(0.1), // Fundo do avatar
                    child: Icon(
                      isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded, // Ícones arredondados
                      color: thematicStatusColor, // Cor do ícone
                    ),
                  ),
                  title: Text(
                    formattedDate,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface, // Cor do título
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Turma: ${attendance['class_name'] ?? 'Não informada'}',
                           style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      if (attendance['discipline_name'] != null) ...[
                        Text('Disciplina: ${attendance['discipline_name']}',
                             style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                      if (attendance['content'] != null && attendance['content'].toString().isNotEmpty) ...[
                        Text('Conteúdo: ${attendance['content']}',
                             style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: thematicStatusColor.withOpacity(0.1), // Fundo do chip
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: thematicStatusColor, width: 1.0), // Borda do chip
                    ),
                    child: Text(
                      attendance['attendance_status'] ?? (isPresent ? 'Presente' : 'Ausente'),
                      style: textTheme.labelLarge?.copyWith(
                        color: thematicStatusColor, // Cor do texto do chip
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
          color: colorScheme.surface, // Fundo do bottom sheet
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant, // Cor da barra de arrasto
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Exportar Relatório',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface, // Cor do título
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: colorScheme.error), // Cor do ícone
              title: Text('Exportar como PDF', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)), // Cor do texto
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Exportar PDF',
                  'Funcionalidade em desenvolvimento',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: colorScheme.tertiaryContainer, // Fundo do Snackbar
                  colorText: colorScheme.onTertiaryContainer, // Texto do Snackbar
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.table_chart, color: colorScheme.tertiary), // Cor do ícone
              title: Text('Exportar como Excel', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)), // Cor do texto
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
              leading: Icon(Icons.share, color: colorScheme.primary), // Cor do ícone
              title: Text('Compartilhar', style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)), // Cor do texto
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