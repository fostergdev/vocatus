import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/modules/students/students_reports_controller.dart';


class StudentsReportsPage extends GetView<StudentsReportsController> {
  const StudentsReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatórios de Alunos',
          style: textTheme.titleLarge?.copyWith(
            
            fontWeight: FontWeight.bold,
            color: colorScheme
                .onPrimary, 
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
        iconTheme: IconThemeData(
          color: colorScheme.onPrimary,
        ), 
        actions: [
          Obx(() {
            final years = controller.availableYears;

            
            if (years.isEmpty || years.length == 1) {
              return const SizedBox
                  .shrink(); 
            }

            
            return IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: colorScheme.onPrimary,
                size: 24,
              ),
              onPressed: () {
                
                final RenderBox button = context.findRenderObject() as RenderBox;
                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(Offset.zero, ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero),
                        ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );

                showMenu(
                  context: context,
                  position: position,
                  items: [
                    for (var year in years)
                      PopupMenuItem(
                        value: year,
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          controller.onYearSelected(year);
                        },
                      ),
                  ],
                );
              },
            );
          }),
        ],
      ),
      body: Column(
        children: [
          
          Obx(
            () => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme
                    .primaryContainer, 
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha:
                    0.3,
                  ), 
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: colorScheme
                        .onPrimaryContainer, 
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ano Letivo: ${controller.selectedFilterYear.value}',
                    style: textTheme.titleSmall?.copyWith(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme
                          .onPrimaryContainer, 
                    ),
                  ),
                ],
              ),
            ),
          ),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Obx(
              () => TextField(
                controller: controller.studentSearchController,
                onChanged: controller.onStudentSearchTextChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar alunos por nome ou turma...',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ), 
                  filled: true,
                  fillColor: colorScheme
                      .surfaceContainerHighest, 
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide
                        .none, 
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
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ), 
                  suffixIcon: controller.studentSearchText.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: colorScheme.onSurfaceVariant,
                          ), 
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
                ), 
              ),
            ),
          ),

          const SizedBox(height: 16),

          
          Expanded(child: _buildStudentsList(context)), 
        ],
      ),
    );
  }

  Widget _buildStudentsList(BuildContext context) {
    
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final data = controller.filteredReportStudents;

      if (controller.isLoadingStudents.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: colorScheme.primary,
              ), 
              const SizedBox(height: 16),
              Text(
                'Carregando alunos...',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ), 
              ),
            ],
          ),
        );
      } else if (data.isEmpty &&
          controller.studentSearchText.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: colorScheme.outline,
              ), 
              const SizedBox(height: 20),
              Text(
                'Nenhum aluno encontrado com este termo de busca.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  
                  fontSize: 18,
                  color: colorScheme.onSurface.withValues(alpha:0.6), 
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
                color: colorScheme.outline,
              ), 
              const SizedBox(height: 20),
              Text(
                'Nenhum aluno encontrado para o ano ${controller.selectedFilterYear.value}.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  
                  fontSize: 18,
                  color: colorScheme.onSurface.withValues(alpha:0.6), 
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Verifique outro ano ou adicione alunos às turmas.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
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
                color: isActive
                    ? colorScheme.primary.withValues(alpha:
                        0.3,
                      ) 
                    : colorScheme.outline.withValues(alpha:
                        0.3,
                      ), 
                width: 1,
              ),
            ),
            color: colorScheme.surface, 
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                controller.openStudentUnifiedReport(student);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isActive
                          ? colorScheme
                                .primaryContainer 
                          : colorScheme.surfaceContainerHighest, 
                      child: Icon(
                        Icons.person,
                        color: isActive
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant, 
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 16),

                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'],
                            style: textTheme.titleSmall?.copyWith(
                              
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isActive
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant, 
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Turma: ${student['class_name'] ?? 'Não informada'}',
                            style: textTheme.bodySmall?.copyWith(
                              
                              color: isActive
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurfaceVariant.withValues(alpha:
                                      0.7,
                                    ), 
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),

                          
                          Row(
                            children: [
                              
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .green
                                      .shade50, 
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        Colors.green.shade200, 
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.checklist,
                                      size: 14,
                                      color: Colors
                                          .green
                                          .shade600, 
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${student['attendance_percentage'] ?? '0.0'}%',
                                      style: textTheme.labelSmall?.copyWith(
                                        
                                        color: Colors
                                            .green
                                            .shade600, 
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.orange.shade50, 
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors
                                        .orange
                                        .shade200, 
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.report_problem,
                                      size: 14,
                                      color: Colors
                                          .orange
                                          .shade600, 
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${student['total_occurrences'] ?? 0}',
                                      style: textTheme.labelSmall?.copyWith(
                                        
                                        color: Colors
                                            .orange
                                            .shade600, 
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          
                          if (!isActive) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme
                                    .errorContainer, 
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'INATIVO',
                                style: textTheme.labelSmall?.copyWith(
                                  
                                  color: colorScheme
                                      .onErrorContainer, 
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurfaceVariant.withValues(alpha:
                        0.6,
                      ), 
                    ),
                  ],
                ),
              ),
            ));
          },
        );
    });
  }
}
