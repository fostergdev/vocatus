import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';
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
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (_) => Dialog(
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
                            Obx(() {
                              return DropdownButtonFormField<
                                ClasseFilterStatus
                              >(
                                decoration: const InputDecoration(
                                  labelText: 'Status da Turma',
                                  border: OutlineInputBorder(),
                                ),
                                value: controller.selectedFilterStatus.value,
                                items: ClasseFilterStatus.values.map((status) {
                                  String label;
                                  switch (status) {
                                    case ClasseFilterStatus.active:
                                      label = 'Ativas';
                                      break;
                                    case ClasseFilterStatus.archived:
                                      label = 'Arquivadas';
                                      break;
                                    case ClasseFilterStatus.all:
                                      label = 'Todas';
                                      break;
                                  }
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(label),
                                  );
                                }).toList(),
                                onChanged: (status) {
                                  controller.selectedFilterStatus.value =
                                      status;
                                  controller.loadAvailableYears();
                                },
                                hint: const Text('Selecione o status'),
                              );
                            }),
                            const SizedBox(height: 16),
                            Obx(() {
                              int? dropdownValue =
                                  controller.selectedYear.value == 0
                                  ? null
                                  : controller.selectedYear.value;
                              return DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Ano Letivo',
                                  border: OutlineInputBorder(),
                                ),
                                value: dropdownValue,
                                items: controller.availableYears.map((year) {
                                  return DropdownMenuItem(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }).toList(),
                                onChanged: (year) {
                                  controller.selectedYear.value = year ?? 0;
                                  controller.loadAvailableClasses();
                                },
                                hint: controller.availableYears.isEmpty
                                    ? const Text('Nenhum ano disponível')
                                    : const Text('Selecione o ano'),
                              );
                            }),
                            const SizedBox(height: 16),
                            Obx(() {
                              return DropdownButtonFormField<Classe>(
                                decoration: const InputDecoration(
                                  labelText: 'Turma de Origem',
                                  border: OutlineInputBorder(),
                                ),
                                value: controller.selectedClasseToImport.value,
                                items: controller.availableClasses.map((
                                  classe,
                                ) {
                                  return DropdownMenuItem(
                                    value: classe,
                                    child: Text(
                                      '${classe.name} ',
                                    ) /* (${classe.schoolYear}) - ${classe.active! ? "Ativa" : "Arquivada"} */,
                                  );
                                }).toList(),
                                onChanged: (classe) {
                                  controller.selectedClasseToImport.value =
                                      classe;
                                  controller.loadStudentsFromSelectedClasse();
                                },
                                hint: controller.availableClasses.isEmpty
                                    ? const Text('Nenhuma turma disponível')
                                    : const Text('Selecione a turma de origem'),
                              );
                            }),
                            const SizedBox(height: 20),
                            Obx(() {
                              if (controller
                                  .studentsFromSelectedClasse
                                  .isEmpty) {
                                if (controller.selectedClasseToImport.value !=
                                    null) {
                                  return const Expanded(
                                    child: Center(
                                      child: Text('Nenhum aluno nesta turma.'),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }
                              return Expanded(
                                child: ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: controller
                                      .studentsFromSelectedClasse
                                      .length,
                                  itemBuilder: (context, index) {
                                    final student = controller
                                        .studentsFromSelectedClasse[index];
                                    return Obx(
                                      () => CheckboxListTile(
                                        contentPadding: EdgeInsets.zero,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        value: controller
                                            .selectedStudentsToImport
                                            .contains(student),
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
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                ),
                              );
                            }),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('CANCELAR'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (controller
                                        .selectedStudentsToImport
                                        .isEmpty) {
                                      return;
                                    }
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
                  ),
                );
              }
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
              controller.students.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
              return ListView.builder(
                itemCount: controller.students.length,
                itemBuilder: (context, index) {
                  final student = controller.students[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
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
                      trailing: CustomPopupMenu(
                        items: [
                          CustomPopupMenuItem(
                            label: 'Editar',
                            icon: Icons.edit,
                            onTap: () => _showEditStudentDialog(student),
                          ),
                          CustomPopupMenuItem(
                            label: 'Transferir',
                            icon: Icons.swap_horiz,
                            onTap: () async {
                              await controller.loadClassesForTransfer();
                              _showTransferStudentDialog(student);
                            },
                          ),
                          CustomPopupMenuItem(
                            label: 'Colar',
                            icon: Icons.paste,
                            onTap: () async {
                              controller.studentEditNameEC.text = student.name;
                              Get.snackbar(
                                'Colado',
                                'Nome do aluno colado no campo de edição!',
                              );
                            },
                          ),
                          CustomPopupMenuItem(
                            label: 'Apagar',
                            icon: Icons.delete,
                            onTap: () => _showDeleteStudentDialog(student),
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

  void _showEditStudentDialog(Student student) {
    controller.studentEditNameEC.text = student.name;
    showDialog(
      context: Get.context!,
      builder: (_) => CustomDialog(
        title: 'Editar Aluno',
        icon: Icons.edit,
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: controller.formEditKey,
            child: CustomTextField(
              validator: Validatorless.required('campo obrigatório!'),
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
                Student updatedStudent = student.copyWith(
                  name: controller.studentEditNameEC.text.trim(),
                );
                await controller.updateStudent(updatedStudent);
                controller.studentEditNameEC.clear();
              }
              Get.back();
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showTransferStudentDialog(Student student) {
    showDialog(
      context: Get.context!,
      builder: (_) => CustomDialog(
        title: 'Transferir Aluno',
        icon: Icons.swap_horiz,
        content: Obx(() {
          return CustomDrop<Classe>(
            items: controller.classesForTransfer,
            value: controller.selectedClasseForTransfer.value,
            labelBuilder: (c) => '${c.name} (${c.schoolYear})',
            onChanged: (c) => controller.selectedClasseForTransfer.value = c,
            hint: 'Selecione uma turma de destino',
          );
        }),
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
      ),
      barrierDismissible: false,
    );
  }

  void _showDeleteStudentDialog(Student student) {
    showDialog(
      context: Get.context!,
      builder: (_) => CustomDialog(
        title: 'Apagar Aluno',
        content: Text(
          'Tem certeza que deseja apagar o aluno "${student.name}"?',
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await controller.deleteStudent(student);
              Get.back();
            },
            child: const Text('Apagar'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
