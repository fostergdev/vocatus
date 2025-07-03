import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart'; 
import 'package:vocatus/app/modules/reports/reports_controller.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';



class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Relatórios',
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
          bottom: TabBar(
            labelColor: colorScheme.onPrimary, 
            unselectedLabelColor: colorScheme.onPrimary.withValues(alpha:0.7), 
            indicatorColor: colorScheme.onPrimary, 
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.class_),
                text: 'Turmas',
              ),
              Tab(
                icon: Icon(Icons.person),
                text: 'Alunos',
              ),
            ],
          ),
          actions: [
            Obx(() {
              final currentTabIndex = controller.currentTabIndex.value;
              final years = controller.yearsByTab[currentTabIndex] ?? [];
              
              if (years.isEmpty) {
                return IconButton(
                  icon: Icon(Icons.calendar_today, color: colorScheme.onPrimary), 
                  onPressed: () {
                    Get.dialog(
                      CustomDialog(
                        title: 'Sem Anos Disponíveis',
                        icon: Icons.info_outline, 
                        content: Text(
                          currentTabIndex == 0 
                            ? 'Não há anos com relatórios de turmas para filtro.'
                            : 'Não há anos com relatórios de alunos para filtro.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface), 
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary, 
                            ),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              
              return CustomPopupMenu(
                textAlign: TextAlign.center,
                icon: Icons.calendar_today, 
                items: [
                  for (var year in years)
                    CustomPopupMenuItem(
                      label: year.toString(),
                      onTap: () {
                        controller.selectedFilterYear.value = year;
                        controller.onYearSelected(currentTabIndex, year);
                      },
                    ),
                ],
              );
            }),
          ],
        ),
        body: TabBarView(
          children: [
            _buildClassReportsTab(colorScheme, textTheme), 
            _buildStudentReportsTab(colorScheme, textTheme), 
          ],
        ),
      ),
    );
  }

  Widget _buildClassReportsTab(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => TextField(
              controller: controller.searchInputController,
              onChanged: controller.onSearchTextChanged,
              decoration: InputDecoration(
                hintText: 'Buscar turmas por nome...',
                hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant), 
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest, 
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none, 
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline, 
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.primary, 
                    width: 2.0,
                  ),
                ),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant), 
                suffixIcon: controller.searchText.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant), 
                        onPressed: () {
                          controller.searchText.value = '';
                          controller.searchInputController.clear();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0,
                ),
              ),
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface, 
                fontSize: 16,
              ),
              cursorColor: colorScheme.primary, 
            ),
          ),
        ),
        Expanded(
          child: _buildClassReportsList(colorScheme, textTheme), 
        ),
      ],
    );
  }

  Widget _buildStudentReportsTab(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => TextField(
              controller: controller.studentSearchController,
              onChanged: controller.onStudentSearchTextChanged,
              decoration: InputDecoration(
                hintText: 'Buscar alunos por nome...',
                hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                suffixIcon: controller.studentSearchText.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                        onPressed: () {
                          controller.studentSearchText.value = '';
                          controller.studentSearchController.clear();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0,
                ),
              ),
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
              cursorColor: colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          child: _buildStudentReportsList(colorScheme, textTheme), 
        ),
      ],
    );
  }

  Widget _buildClassReportsList(ColorScheme colorScheme, TextTheme textTheme) {
    return Obx(() {
      final data = controller.filteredReportClasses;
      if (controller.isLoadingAttendance.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary), 
              const SizedBox(height: 16),
              Text(
                'Carregando relatórios...',
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant, 
                ),
              ),
            ],
          ),
        );
      } else if (data.isEmpty && controller.searchText.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: colorScheme.onSurfaceVariant.withValues(alpha:0.4), 
              ),
              const SizedBox(height: 20),
              Text(
                'Nenhuma turma encontrada com este termo de busca.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant, 
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      } else if (data.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 80,
                color: colorScheme.onSurfaceVariant.withValues(alpha:0.4), 
              ),
              const SizedBox(height: 20),
              Text(
                'Nenhum relatório de turmas disponível para o ano ${controller.selectedFilterYear.value}.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant, 
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Verifique outro ano ou adicione turmas.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant.withValues(alpha:0.8), 
                ),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final classe = data[index];
          final bool isActive = classe.active ?? false;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isActive ? colorScheme.primary.withValues(alpha:0.3) : colorScheme.outline.withValues(alpha:0.3), 
                width: 1,
              ),
            ),
            color: colorScheme.surface, 
            surfaceTintColor: colorScheme.primaryContainer, 
            child: ExpansionTile(
              backgroundColor: isActive ? Colors.transparent : colorScheme.surfaceContainerHighest, 
              collapsedBackgroundColor: isActive ? Colors.transparent : colorScheme.surfaceContainerHighest, 
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? colorScheme.primary.withValues(alpha:0.1) : colorScheme.surfaceContainerHighest, 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.class_,
                  color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant, 
                  size: 28, 
                ),
              ),
              title: Text(
                classe.name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive ? colorScheme.onSurface : colorScheme.onSurfaceVariant, 
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (classe.description != null) ...[
                    Text(
                      classe.description!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isActive ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withValues(alpha:0.7), 
                        fontSize: 14,
                      ),
                    ),
                  ],
                  Text(
                    'Ano Letivo: ${classe.schoolYear}',
                    style: textTheme.bodySmall?.copyWith(
                      color: isActive ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withValues(alpha:0.7), 
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isActive) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer, 
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ARQUIVADA',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onErrorContainer, 
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildReportOption(
                        icon: Icons.checklist,
                        title: 'Relatório de Presença',
                        subtitle: 'Visualizar frequência da turma',
                        onTap: () => controller.openAttendanceReport(classe),
                        colorScheme: colorScheme, 
                        textTheme: textTheme, 
                      ),
                      const SizedBox(height: 8),
                      _buildReportOption(
                        icon: Icons.assignment,
                        title: 'Relatório de Notas',
                        subtitle: 'Visualizar desempenho da turma',
                        onTap: () => controller.openSchedulesReport(classe),
                        colorScheme: colorScheme, 
                        textTheme: textTheme, 
                      ),
                      const SizedBox(height: 8),
                      _buildReportOption(
                        icon: Icons.report_problem,
                        title: 'Relatório de Ocorrências',
                        subtitle: 'Visualizar ocorrências da turma',
                        onTap: () => controller.openOccurrencesReport(classe),
                        colorScheme: colorScheme, 
                        textTheme: textTheme, 
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildStudentReportsList(ColorScheme colorScheme, TextTheme textTheme) {
    return Obx(() {
      final data = controller.filteredReportStudents;
      if (controller.isLoadingStudents.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary), 
              const SizedBox(height: 16),
              Text(
                'Carregando alunos...',
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant, 
                ),
              ),
            ],
          ),
        );
      } else if (data.isEmpty && controller.studentSearchText.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: colorScheme.onSurfaceVariant.withValues(alpha:0.4), 
              ),
              const SizedBox(height: 20),
              Text(
                'Nenhum aluno encontrado com este termo de busca.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant, 
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      } else if (data.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: colorScheme.onSurfaceVariant.withValues(alpha:0.4), 
              ),
              const SizedBox(height: 20),
              Text(
                'Nenhum relatório de alunos disponível para o ano ${controller.selectedFilterYear.value}.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant, 
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Verifique outro ano ou adicione alunos.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant.withValues(alpha:0.8), 
                ),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final student = data[index];
          final bool isActive = student['active'] == 1;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isActive ? colorScheme.primary.withValues(alpha:0.3) : colorScheme.outline.withValues(alpha:0.3), 
                width: 1,
              ),
            ),
            color: colorScheme.surface, 
            surfaceTintColor: colorScheme.primaryContainer, 
            child: ExpansionTile(
              backgroundColor: isActive ? Colors.transparent : colorScheme.surfaceContainerHighest, 
              collapsedBackgroundColor: isActive ? Colors.transparent : colorScheme.surfaceContainerHighest, 
              onExpansionChanged: (expanded) {
                if (expanded) {
                  controller.openStudentUnifiedReport(student);
                }
              },
              leading: CircleAvatar(
                backgroundColor: isActive ? colorScheme.primary.withValues(alpha:0.1) : colorScheme.surfaceContainerHighest, 
                child: Icon(
                  Icons.person,
                  color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant, 
                ),
              ),
              title: Text(
                student['name'],
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive ? colorScheme.onSurface : colorScheme.onSurfaceVariant, 
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Turma: ${student['class_name'] ?? 'Não informada'}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: isActive ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withValues(alpha:0.7), 
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.checklist,
                        size: 14,
                        color: colorScheme.tertiary, 
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Frequência: ${student['attendance_percentage'] ?? '0.0'}%',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.tertiary, 
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.report_problem,
                        size: 14,
                        color: colorScheme.secondary, 
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ocorrências: ${student['total_occurrences'] ?? 0}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary, 
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (!isActive) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer, 
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'INATIVO',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onErrorContainer, 
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              children: const [
                SizedBox.shrink(),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildReportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme, 
    required TextTheme textTheme, 
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant), 
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha:0.1), 
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary, 
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colorScheme.onSurface, 
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant, 
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onSurfaceVariant.withValues(alpha:0.4), 
            ),
          ],
        ),
      ),
    );
  }
}