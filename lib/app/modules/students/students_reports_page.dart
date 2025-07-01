import 'package:get/get.dart';
import 'package:flutter/material.dart';
// import 'package:vocatus/app/core/constants/constants.dart'; // No longer needed if all colors are dynamic
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/modules/students/students_reports_controller.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';

class StudentsReportsPage extends GetView<StudentsReportsController> {
  const StudentsReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current color scheme and text theme from the ThemeData
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatórios de Alunos',
          style: textTheme.titleLarge?.copyWith(
            // Use textTheme for consistency
            fontWeight: FontWeight.bold,
            color: colorScheme
                .onPrimary, // Dynamic color: text on primary background
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.9), // Dynamic primary color
                colorScheme.primary, // Dynamic primary color
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
        ), // Dynamic color: icons on primary background
        actions: [
          Obx(() {
            final years = controller.availableYears;

            // Se não tiver anos ou tiver apenas um, não mostra o botão
            if (years.isEmpty || years.length == 1) {
              return const SizedBox
                  .shrink(); // Widget invisível - não exibe nada
            }

            // Se tiver dois ou mais anos, mostra o ícone de calendário
            return IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: colorScheme.onPrimary,
                size: 24,
              ),
              onPressed: () {
                // Exibe o menu de seleção de ano
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
          // Current year indicator
          Obx(
            () => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme
                    .primaryContainer, // Dynamic: a light tint of primary
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(
                    0.3,
                  ), // Dynamic primary color
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: colorScheme
                        .onPrimaryContainer, // Dynamic: icon color on primary container
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Ano Letivo: ${controller.selectedFilterYear.value}',
                    style: textTheme.titleSmall?.copyWith(
                      // Use textTheme
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme
                          .onPrimaryContainer, // Dynamic: text color on primary container
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search field
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
                  ), // Dynamic
                  filled: true,
                  fillColor: colorScheme
                      .surfaceVariant, // Dynamic: a light background for input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide
                        .none, // Border is handled by enabledBorder/focusedBorder
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colorScheme.outline, // Dynamic outline color
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colorScheme.primary, // Dynamic primary color
                      width: 2.0,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ), // Dynamic
                  suffixIcon: controller.studentSearchText.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: colorScheme.onSurfaceVariant,
                          ), // Dynamic
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
                ), // Dynamic
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Students list
          Expanded(child: _buildStudentsList(context)), // Pass context
        ],
      ),
    );
  }

  Widget _buildStudentsList(BuildContext context) {
    // Added BuildContext
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
              ), // Dynamic color
              const SizedBox(height: 16),
              Text(
                'Carregando alunos...',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ), // Dynamic
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
              ), // Dynamic color
              const SizedBox(height: 20),
              Text(
                'Nenhum aluno encontrado com este termo de busca.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  // Dynamic
                  fontSize: 18,
                  color: colorScheme.onSurface.withOpacity(0.6), // Dynamic
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
              ), // Dynamic color
              const SizedBox(height: 20),
              Text(
                'Nenhum aluno encontrado para o ano ${controller.selectedFilterYear.value}.',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  // Dynamic
                  fontSize: 18,
                  color: colorScheme.onSurface.withOpacity(0.6), // Dynamic
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Verifique outro ano ou adicione alunos às turmas.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ), // Dynamic
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
                    ? colorScheme.primary.withOpacity(
                        0.3,
                      ) // Dynamic primary color
                    : colorScheme.outline.withOpacity(
                        0.3,
                      ), // Dynamic outline color
                width: 1,
              ),
            ),
            color: colorScheme.surface, // Dynamic: card background
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                controller.openStudentUnifiedReport(student);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: isActive
                          ? colorScheme
                                .primaryContainer // Dynamic: light tint of primary
                          : colorScheme.surfaceVariant, // Dynamic: for inactive
                      child: Icon(
                        Icons.person,
                        color: isActive
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant, // Dynamic
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Student info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'],
                            style: textTheme.titleSmall?.copyWith(
                              // Dynamic
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isActive
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant, // Dynamic
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Turma: ${student['class_name'] ?? 'Não informada'}',
                            style: textTheme.bodySmall?.copyWith(
                              // Dynamic
                              color: isActive
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurfaceVariant.withOpacity(
                                      0.7,
                                    ), // Dynamic
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Statistics row
                          Row(
                            children: [
                              // Attendance
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .green
                                      .shade50, // Specific color, consider defining in theme if frequent
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        Colors.green.shade200, // Specific color
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
                                          .shade600, // Specific color
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${student['attendance_percentage'] ?? '0.0'}%',
                                      style: textTheme.labelSmall?.copyWith(
                                        // Dynamic
                                        color: Colors
                                            .green
                                            .shade600, // Specific color
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Occurrences
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.orange.shade50, // Specific color
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors
                                        .orange
                                        .shade200, // Specific color
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
                                          .shade600, // Specific color
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${student['total_occurrences'] ?? 0}',
                                      style: textTheme.labelSmall?.copyWith(
                                        // Dynamic
                                        color: Colors
                                            .orange
                                            .shade600, // Specific color
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Inactive badge
                          if (!isActive) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme
                                    .errorContainer, // Dynamic: A light background for errors/warnings
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'INATIVO',
                                style: textTheme.labelSmall?.copyWith(
                                  // Dynamic
                                  color: colorScheme
                                      .onErrorContainer, // Dynamic: text color on error container
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Arrow icon
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurfaceVariant.withOpacity(
                        0.6,
                      ), // Dynamic
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
