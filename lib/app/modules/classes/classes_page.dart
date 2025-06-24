import 'dart:developer' as developer;
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
    developer.log('ClassesPage build chamada', name: 'ClassesPage');
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
          /* CustomPopupMenu(
            textAlign: TextAlign.center,
            iconColor: Colors.white,
            // Troque o ícone do menu de "more_vert" para "calendar_today" apenas aqui:
            // Basta adicionar o parâmetro 'icon' ao CustomPopupMenu.
            icon: Icons.calendar_today,
            items: [
              for (var year in List.generate(4, (i) => DateTime.now().year + i))
                CustomPopupMenuItem(
                  label: year.toString(),
                  onTap: () {
                    developer.log(
                      'Ano selecionado no filtro: $year',
                      name: 'ClassesPage',
                    );
                    controller.selectedFilterYear.value = year;
                    controller.readClasses(
                      year: year,
                      active: controller.showOnlyActiveClasses.value,
                    );
                  },
                ),
            ],
          ), */
        ],
      ),
      body: Obx(() {
        developer.log(
          'Atualizando lista de turmas. isLoading: ${controller.isLoading.value}',
          name: 'ClassesPage',
        );
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.classes.isEmpty) {
          developer.log(
            'Nenhuma turma encontrada para ${controller.selectedFilterYear.value}',
            name: 'ClassesPage',
          );
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
          developer.log(
            'Exibindo ${filteredClasses.length} turmas',
            name: 'ClassesPage',
          );
          return ListView.builder(
            itemCount: filteredClasses.length,
            itemBuilder: (context, index) {
              final classe = filteredClasses[index];
              developer.log(
                'Renderizando card da turma: ${classe.name} (${classe.schoolYear})',
                name: 'ClassesPage',
              );
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
                        onTap: () async {
                          developer.log(
                            'Abrindo alunos da turma ${classe.name}',
                            name: 'ClassesPage',
                          );
                          await Get.toNamed(
                            '/students/home',
                            arguments: classe,
                          );
                        },
                      ),
                      CustomPopupMenuItem(
                        label: 'Editar',
                        icon: Icons.edit,
                        onTap: () async {
                          developer.log(
                            'Editando turma ${classe.name}',
                            name: 'ClassesPage',
                          );
                          await _showEditClasseDialog(classe);
                        },
                      ),
                      if (classe.active ?? true)
                        CustomPopupMenuItem(
                          label: 'Arquivar',
                          icon: Icons.archive,
                          onTap: () async {
                            developer.log(
                              'Arquivando turma ${classe.name}',
                              name: 'ClassesPage',
                            );
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
          developer.log(
            'Abrindo diálogo para adicionar turma',
            name: 'ClassesPage',
          );
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
    developer.log('Diálogo de adicionar turma aberto', name: 'ClassesPage');
    controller.classeNameEC.clear();
    controller.classeSchoolYearEC.text = DateTime.now().year.toString();
    final currentYear = DateTime.now().year;
    /* final years = List.generate(11, (i) => currentYear - 5 + i); */

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
          /*   const SizedBox(height: 16),
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
                  developer.log(
                    'Ano letivo selecionado no cadastro: $val',
                    name: 'ClassesPage',
                  );
                }
              },
              validator: (val) => val == null ? 'Ano obrigatório!' : null,
            ), */
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (controller.formKey.currentState!.validate()) {
            try {
              final schoolYear = int.parse(controller.classeSchoolYearEC.text);
              developer.log(
                'Salvando nova turma: ${controller.classeNameEC.text} ($schoolYear)',
                name: 'ClassesPage',
              );
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
              developer.log(
                'Erro ao adicionar turma: $e',
                name: 'ClassesPage',
                error: e,
              );
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
          developer.log('Cancelou adicionar turma', name: 'ClassesPage');
          Get.back();
        },
        child: const Text('Cancelar'),
      ),
    );
  }

  Future<void> _showEditClasseDialog(Classe classe) async {
    developer.log(
      'Diálogo de edição aberto para turma: ${classe.name}',
      name: 'ClassesPage',
    );
    controller.classeEditNameEC.text = classe.name;
    controller.classeSchoolYearEC.text = classe.schoolYear.toString();

    final currentYear = DateTime.now().year;
    // Garante que o ano da classe editada esteja na lista
    final years = List.generate(4, (i) => currentYear + i);
    final yearsSet = {...years, classe.schoolYear};
    final yearsList = yearsSet.toList()..sort();

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
            DropdownButtonFormField<int>(
              value: classe.schoolYear,
              decoration: const InputDecoration(
                labelText: 'Ano Letivo',
                border: OutlineInputBorder(),
              ),
              items: yearsList
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
          if (controller.formEditKey.currentState!.validate()) {
            try {
              final updatedSchoolYear = int.parse(
                controller.classeSchoolYearEC.text,
              );
              developer.log(
                'Salvando edição da turma: ${controller.classeEditNameEC.text} ($updatedSchoolYear)',
                name: 'ClassesPage',
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
              controller.selectedYear.value = updatedSchoolYear;
              controller.classeEditNameEC.clear();
              controller.classeSchoolYearEC.clear();
              Get.back();
            } catch (e) {
              developer.log(
                'Erro ao editar turma: $e',
                name: 'ClassesPage',
                error: e,
              );
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
          developer.log('Cancelou edição de turma', name: 'ClassesPage');
          Get.back();
        },
        child: const Text('Cancelar'),
      ),
    );
  }

  Future<void> _showArchiveClasseDialog(Classe classe) async {
    final String message =
        'Você tem certeza que deseja ARQUIVAR a turma "${Constants.capitalize(classe.name)} (${classe.schoolYear})"?\n\n'
        'Ao arquivar, esta turma será removida da lista de turmas ativas, mas todos os seus dados e históricos (alunos, chamadas, etc.) serão MANTIDOS para consulta.\n\n'
        'Você poderá acessá-la posteriormente na tela de Relatórios para visualizar seus dados.';

    developer.log(
      'Solicitação de arquivamento da turma: ${classe.name}',
      name: 'ClassesPage',
    );
    await Get.dialog(
      CustomConfirmationDialogWithCode(
        title: 'Arquivar Turma',
        message: message,
        confirmButtonText: 'Sim, Arquivar',
        onConfirm: () async {
          try {
            developer.log(
              'Confirmou arquivamento da turma: ${classe.name}',
              name: 'ClassesPage',
            );

            await controller.archiveClasse(classe);
          } catch (e) {
            developer.log(
              'Erro ao arquivar turma: $e',
              name: 'ClassesPage',
              error: e,
            );
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
      barrierDismissible: false,
    );
  }
}
