import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart'; // Remova se não usar
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
          bottom: TabBar(
            labelColor: colorScheme.onPrimary, // Cor da label da aba selecionada
            unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7), // Cor da label da aba não selecionada
            indicatorColor: colorScheme.onPrimary, // Cor do indicador da aba
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
                  icon: Icon(Icons.calendar_today, color: colorScheme.onPrimary), // Ícone do tema
                  onPressed: () {
                    Get.dialog(
                      CustomDialog(
                        title: 'Sem Anos Disponíveis',
                        icon: Icons.info_outline, // Ícone do diálogo
                        content: Text(
                          currentTabIndex == 0 
                            ? 'Não há anos com relatórios de turmas para filtro.'
                            : 'Não há anos com relatórios de alunos para filtro.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface), // Texto do diálogo
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary, // Cor do botão
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
                icon: Icons.calendar_today, // Ícone do menu
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
            _buildClassReportsTab(colorScheme, textTheme), // Passa colorScheme e textTheme
            _buildStudentReportsTab(colorScheme, textTheme), // Passa colorScheme e textTheme
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
                hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant), // Hint style
                filled: true,
                fillColor: colorScheme.surfaceVariant, // Cor de fundo do campo
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none, // Sem borda por padrão
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline, // Borda habilitada
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.primary, // Borda focada com cor primária
                    width: 2.0,
                  ),
                ),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant), // Ícone de busca
                suffixIcon: controller.searchText.value.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant), // Ícone de limpar
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
                color: colorScheme.onSurface, // Cor do texto digitado
                fontSize: 16,
              ),
              cursorColor: colorScheme.primary, // Cor do cursor
            ),
          ),
        ),
        Expanded(
          child: _buildClassReportsList(colorScheme, textTheme), // Passa colorScheme e textTheme
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
                fillColor: colorScheme.surfaceVariant,
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
          child: _buildStudentReportsList(colorScheme, textTheme), // Passa colorScheme e textTheme
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
              CircularProgressIndicator(color: colorScheme.primary), // Cor do tema
              const SizedBox(height: 16),
              Text(
                'Carregando relatórios...',
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant, // Cor do texto
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
                color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor do ícone
              ),
              const SizedBox(height: 20),
              Text(
                'Nenhuma turma encontrada com este termo de busca.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant, // Cor do texto
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
                color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor do ícone
              ),
              const SizedBox(height: 20),
              Text(
                'Nenhum relatório de turmas disponível para o ano ${controller.selectedFilterYear.value}.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant, // Cor do texto
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Verifique outro ano ou adicione turmas.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8), // Cor do texto
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
                color: isActive ? colorScheme.primary.withOpacity(0.3) : colorScheme.outline.withOpacity(0.3), // Borda ativa/inativa
                width: 1,
              ),
            ),
            color: colorScheme.surface, // Fundo do Card
            surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
            child: ExpansionTile(
              backgroundColor: isActive ? Colors.transparent : colorScheme.surfaceVariant, // Fundo expandido
              collapsedBackgroundColor: isActive ? Colors.transparent : colorScheme.surfaceVariant, // Fundo recolhido
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? colorScheme.primary.withOpacity(0.1) : colorScheme.surfaceVariant, // Fundo do avatar
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.class_,
                  color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant, // Cor do ícone
                  size: 28, // Tamanho padrão do ícone
                ),
              ),
              title: Text(
                classe.name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive ? colorScheme.onSurface : colorScheme.onSurfaceVariant, // Cor do título
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (classe.description != null) ...[
                    Text(
                      classe.description!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: isActive ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withOpacity(0.7), // Cor da descrição
                        fontSize: 14,
                      ),
                    ),
                  ],
                  Text(
                    'Ano Letivo: ${classe.schoolYear}',
                    style: textTheme.bodySmall?.copyWith(
                      color: isActive ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withOpacity(0.7), // Cor do ano letivo
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isActive) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer, // Fundo para "Arquivada"
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ARQUIVADA',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onErrorContainer, // Texto para "Arquivada"
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
                        colorScheme: colorScheme, // Passa colorScheme
                        textTheme: textTheme, // Passa textTheme
                      ),
                      const SizedBox(height: 8),
                      _buildReportOption(
                        icon: Icons.assignment,
                        title: 'Relatório de Notas',
                        subtitle: 'Visualizar desempenho da turma',
                        onTap: () => controller.openGradesReport(classe),
                        colorScheme: colorScheme, // Passa colorScheme
                        textTheme: textTheme, // Passa textTheme
                      ),
                      const SizedBox(height: 8),
                      _buildReportOption(
                        icon: Icons.report_problem,
                        title: 'Relatório de Ocorrências',
                        subtitle: 'Visualizar ocorrências da turma',
                        onTap: () => controller.openOccurrencesReport(classe),
                        colorScheme: colorScheme, // Passa colorScheme
                        textTheme: textTheme, // Passa textTheme
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
              CircularProgressIndicator(color: colorScheme.primary), // Cor do tema
              const SizedBox(height: 16),
              Text(
                'Carregando alunos...',
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant, // Cor do texto
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
                color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor do ícone
              ),
              const SizedBox(height: 20),
              Text(
                'Nenhum aluno encontrado com este termo de busca.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant, // Cor do texto
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
                color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor do ícone
              ),
              const SizedBox(height: 20),
              Text(
                'Nenhum relatório de alunos disponível para o ano ${controller.selectedFilterYear.value}.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color: colorScheme.onSurfaceVariant, // Cor do texto
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Verifique outro ano ou adicione alunos.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8), // Cor do texto
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
                color: isActive ? colorScheme.primary.withOpacity(0.3) : colorScheme.outline.withOpacity(0.3), // Borda ativa/inativa
                width: 1,
              ),
            ),
            color: colorScheme.surface, // Fundo do Card
            surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
            child: ExpansionTile(
              backgroundColor: isActive ? Colors.transparent : colorScheme.surfaceVariant, // Fundo expandido
              collapsedBackgroundColor: isActive ? Colors.transparent : colorScheme.surfaceVariant, // Fundo recolhido
              onExpansionChanged: (expanded) {
                if (expanded) {
                  controller.openStudentUnifiedReport(student);
                }
              },
              leading: CircleAvatar(
                backgroundColor: isActive ? colorScheme.primary.withOpacity(0.1) : colorScheme.surfaceVariant, // Fundo do avatar
                child: Icon(
                  Icons.person,
                  color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant, // Cor do ícone
                ),
              ),
              title: Text(
                student['name'],
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isActive ? colorScheme.onSurface : colorScheme.onSurfaceVariant, // Cor do título
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Turma: ${student['class_name'] ?? 'Não informada'}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: isActive ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withOpacity(0.7), // Cor da turma
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.checklist,
                        size: 14,
                        color: colorScheme.tertiary, // Cor para frequência (verde)
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Frequência: ${student['attendance_percentage'] ?? '0.0'}%',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.tertiary, // Cor para frequência
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.report_problem,
                        size: 14,
                        color: colorScheme.secondary, // Cor para ocorrências (laranja)
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ocorrências: ${student['total_occurrences'] ?? 0}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary, // Cor para ocorrências
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
                        color: colorScheme.errorContainer, // Fundo para "Inativo"
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'INATIVO',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onErrorContainer, // Texto para "Inativo"
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
    required ColorScheme colorScheme, // Adicionado para cores do tema
    required TextTheme textTheme, // Adicionado para estilos de texto
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant), // Borda do tema
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1), // Fundo do ícone
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary, // Cor do ícone
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
                      color: colorScheme.onSurface, // Cor do título
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant, // Cor do subtítulo
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor da seta
            ),
          ],
        ),
      ),
    );
  }
}