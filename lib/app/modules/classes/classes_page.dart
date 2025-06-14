import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/models/classe.dart';
import './classes_controller.dart';

class ClassesPage extends GetView<ClassesController> {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Turmas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple.shade800,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Obx(
            () => IconButton(
              icon: Text(
                controller.selectedYear.value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              tooltip: 'Filtrar por ano',
              onPressed: () async {
                final yearController = TextEditingController(
                  text: controller.selectedYear.value.toString(),
                );
                await Get.defaultDialog(
                  title: 'Filtrar por Ano',
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: const InputDecoration(
                          hintText: 'Digite o ano',
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ano obrigatório';
                          }
                          if (value.length != 4) return 'Digite 4 dígitos';
                          if (int.tryParse(value) == null) {
                            return 'Apenas números';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  confirm: ElevatedButton(
                    onPressed: () {
                      final year = int.tryParse(yearController.text);
                      if (year != null && yearController.text.length == 4) {
                        controller.selectedYear.value = year;
                        controller.readClasses(year: year);
                        Get.back();
                      }
                    },
                    child: const Text('OK'),
                  ),
                  cancel: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancelar'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredClasses = controller.classes.toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return Column(
          children: [
            if (filteredClasses.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Nenhuma turma ativa encontrada para ${controller.selectedYear.value}.',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredClasses.length,
                  itemBuilder: (context, index) {
                    final classe = filteredClasses[index];
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
                          Constants.capitalize(classe.name),
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
                              label: 'Alunos',
                              icon: Icons.people,
                              onTap: () async => await Get.toNamed(
                                '/students/home',
                                arguments: classe,
                              ),
                            ),
                            CustomPopupMenuItem(
                              label: 'Editar',
                              icon: Icons.edit,
                              onTap: () async =>
                                  await _showEditClasseDialog(classe),
                            ),
                            if (classe.active ?? true)
                              CustomPopupMenuItem(
                                label: 'Arquivar',
                                icon: Icons.archive,
                                onTap: () async {
                                  await _showArchiveClasseDialog(classe);
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          await _showAddClasseDialog();
        },
        tooltip: 'Adicionar turma',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.purple.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showAddClasseDialog() async {
    controller.classeNameEC.clear();
    controller.classeSchoolYearEC.text = DateTime.now().year.toString();
    final currentYear = DateTime.now().year;
    final years = List.generate(11, (i) => currentYear - 5 + i);

    await Get.defaultDialog(
      title: 'Adicionar Turma',
      content: Form(
        key: controller.formKey,
        child: Column(
          children: [
            CustomTextField(
              validator: Validatorless.required('Nome obrigatório!'),
              maxLines: 1,
              controller: controller.classeNameEC,
              hintText: 'Nome da turma (Ex: 3º Ano A)',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value:
                  int.tryParse(controller.classeSchoolYearEC.text) ??
                  currentYear,
              decoration: const InputDecoration(
                labelText: 'Ano Letivo',
                border: OutlineInputBorder(),
              ),
              items: years
                  .map(
                    (year) => DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  controller.classeSchoolYearEC.text = val.toString();
                }
              },
              validator: (val) => val == null ? 'Ano obrigatório!' : null,
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (controller.formKey.currentState!.validate()) {
            try {
              final schoolYear = int.parse(controller.classeSchoolYearEC.text);
              await controller.createClasse(
                Classe(
                  name: controller.classeNameEC.text,
                  schoolYear: schoolYear,
                  active: true,
                ),
              );
              controller.selectedYear.value = schoolYear;
              controller.classeNameEC.clear();
              controller.classeSchoolYearEC.clear();
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

  Future<void> _showEditClasseDialog(Classe classe) async {
    controller.classeEditNameEC.text = classe.name;
    controller.classeSchoolYearEC.text = classe.schoolYear.toString();
    await Get.defaultDialog(
      title: 'Editar Turma',
      content: Form(
        key: controller.formEditKey,
        child: Column(
          children: [
            CustomTextField(
              validator: Validatorless.required('Nome obrigatório!'),
              maxLines: 1,
              controller: controller.classeEditNameEC,
              hintText: 'Nome da turma',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              validator: Validatorless.multiple([
                Validatorless.required('Ano obrigatório!'),
                Validatorless.number('Ano inválido!'),
                (value) {
                  if (value == null || int.tryParse(value) == null || value.length != 4) {
                    return 'Ano inválido (Ex: 2050)';
                  }
                  return null;
                },
              ]),
              keyboardType: TextInputType.number,
              controller: controller.classeSchoolYearEC,
              hintText: 'Ano Letivo (Ex: 2050)',
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (controller.formEditKey.currentState!.validate()) {
            try {
              final updatedSchoolYear = int.parse(
                controller.classeSchoolYearEC.text,
              );
              await controller.updateClasse(
                Classe(
                  id: classe.id,
                  name: controller.classeEditNameEC.text,
                  description: classe.description,
                  schoolYear: updatedSchoolYear,
                  createdAt: classe.createdAt,
                  active: classe.active,
                ),
              );
              controller.selectedYear.value =
                  updatedSchoolYear; // <-- Atualiza o filtro para o ano editado
              controller.classeEditNameEC.clear();
              controller.classeSchoolYearEC.clear();
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

  Future<void> _showArchiveClasseDialog(Classe classe) async {
    await Get.defaultDialog(
      title: 'Arquivar Turma',
      middleText:
          'Você tem certeza que deseja ARQUIVAR a turma "${Constants.capitalize(classe.name)} (${classe.schoolYear})"?\n\n'
          'Ao arquivar, esta turma será removida da lista de turmas ativas, mas todos os seus dados e históricos (alunos, chamadas, etc.) serão MANTIDOS para consulta.\n\n'
          'Você poderá acessá-la posteriormente na tela de Relatórios para visualizar seus dados.',
      confirm: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                await controller.updateClasse(
                  Classe(
                    id: classe.id,
                    name: classe.name,
                    description: classe.description,
                    schoolYear: classe.schoolYear,
                    createdAt: classe.createdAt,
                    active: false,
                  ),
                );
                Get.back();
              } catch (e) {
                Get.dialog(
                  CustomErrorDialog(
                    title: 'Erro ao Arquivar',
                    message: e.toString(),
                  ),
                  barrierDismissible: false,
                );
              }
            },
            child: const Text('Sim, Arquivar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
