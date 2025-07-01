// app/pages/students/students_page.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
// import 'package:vocatus/app/core/constants/constants.dart'; // No longer needed if all colors are dynamic
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/student.dart';
import './students_controller.dart';

class StudentsPage extends GetView<StudentsController> {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current color scheme and text theme from the ThemeData
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alunos de ${controller.currentClasse.name}',
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
          IconButton(
            icon: const Icon(Icons.file_copy),
            tooltip: 'Importar alunos de outra turma',
            color: colorScheme.onPrimary, // Dynamic color
            onPressed: () async {
              controller.resetImportFilters();
              await controller.loadAvailableYears();
              if (context.mounted) {
                _showImportStudentsDialog(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              controller.currentClasse.name,
              style: textTheme.headlineMedium?.copyWith(
                // Use textTheme for consistency
                fontWeight: FontWeight.bold,
                color: colorScheme.primary, // Use primary color for prominence
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ); // Dynamic color
              }
              if (controller.students.isEmpty) {
                return Center(
                  child: Text(
                    'Nenhum aluno encontrado',
                    style: textTheme.bodyLarge?.copyWith(
                      // Use textTheme
                      fontSize: 18,
                      color: colorScheme.onSurface.withOpacity(
                        0.6,
                      ), // Dynamic color
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.students.length,
                itemBuilder: (context, index) {
                  final student = controller.students[index];
                  final isStudentGloballyActive = student.active ?? true;

                  return Card(
                    key: ValueKey(student.id),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color:
                        colorScheme.surface, // Dynamic color: card background
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme
                            .primaryContainer, // Dynamic: a light tint of primary
                        child: Icon(
                          Icons.person,
                          color: colorScheme
                              .onPrimaryContainer, // Dynamic: icon color on primary container
                        ),
                      ),
                      title: Text(
                        student.name,
                        style: textTheme.titleSmall?.copyWith(
                          // Use textTheme
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color:
                              colorScheme.onSurface, // Dynamic color for title
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      trailing: CustomPopupMenu(
                        items: [
                          CustomPopupMenuItem(
                            label: 'Transferir',
                            icon: Icons.swap_horiz,

                            onTap: () => _showConfirmationDialog(
                              context: context,
                              title: 'Confirmar Transferência',
                              message:
                                  'Você irá transferir o aluno "${student.name}" para outra turma. Ele será removido desta turma e adicionado à nova. Deseja continuar?',
                              onConfirm: () async {
                                await controller.loadClassesForTransfer();
                                _showTransferStudentDialog(
                                  context,
                                  student,
                                ); // Pass context
                              },
                            ),
                          ),
                          CustomPopupMenuItem(
                            label: 'Duplicar',
                            icon: Icons.copy,

                            onTap: () => _showConfirmationDialog(
                              context: context,
                              title: 'Confirmar Duplicação',
                              message:
                                  'Você irá duplicar o aluno "${student.name}" para outra turma. Ele permanecerá nesta turma e será adicionado à nova. Deseja continuar?',
                              onConfirm: () async {
                                await controller.loadClassesForTransfer();
                                _showCopyStudentDialog(
                                  context,
                                  student,
                                ); // Pass context
                              },
                            ),
                          ),
                          CustomPopupMenuItem(
                            label: isStudentGloballyActive
                                ? 'Arquivar'
                                : 'Aluno já Arquivado',
                            icon: isStudentGloballyActive
                                ? Icons.archive
                                : Icons.do_not_disturb_alt,

                            onTap: () {
                              if (isStudentGloballyActive) {
                                // Se o aluno está ativo globalmente, permite arquivar
                                _showArchiveStudentDialog(
                                  context,
                                  student,
                                ); // Pass context
                              } else {
                                // Se o aluno já está arquivado globalmente, exibe um aviso
                                Get.dialog(
                                  CustomDialog(
                                    title: 'Ação não permitida',
                                    content: Text(
                                      // Use Text widget, style it dynamically
                                      'Este aluno já está arquivado globalmente. Não é possível arquivá-lo novamente ou reativá-lo por aqui.',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text(
                                          'Fechar',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                          ),
                                        ), // Dynamic
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: controller.formKey,
              child: CustomTextField(
                validator: Validatorless.required('campo obrigatório!'),
                hintText: 'Digite um aluno por linha',
                controller: controller.studentNameEC,
                minLines: 1,
                maxLines: 5,
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: colorScheme.primary,
                  ), // Dynamic color
                  onPressed: () async {
                    if (controller.formKey.currentState!.validate()) {
                      await controller.addStudent();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNÇÕES AUXILIARES DA CLASSE StudentsPage (DENTRO DO ESCOPO DA CLASSE) ---

  Future<void> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    Get.dialog(
      CustomDialog(
        title: title,

        content: Text(
          message,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ), // Dynamic
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: colorScheme.primary),
            ), // Dynamic
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Fechar o diálogo de confirmação ANTES de executar onConfirm
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary, // Dynamic
              foregroundColor: colorScheme.onPrimary, // Dynamic
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showImportStudentsDialog(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ); // Dynamic
        }
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: 600,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Importar Alunos',
                        style: textTheme.titleMedium?.copyWith(
                          // Dynamic
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface, // Dynamic
                        ),
                      ),
                      Icon(
                        Icons.file_download,
                        size: 24,
                        color: colorScheme.primary,
                      ), // Dynamic
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Ano Letivo',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ), // Dynamic
                    ),
                    value: controller.selectedYear.value,
                    items: controller.availableYears.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(
                          year.toString(),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ), // Dynamic
                      );
                    }).toList(),
                    onChanged: (year) {
                      controller.selectedYear.value = year;
                      controller.loadAvailableClasses();
                    },
                    hint: controller.availableYears.isEmpty
                        ? Text(
                            'Nenhum ano disponível',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ) // Dynamic
                        : Text(
                            'Selecione o ano',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ), // Dynamic
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Classe>(
                    decoration: InputDecoration(
                      labelText: 'Turma de Origem',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ), // Dynamic
                    ),
                    value: controller.selectedClasseToImport.value,
                    items: controller.availableClasses.map((classe) {
                      return DropdownMenuItem(
                        value: classe,
                        child: Text(
                          classe.name,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ), // Dynamic
                      );
                    }).toList(),
                    onChanged: (classe) {
                      controller.selectedClasseToImport.value = classe;
                      controller.loadStudentsFromSelectedClasse();
                    },
                    hint: controller.availableClasses.isEmpty
                        ? Text(
                            'Nenhuma turma disponível',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ) // Dynamic
                        : Text(
                            'Selecione a turma de origem',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ), // Dynamic
                  ),
                  const SizedBox(height: 20),
                  if (controller.isLoading.value)
                    Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ) // Dynamic
                  else if (controller.selectedClasseToImport.value != null &&
                      controller.studentsFromSelectedClasse.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          'Nenhum aluno nesta turma.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ), // Dynamic
                    )
                  else if (controller.selectedClasseToImport.value == null)
                    const SizedBox.shrink()
                  else
                    Expanded(
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: controller.studentsFromSelectedClasse.length,
                        itemBuilder: (context, index) {
                          final student =
                              controller.studentsFromSelectedClasse[index];
                          return Obx(
                            () => CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              value: controller.selectedStudentsToImport
                                  .contains(student),
                              title: Text(
                                student.name,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ), // Dynamic
                              ),
                              onChanged: (selected) {
                                controller.toggleStudentToImport(
                                  student,
                                  selected ?? false,
                                );
                              },
                              activeColor: colorScheme.primary, // Dynamic
                              checkColor: colorScheme.onPrimary, // Dynamic
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: colorScheme.outlineVariant,
                        ), // Dynamic
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          foregroundColor: colorScheme.primary, // Dynamic
                        ),
                        onPressed: () => Get.back(),
                        child: const Text('CANCELAR'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          backgroundColor: colorScheme.primary, // Dynamic
                          foregroundColor: colorScheme.onPrimary, // Dynamic
                        ),
                        onPressed: () async {
                          await controller
                              .importSelectedStudentsToCurrentClasse();
                        },
                        child: const Text('IMPORTAR'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      barrierDismissible: false,
    );
  }

  void _showTransferStudentDialog(BuildContext context, Student student) {
    // Added context
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ); // Dynamic
        }
        return CustomDialog(
          title: 'Transferir Aluno',

          icon: Icons.swap_horiz,

          content: controller.classesForTransfer.isEmpty
              ? Text(
                  'Nenhuma outra turma disponível para transferência.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ) // Dynamic
              : CustomDrop<Classe>(
                  items: controller.classesForTransfer,
                  value: controller.selectedClasseForTransfer.value,
                  labelBuilder: (c) => '${c.name} (${c.schoolYear})',
                  onChanged: (c) =>
                      controller.selectedClasseForTransfer.value = c,
                  hint: 'Selecione uma turma de destino',
                ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colorScheme.primary),
              ), // Dynamic
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.moveStudentAcrossClasses(student);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, // Dynamic
                foregroundColor: colorScheme.onPrimary, // Dynamic
              ),
              child: const Text('Transferir'),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }

  void _showCopyStudentDialog(BuildContext context, Student student) {
    // Added context
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          ); // Dynamic
        }
        return CustomDialog(
          title: 'Duplicar Aluno',

          icon: Icons.copy,

          content: controller.classesForTransfer.isEmpty
              ? Text(
                  'Nenhuma outra turma disponível para duplicar.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ) // Dynamic
              : CustomDrop<Classe>(
                  items: controller.classesForTransfer,
                  value: controller.selectedClasseForTransfer.value,
                  labelBuilder: (c) => '${c.name} (${c.schoolYear})',
                  onChanged: (c) =>
                      controller.selectedClasseForTransfer.value = c,
                  hint: 'Selecione uma turma de destino',
                ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colorScheme.primary),
              ), // Dynamic
            ),
            ElevatedButton(
              onPressed: () async {
                final targetClasse = controller.selectedClasseForTransfer.value;
                if (targetClasse == null || targetClasse.id == null) {
                  Get.dialog(
                    CustomErrorDialog(
                      title: 'Atenção',
                      message: 'Selecione uma turma de destino válida.',
                    ),
                  );
                  return;
                }
                await controller.duplicateStudentToOtherClasse(
                  student,
                  targetClasse.id!,
                );
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, // Dynamic
                foregroundColor: colorScheme.onPrimary, // Dynamic
              ),
              child: const Text('Duplicar'),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }

  void _showArchiveStudentDialog(BuildContext context, Student student) {
    // Added context
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final message =
        'Tem certeza que deseja ARQUIVAR o aluno "${student.name}" desta turma (${controller.currentClasse.name})?\n\n'
        'A matrícula deste aluno nesta turma será inativada.\n\n'
        'Se esta for a ÚLTIMA matrícula ativa do aluno em qualquer turma, ele será arquivado GLOBALMENTE e não poderá ser reativado. Você ainda poderá acessá-lo no histórico.\n\n'
        'Esta ação é irreversível.';

    Get.dialog(
      CustomConfirmationDialogWithCode(
        title: 'Arquivar Aluno',

        message: message,

        confirmButtonText: 'Arquivar',

        onConfirm: () async {
          await controller.archiveStudentFromCurrentClasse(student);
        },
      ),
      barrierDismissible: false,
    );
  }
}
