import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart'; // Importação do dialog com código
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/student.dart';
import './students_controller.dart';

class StudentsPage extends GetView<StudentsController> {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alunos de ${controller.currentClasse.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Constants.primaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Importar alunos de outra turma',
            color: Colors.white,
            onPressed: () async {
              controller.resetImportFilters();
              _showImportStudentsDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Text(
            controller.currentClasse.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.students.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum aluno encontrado',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.students.length,
                itemBuilder: (context, index) {
                  final student = controller.students[index];
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
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: Icon(
                          Icons.person,
                          color: Colors.purple.shade800,
                        ),
                      ),
                      title: Text(
                        student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Constants.primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        (student.active ?? true)
                            ? 'Status: Ativo'
                            : 'Status: Arquivado',
                        style: TextStyle(
                          fontSize: 14,
                          color: (student.active ?? true)
                              ? Colors.green.shade700
                              : Colors.deepOrange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: CustomPopupMenu(
                        items: [
                          CustomPopupMenuItem(
                            label: 'Editar',
                            icon: Icons.edit,
                            onTap: () => _showConfirmationDialog(
                              context: context,
                              title: 'Confirmar Edição',
                              message:
                                  'Você irá editar os dados do aluno "${student.name}". Deseja continuar?',
                              onConfirm: () => _showEditStudentDialog(student),
                            ),
                          ),
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
                                _showTransferStudentDialog(student);
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
                                _showCopyStudentDialog(student);
                              },
                            ),
                          ),
                          CustomPopupMenuItem(
                            label: (student.active ?? true)
                                ? 'Arquivar'
                                : 'Ação não permitida',
                            icon: (student.active ?? true)
                                ? Icons.archive
                                : Icons.do_not_disturb_alt,
                            onTap: () => _showArchiveStudentDialog(student),
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
                  icon: const Icon(Icons.add),
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
    Get.dialog(
      CustomDialog(
        title: title,
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showEditStudentDialog(Student student) {
    controller.studentEditNameEC.text = student.name;
    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomDialog(
          title: 'Editar Aluno',
          icon: Icons.edit,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: controller.formEditKey,
              child: CustomTextField(
                validator: Validatorless.required('Campo obrigatório!'),
                controller: controller.studentEditNameEC,
                maxLines: 1,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.formEditKey.currentState!.validate()) {
                  await controller.updateStudent(
                    student.copyWith(
                      name: controller.studentEditNameEC.text.trim(),
                    ),
                  );
                  controller.studentEditNameEC.clear();
                  Get.back();
                }
              },
              child: const Text('Atualizar'),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }

  // Diálogo de Importação de Alunos (sem filtros)
  void _showImportStudentsDialog(BuildContext context) {
    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
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
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Importar Alunos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.file_download, size: 24),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Ano Letivo',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedYear.value,
                    items: controller.availableYears.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (year) {
                      controller.selectedYear.value = year;
                      controller.loadAvailableClasses();
                    },
                    hint: controller.availableYears.isEmpty
                        ? const Text('Nenhum ano disponível')
                        : const Text('Selecione o ano'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Classe>(
                    decoration: const InputDecoration(
                      labelText: 'Turma de Origem',
                      border: OutlineInputBorder(),
                    ),
                    value: controller.selectedClasseToImport.value,
                    items: controller.availableClasses.map((classe) {
                      return DropdownMenuItem(
                        value: classe,
                        child: Text(
                          '${classe.name} (${classe.schoolYear}) - ${classe.active! ? "Ativa" : "Arquivada"}',
                        ),
                      );
                    }).toList(),
                    onChanged: (classe) {
                      controller.selectedClasseToImport.value = classe;
                      controller.loadStudentsFromSelectedClasse();
                    },
                    hint: controller.availableClasses.isEmpty
                        ? const Text('Nenhuma turma disponível')
                        : const Text('Selecione a turma de origem'),
                  ),
                  const SizedBox(height: 20),
                  if (controller.isLoading.value)
                    const Center(child: CircularProgressIndicator())
                  else if (controller.selectedClasseToImport.value != null &&
                      controller.studentsFromSelectedClasse.isEmpty)
                    const Expanded(
                      child: Center(child: Text('Nenhum aluno nesta turma.')),
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
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: controller.selectedStudentsToImport.contains(
                              student,
                            ),
                            title: Text(
                              student.name,
                              style: const TextStyle(fontSize: 16),
                            ),
                            onChanged: (selected) {
                              controller.toggleStudentToImport(
                                student,
                                selected ?? false,
                              );
                            },
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(height: 1),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text('CANCELAR'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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

  void _showTransferStudentDialog(Student student) {
    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomDialog(
          title: 'Transferir Aluno',
          icon: Icons.swap_horiz,
          content: controller.classesForTransfer.isEmpty
              ? const Text('Nenhuma outra turma disponível para transferência.')
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
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.moveStudentAcrossClasses(student);
              },
              child: const Text('Transferir'),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }

  void _showCopyStudentDialog(Student student) {
    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomDialog(
          title: 'Duplicar Aluno',
          icon: Icons.copy,
          content: controller.classesForTransfer.isEmpty
              ? const Text('Nenhuma outra turma disponível para duplicar.')
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
              child: const Text('Cancelar'),
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
              child: const Text('Duplicar'),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }

  void _showArchiveStudentDialog(Student student) {
    final isCurrentlyActive = student.active ?? true;

    // Se o aluno já está inativo, mostre um diálogo de "Ação não permitida"
    if (!isCurrentlyActive) {
      Get.dialog(
        CustomDialog(
          title: 'Ação não permitida',
          content: const Text(
            'Este aluno já está arquivado e não pode ser reativado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Fechar'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      return; // Sai da função
    }

    // Se o aluno está ativo, mostre o diálogo de confirmação com código para ARQUIVAR
    final message =
        'Tem certeza que deseja ARQUIVAR o aluno "${student.name}"?\n\n'
        'ATENÇÃO: Esta ação é irreversível. Não será possível reativar este aluno depois.\n\n'
        'Você ainda poderá acessar os dados deste aluno para consulta/histórico, mas não poderá reativá-lo.';

    Get.dialog(
      CustomConfirmationDialogWithCode(
        title: 'Arquivar Aluno',
        message: message,
        confirmButtonText: 'Arquivar',
        onConfirm: () async {
          // Esta função será chamada SOMENTE se o código for digitado corretamente
          await controller.archiveStudent(
            student,
          ); // Chamada para a nova função no controller
          // O Get.back() já é tratado pelo ConfirmationDialogWithCode
        },
      ),
      barrierDismissible: false,
    );
  }
}
