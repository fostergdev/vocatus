import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';

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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.currentClasse.name,
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
                colorScheme.primary.withValues(alpha: 0.9),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.file_copy),
            tooltip: 'Importar alunos de outra turma',
            color: colorScheme.onPrimary,
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
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                );
              }
              if (controller.students.isEmpty) {
                return Center(
                  child: Text(
                    'Nenhum aluno encontrado',
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                    color: colorScheme.surface,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        student.name,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: colorScheme.onSurface,
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
                                if (context.mounted) {
                                  _showTransferStudentDialog(context, student);
                                }
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
                                if (context.mounted) {
                                  _showCopyStudentDialog(context, student);
                                }
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
                                _showArchiveStudentDialog(context, student);
                              } else {
                                Get.dialog(
                                  CustomDialog(
                                    title: 'Ação não permitida',
                                    content: Text(
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
                                        ),
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
                  icon: Icon(Icons.add, color: colorScheme.primary),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
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
          );
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Icon(
                        Icons.file_download,
                        size: 24,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Ano Letivo',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
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
                        ),
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
                          )
                        : Text(
                            'Selecione o ano',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Classe>(
                    decoration: InputDecoration(
                      labelText: 'Turma de Origem',
                      border: const OutlineInputBorder(),
                      labelStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
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
                        ),
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
                          )
                        : Text(
                            'Selecione a turma de origem',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  if (controller.isLoading.value)
                    Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
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
                      ),
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
                                ),
                              ),
                              onChanged: (selected) {
                                controller.toggleStudentToImport(
                                  student,
                                  selected ?? false,
                                );
                              },
                              activeColor: colorScheme.primary,
                              checkColor: colorScheme.onPrimary,
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          foregroundColor: colorScheme.primary,
                        ),
                        onPressed: () => Get.back(),
                        child: const Text('CANCELAR'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
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
                )
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
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.moveStudentAcrossClasses(student);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary),
          );
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
                )
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
              ),
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
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
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
