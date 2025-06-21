import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/modules/classes/classes_controller.dart';

class ClassesPage extends GetView<ClassesController> {
  const ClassesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Turmas',
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
         /*  IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Filtrar',
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Filtros',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.purple.shade800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Dropdown para Ano Letivo
                          Obx(
                            () => DropdownButtonFormField<int>(
                              value: controller.selectedFilterYear.value,
                              decoration: const InputDecoration(
                                labelText: 'Ano Letivo',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  List.generate(
                                        11,
                                        (i) => DateTime.now().year - 5 + i,
                                      )
                                      .map(
                                        (year) => DropdownMenuItem(
                                          value: year,
                                          child: Text(year.toString()),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (year) {
                                if (year != null) {
                                  controller.selectedFilterYear.value = year;
                                  controller.readClasses(
                                    year: year,
                                    active:
                                        controller.showOnlyActiveClasses.value,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Switch para Ativo/Arquivado
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: 0.75,
                                  child: Switch(
                                    value:
                                        controller.showOnlyActiveClasses.value,
                                    onChanged: (val) {
                                      controller.showOnlyActiveClasses.value =
                                          val;
                                      controller.readClasses(
                                        active: val,
                                        year:
                                            controller.selectedFilterYear.value,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    controller.showOnlyActiveClasses.value
                                        ? 'Ativas'
                                        : 'Arquivadas',
                                    style: TextStyle(
                                      color:
                                          controller.showOnlyActiveClasses.value
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ), */
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.classes.isEmpty) {
          return Center(
            child: Text(
              'Nenhuma turma encontrada para ${controller.selectedFilterYear.value}.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          final filteredClasses = controller.classes.toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          return ListView.builder(
            itemCount: filteredClasses.length,
            itemBuilder: (context, index) {
              final classe = filteredClasses[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade100,
                    child: Icon(Icons.class_, color: Colors.purple.shade800),
                  ),
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
                  subtitle:
                      classe.description != null &&
                          classe.description!.isNotEmpty
                      ? Text(
                          classe.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        )
                      : null,
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
                        onTap: () async => await _showEditClasseDialog(classe),
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
          );
        }
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
                  if (value == null ||
                      int.tryParse(value) == null ||
                      value.length != 4) {
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
    // O texto da mensagem que será exibido no diálogo de confirmação.
    final String message =
        'Você tem certeza que deseja ARQUIVAR a turma "${Constants.capitalize(classe.name)} (${classe.schoolYear})"?\n\n'
        'Ao arquivar, esta turma será removida da lista de turmas ativas, mas todos os seus dados e históricos (alunos, chamadas, etc.) serão MANTIDOS para consulta.\n\n'
        'Você poderá acessá-la posteriormente na tela de Relatórios para visualizar seus dados.';

    await Get.dialog(
      CustomConfirmationDialogWithCode(
        title: 'Arquivar Turma',
        message: message,
        confirmButtonText: 'Sim, Arquivar',
        onConfirm: () async {
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
      ),
      barrierDismissible:
          false, // Impede que o diálogo seja fechado ao clicar fora
    );
  }
}
