import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/models/discipline.dart';
import './disciplines_controller.dart';

class DisciplinesPage extends GetView<DisciplinesController> {
  const DisciplinesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Disciplinas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple.shade800,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.disciplines.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma disciplina encontrada',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        controller.disciplines.sort((a, b) => a.name.compareTo(b.name));
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.disciplines.length,
                itemBuilder: (context, index) {
                  final discipline = controller.disciplines[index];
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
                        Constants.capitalize(discipline.name),
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
                            onTap: () async =>
                                await _showEditDisciplineDialog(discipline),
                          ),
                          CustomPopupMenuItem(
                            label: 'Excluir',
                            icon: Icons.delete,
                            onTap: () async =>
                                await _showDeleteDisciplineDialog(discipline),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 70,
              child: Center(
                child: Text(
                  'Total de Disciplinas: ${controller.disciplines.length}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          await _showAddDisciplineDialog();
        },
        tooltip: 'Adicionar Disciplina',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.purple.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddDisciplineDialog() async {
    controller.nameEC.clear();
    await Get.defaultDialog(
      title: 'Adicionar Disciplina',
      content: Form(
        key: controller.formKey,

        child: Column(
          children: [
            CustomTextField(
              validator: Validatorless.required('nome obrigatório!'),
              maxLines: 1,
              controller: controller.nameEC,
              hintText: 'Nome da Disciplina',
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (controller.formKey.currentState!.validate()) {
            try {
              await controller.createDiscipline(
                Discipline(name: controller.nameEC.text),
              );
              controller.nameEC.clear();
              Get.back();
            } catch (e) {
              Get.dialog(
                CustomErrorDialog(title: 'Erro', message: e.toString()),
                barrierDismissible: false,
              );
            }
          }
        },
        child: const Text('Adicionar'),
      ),
      cancel: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Cancelar'),
      ),
    );
  }

  Future<void> _showEditDisciplineDialog(Discipline discipline) async {
    controller.nameEditEC.text = discipline.name;
    await Get.defaultDialog(
      title: 'Editar Disciplina',
      content: Form(
        key: controller.formEditKey,

        child: Column(
          children: [
            CustomTextField(
              validator: Validatorless.required('Nome obrigatório!'),
              maxLines: 1,
              controller: controller.nameEditEC,
              hintText: 'Nome da Disciplina',
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (controller.formEditKey.currentState!.validate()) {
            try {
              await controller.updateDiscipline(
                Discipline(id: discipline.id, name: controller.nameEditEC.text),
              );
              controller.nameEditEC.clear();
              Get.back();
            } catch (e) {
              Get.dialog(
                CustomErrorDialog(title: 'Erro', message: e.toString()),
                barrierDismissible: false,
              );
            }
          }
        },
        child: const Text('Salvar'),
      ),
      cancel: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Cancelar'),
      ),
    );
  }

  Future<void> _showDeleteDisciplineDialog(Discipline discipline) async {
    await Get.defaultDialog(
      title: 'Excluir Disciplina',
      content: Text(
        'Você tem certeza que deseja excluir a disciplina "${discipline.name}"?',
        style: const TextStyle(fontSize: 16),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Cancelar'),
      ),
      cancel: ElevatedButton(
        onPressed: () async {
          try {
            await controller.deleteDiscipline(discipline.id!);
            Get.back();
          } catch (e) {
            Get.dialog(
              CustomErrorDialog(title: 'Erro', message: e.toString()),
              barrierDismissible: false,
            );
          }
        },
        child: const Text('Excluir'),
      ),
    );
  }
}
