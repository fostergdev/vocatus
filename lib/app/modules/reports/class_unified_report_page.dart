import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/constants/constants.dart'; // Mantenha, mas sem primaryColor
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
          iconTheme: IconThemeData(color: colorScheme.onPrimary), // Cor dos ícones da AppBar
          bottom: TabBar(
            labelColor: colorScheme.onPrimary, // Cor da label da aba selecionada
            unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7), // Cor da label da aba não selecionada
            indicatorColor: colorScheme.onPrimary, // Cor do indicador da aba
            indicatorWeight: 3,
            tabs: const [
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
            _buildAttendanceTab(classe, colorScheme, textTheme), // Passa context e theme
            _buildClassAverageTab(classe, colorScheme, textTheme), // Passa context e theme
            _buildOccurrencesTab(classe, colorScheme, textTheme), // Passa context e theme
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceTab(Classe classe, ColorScheme colorScheme, TextTheme textTheme) {
    return Obx(() {
      if (controller.isLoadingAttendance.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary), // Cor do tema
              const SizedBox(height: 16),
              Text(
                'Carregando registros de presença...',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant), // Cor do texto
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
              Icon(Icons.how_to_reg, size: 80, color: colorScheme.onSurfaceVariant.withOpacity(0.4)), // Cor do tema
              const SizedBox(height: 16),
              Text(
                'Nenhum registro de presença',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant, // Cor do tema
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta turma ainda não possui chamadas registradas.',
                style: textTheme.bodyMedium?.copyWith(fontSize: 14, color: colorScheme.onSurfaceVariant.withOpacity(0.7)), // Cor do tema
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
          return _buildDateCard(date, records, colorScheme, textTheme); // Passa colorscheme e texttheme
        },
      );
    });
  }

  Widget _buildDateCard(String dateStr, List<Map<String, dynamic>> records, ColorScheme colorScheme, TextTheme textTheme) {
    final DateTime date = DateTime.parse(dateStr);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(date);

    final int presentCount = records.where((r) => r['status'] == 'P').length; // P = Presente
    final int absentCount = records.where((r) => r['status'] == 'F').length; // F = Falta
    final int totalStudents = records.length;

    final String content = records.first['content']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: colorScheme.surface, // Fundo do Card
      surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1), // Fundo do ícone
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.calendar_today,
            color: colorScheme.primary, // Cor do ícone
            size: 20,
          ),
        ),
        title: Text(
          formattedDate,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 16, color: colorScheme.onSurface), // Estilo do título
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMiniStat('Presentes', presentCount, colorScheme.tertiary, colorScheme, textTheme), // Cores do tema
                const SizedBox(height: 4),
                _buildMiniStat('Ausentes', absentCount, colorScheme.error, colorScheme, textTheme), // Cores do tema
                const SizedBox(height: 4),
                _buildMiniStat('Total', totalStudents, colorScheme.primary, colorScheme, textTheme), // Cores do tema
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
                color: colorScheme.secondaryContainer, // Fundo suave para conteúdo (Material 3)
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.secondary.withOpacity(0.2)), // Borda
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conteúdo da Aula:',
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 14, color: colorScheme.onSecondaryContainer), // Cor do texto
                  ),
                  const SizedBox(height: 4),
                  Text(content, style: textTheme.bodyMedium?.copyWith(fontSize: 14, color: colorScheme.onSecondaryContainer)), // Cor do texto
                ],
              ),
            ),
          const SizedBox(height: 8),
          ...records.map((record) => _buildStudentItem(record, colorScheme, textTheme)), // Passa colorscheme e texttheme
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStudentItem(Map<String, dynamic> record, ColorScheme colorScheme, TextTheme textTheme) {
    final String studentName =
        record['student_name']?.toString() ?? 'Nome não informado';
    final String status = record['status']?.toString() ?? 'N';

    // Mapeamento de status para cores e ícones do ColorScheme
    Color thematicStatusColor;
    String statusText;
    IconData statusIcon;

    if (status == 'P') { // P = Presente
      thematicStatusColor = colorScheme.tertiary; // Geralmente verde
      statusText = 'Presente';
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'F') { // F = Falta
      thematicStatusColor = colorScheme.error; // Vermelho
      statusText = 'Ausente';
      statusIcon = Icons.cancel_rounded;
    } else { // N/A ou outros
      thematicStatusColor = colorScheme.onSurfaceVariant;
      statusText = 'N/A';
      statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          Icon(statusIcon, color: thematicStatusColor, size: 20), // Cor do ícone de status
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              studentName,
              style: textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurface), // Cor do texto do nome do aluno
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: thematicStatusColor.withOpacity(0.1), // Fundo suave da cor do status
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: thematicStatusColor.withOpacity(0.3)), // Borda da cor do status
            ),
            child: Text(
              statusText,
              style: textTheme.labelLarge?.copyWith(
                color: thematicStatusColor, // Cor do texto do status
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Fundo com opacidade da cor fornecida
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)), // Borda com opacidade da cor fornecida
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle), // Círculo com a cor fornecida
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color, // Cor do texto (a mesma da bolinha)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassAverageTab(Classe classe, ColorScheme colorScheme, TextTheme textTheme) {
    return Obx(() {
      if (controller.isLoadingAttendance.value) { // Reutiliza isLoadingAttendance, pode precisar de um isLoading separado para médias se for complexo
        return Center(child: CircularProgressIndicator(color: colorScheme.primary)); // Cor do tema
      }

      final attendanceData = controller.attendanceReportData;
      final uniqueStudents = attendanceData
          .map((a) => a['student_name'])
          .toSet();
      final uniqueDates = attendanceData.map((a) => a['date']).toSet();

      final totalPresences = attendanceData
          .where((a) => a['status'] == 'P') // P = Presente
          .length;
      final totalAbsences = attendanceData
          .where((a) => a['status'] == 'F') // F = Falta
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
              color: colorScheme.surface, // Fundo do Card
              surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: colorScheme.primary, // Cor do ícone
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Resumo da Turma',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface, // Cor do texto
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
                            colorScheme.secondary, // Cor do tema
                            colorScheme, textTheme, // Passa colorScheme e textTheme
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Aulas Realizadas',
                            uniqueDates.length.toString(),
                            Icons.calendar_today,
                            colorScheme.tertiary, // Cor do tema
                            colorScheme, textTheme, // Passa colorScheme e textTheme
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
              color: colorScheme.surface, // Fundo do Card
              surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.pie_chart, color: colorScheme.secondary, size: 28), // Cor do ícone
                        const SizedBox(width: 12),
                        Text(
                          'Frequência Geral',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface, // Cor do texto
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
                                  ? colorScheme.tertiary // Acima de 75% (verde)
                                  : attendancePercentage >= 50
                                  ? colorScheme.secondary // Acima de 50% (laranja/amarelo)
                                  : colorScheme.error, // Abaixo de 50% (vermelho)
                              (attendancePercentage >= 75
                                      ? colorScheme.tertiary
                                      : attendancePercentage >= 50
                                      ? colorScheme.secondary
                                      : colorScheme.error)
                                  .withOpacity(0.3), // Tom suave
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${attendancePercentage.toStringAsFixed(1)}%',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary, // Texto em contraste com o gradiente
                                ),
                              ),
                              Text(
                                'Frequência',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimary, // Texto em contraste
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
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.tertiary, // Cor para Presenças (verde)
                              ),
                            ),
                            Text(
                              'Presenças',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.tertiary, // Cor para Presenças
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              totalAbsences.toString(),
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.error, // Cor para Ausências (vermelho)
                              ),
                            ),
                            Text(
                              'Ausências',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.error, // Cor para Ausências
                              ),
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
                color: colorScheme.surface, // Fundo do Card
                surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: colorScheme.primary, size: 28), // Cor do ícone
                          const SizedBox(width: 12),
                          Text(
                            'Frequência por Aluno',
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface, // Cor do texto
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
                            .where((a) => a['status'] == 'P') // P = Presente
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
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface, // Cor do nome do aluno
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${studentPercentage.toStringAsFixed(1)}%',
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: studentPercentage >= 75
                                          ? colorScheme.tertiary
                                          : studentPercentage >= 50
                                          ? colorScheme.secondary
                                          : colorScheme.error,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: studentPercentage / 100,
                                backgroundColor: colorScheme.surfaceVariant, // Fundo da barra
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  studentPercentage >= 75
                                      ? colorScheme.tertiary
                                      : studentPercentage >= 50
                                      ? colorScheme.secondary
                                      : colorScheme.error,
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
    Color color, // Esta é a cor "temática" passada (primary, secondary, tertiary)
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Fundo suave da cor
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)), // Borda suave da cor
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28), // Ícone com a cor
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color, // Valor com a cor
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: color, // Label com a cor
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOccurrencesTab(Classe classe, ColorScheme colorScheme, TextTheme textTheme) {
    return Obx(() {
      log('🔍 Building occurrences tab. Data count: ${controller.occurrencesData.length}', 
          name: 'ClassUnifiedReportPage');
      
      if (controller.isLoadingOccurrences.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary), // Cor do tema
              const SizedBox(height: 16),
              Text(
                'Carregando ocorrências...',
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant), // Cor do tema
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
              Icon(Icons.report_problem, size: 80, color: colorScheme.onSurfaceVariant.withOpacity(0.4)), // Cor do tema
              const SizedBox(height: 16),
              Text(
                'Nenhuma ocorrência registrada',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant, // Cor do tema
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta turma ainda não possui ocorrências registradas.',
                style: textTheme.bodyMedium?.copyWith(fontSize: 14, color: colorScheme.onSurfaceVariant.withOpacity(0.7)), // Cor do tema
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
          return _buildOccurrenceDateCard(date, occurrences, colorScheme, textTheme); // Passa colorscheme e texttheme
        },
      );
    });
  }

  Widget _buildOccurrenceDateCard(
    String dateStr,
    List<Map<String, dynamic>> occurrences,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final DateTime date = DateTime.parse(dateStr);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: colorScheme.surface, // Fundo do Card
      surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1), // Fundo do ícone
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.calendar_today,
            color: colorScheme.primary, // Cor do ícone
            size: 20,
          ),
        ),
        title: Text(
          formattedDate,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 16, color: colorScheme.onSurface), // Estilo do título
        ),
        subtitle: Text(
          '${occurrences.length} ocorrência${occurrences.length != 1 ? 's' : ''}',
          style: textTheme.bodyMedium?.copyWith(fontSize: 14, color: colorScheme.onSurfaceVariant), // Estilo do subtítulo
        ),
        children: [
          ...occurrences.map((occurrence) => _buildOccurrenceItem(occurrence, colorScheme, textTheme)), // Passa colorscheme e texttheme
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOccurrenceItem(Map<String, dynamic> occurrence, ColorScheme colorScheme, TextTheme textTheme) {
    final String studentName =
        occurrence['student_name']?.toString() ?? 'Turma Toda';
    final String description = occurrence['description']?.toString() ?? '';
    final String type = occurrence['type']?.toString() ?? 'Geral';
    final bool isGeneral = occurrence['is_general'] == 1;

    Color typeColor;
    IconData typeIcon;

    // Mapeamento de tipo para cores do ColorScheme
    switch (type.toUpperCase()) {
      case 'DISCIPLINAR': // Comportamento
      case 'COMPORTAMENTO':
        typeColor = colorScheme.error; // Vermelho para problemas disciplinares/comportamentais
        typeIcon = Icons.psychology;
        break;
      case 'PEDAGOGICA': // Exemplo de um novo tipo
        typeColor = colorScheme.tertiary; // Verde/azul para pedagógica
        typeIcon = Icons.school;
        break;
      case 'SAUDE':
        typeColor = colorScheme.secondary; // Laranja/amarelo para saúde
        typeIcon = Icons.local_hospital;
        break;
      case 'ATRASO':
        typeColor = colorScheme.onSurfaceVariant; // Neutro para atraso
        typeIcon = Icons.access_time;
        break;
      case 'MATERIAL':
        typeColor = colorScheme.primary; // Primária para material
        typeIcon = Icons.inventory;
        break;
      default: // Geral ou tipos não mapeados
        if (isGeneral) {
          typeColor = colorScheme.primary; // Primária para geral
          typeIcon = Icons.info;
        } else {
          typeColor = colorScheme.onSurfaceVariant; // Neutro para outros de aluno
          typeIcon = Icons.person;
        }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      elevation: 2,
      color: colorScheme.surfaceContainerLow, // Fundo do Card interno
      surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: typeColor.withOpacity(0.3), // Borda com cor do tipo de ocorrência
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
                    color: typeColor.withOpacity(0.1), // Fundo do ícone
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    typeIcon,
                    size: 20,
                    color: typeColor, // Cor do ícone do tipo de ocorrência
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.capitalize!,
                        style: textTheme.titleSmall?.copyWith( // Estilo do título do tipo
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface, // Cor do texto do tipo
                        ),
                      ),
                      Text(
                        isGeneral ? 'Ocorrência Geral da Turma' : studentName,
                        style: textTheme.bodySmall?.copyWith( // Estilo do texto de aluno/geral
                          color: isGeneral ? colorScheme.primary : colorScheme.onSurfaceVariant, // Cor para geral ou aluno
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
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant, // Cor da descrição
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant), // Cor do ícone de calendário
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(occurrence['date'].toString())),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant, // Cor da data
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