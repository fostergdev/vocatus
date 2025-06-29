import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/modules/reports/reports_controller.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Relatórios',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Constants.primaryColor.withValues(alpha: .9),
                  Constants.primaryColor,
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
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
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
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
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
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
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
                iconColor: Colors.white,
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
            _buildClassReportsTab(),
            _buildStudentReportsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildClassReportsTab() {
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
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Constants.primaryColor,
                    width: 2.0,
                  ),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: controller.searchText.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
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
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildClassReportsList(),
        ),
      ],
    );
  }

  Widget _buildStudentReportsTab() {
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
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Constants.primaryColor,
                    width: 2.0,
                  ),
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: controller.studentSearchText.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
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
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildStudentReportsList(),
        ),
      ],
    );
  }

  Widget _buildClassReportsList() {
    return Obx(() {
      final data = controller.filteredReportClasses;
      if (controller.isLoadingAttendance.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Constants.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Carregando relatórios...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
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
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 20),
              const Text(
                'Nenhuma turma encontrada com este termo de busca.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
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
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 20),
              Text(
                'Nenhum relatório de turmas disponível para o ano ${controller.selectedFilterYear.value}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Verifique outro ano ou adicione turmas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
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
                color: isActive ? Constants.primaryColor.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ExpansionTile(
              backgroundColor: isActive ? Colors.transparent : Colors.grey.shade50,
              collapsedBackgroundColor: isActive ? Colors.transparent : Colors.grey.shade50,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? Constants.primaryColor.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.class_,
                  color: isActive ? Constants.primaryColor : Colors.grey,
                ),
              ),
              title: Text(
                classe.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.black87 : Colors.grey,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (classe.description != null) ...[
                    Text(
                      classe.description!,
                      style: TextStyle(
                        color: isActive ? Colors.grey.shade600 : Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  Text(
                    'Ano Letivo: ${classe.schoolYear}',
                    style: TextStyle(
                      color: isActive ? Colors.grey.shade600 : Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (!isActive) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ARQUIVADA',
                        style: TextStyle(
                          color: Colors.orange.shade700,
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
                      ),
                      const SizedBox(height: 8),
                      _buildReportOption(
                        icon: Icons.assignment,
                        title: 'Relatório de Notas',
                        subtitle: 'Visualizar desempenho da turma',
                        onTap: () => controller.openGradesReport(classe),
                      ),
                      const SizedBox(height: 8),
                      _buildReportOption(
                        icon: Icons.report_problem,
                        title: 'Relatório de Ocorrências',
                        subtitle: 'Visualizar ocorrências da turma',
                        onTap: () => controller.openOccurrencesReport(classe),
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

  Widget _buildStudentReportsList() {
    return Obx(() {
      final data = controller.filteredReportStudents;
      if (controller.isLoadingStudents.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Constants.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Carregando alunos...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
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
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 20),
              const Text(
                'Nenhum aluno encontrado com este termo de busca.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
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
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 20),
              Text(
                'Nenhum relatório de alunos disponível para o ano ${controller.selectedFilterYear.value}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Verifique outro ano ou adicione alunos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
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
                color: isActive ? Constants.primaryColor.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ExpansionTile(
              backgroundColor: isActive ? Colors.transparent : Colors.grey.shade50,
              collapsedBackgroundColor: isActive ? Colors.transparent : Colors.grey.shade50,
              onExpansionChanged: (expanded) {
                if (expanded) {
                  // Ao expandir, navegar diretamente para a página unificada
                  controller.openStudentUnifiedReport(student);
                }
              },
              leading: CircleAvatar(
                backgroundColor: isActive ? Constants.primaryColor.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  color: isActive ? Constants.primaryColor : Colors.grey,
                ),
              ),
              title: Text(
                student['name'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.black87 : Colors.grey,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Turma: ${student['class_name'] ?? 'Não informada'}',
                    style: TextStyle(
                      color: isActive ? Colors.grey.shade600 : Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.checklist,
                        size: 14,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Frequência: ${student['attendance_percentage'] ?? '0.0'}%',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.report_problem,
                        size: 14,
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ocorrências: ${student['total_occurrences'] ?? 0}',
                        style: TextStyle(
                          color: Colors.orange.shade600,
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
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'INATIVO',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              children: const [
                // Removido o conteúdo das opções, agora vai direto para a página unificada
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Constants.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: Constants.primaryColor,
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
