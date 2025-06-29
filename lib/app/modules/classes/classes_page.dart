import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Constants.primaryColor,
                Colors.purple.shade800,
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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [],
      ),
      body: Obx(() {
        developer.log(
          'Atualizando lista de turmas. isLoading: ${controller.isLoading.value}',
          name: 'ClassesPage',
        );
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Constants.primaryColor),
                const SizedBox(height: 16),
                Text(
                  'Carregando turmas...',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        } else if (controller.classes.isEmpty) {
          developer.log(
            'Nenhuma turma encontrada para ${controller.selectedFilterYear.value}',
            name: 'ClassesPage',
          );
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 80,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 20),
                Text(
                  'Nenhuma turma encontrada para o ano ${controller.selectedFilterYear.value}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Que tal adicionar uma nova turma agora?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
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
              final isActive = classe.active ?? true;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: Colors.purple.shade100.withAlpha(
                  (0.6 * 255).toInt(),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isActive
                        ? Constants.primaryColor.withAlpha((0.1 * 255).toInt())
                        : Colors.grey.shade100,
                    child: Icon(
                      Icons.school,
                      color: isActive
                          ? Constants.primaryColor
                          : Colors.grey.shade600,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    Constants.capitalize(classe.name),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isActive
                          ? Colors.purple.shade900
                          : Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (classe.description != null &&
                          classe.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          classe.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${classe.schoolYear}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (!isActive)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ARQUIVADA',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: CustomPopupMenu(
                    icon: Icons.more_vert,
                    items: [
                      CustomPopupMenuItem(
                        label: 'Alunos',
                        icon: Icons.people_outline,
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
                      if (isActive)
                        CustomPopupMenuItem(
                          label: 'Tarefas',
                          icon: Icons.assignment_outlined,
                          onTap: () async {
                            developer.log(
                              'Abrindo tarefas da turma ${classe.name}',
                              name: 'ClassesPage',
                            );
                            await Get.toNamed(
                              '/homework/home',
                              arguments: classe,
                            );
                          },
                        ),
                      CustomPopupMenuItem(
                        label: 'Editar',
                        icon: Icons.edit_outlined,
                        onTap: () async {
                          developer.log(
                            'Editando turma ${classe.name}',
                            name: 'ClassesPage',
                          );
                          await _showEditClasseDialog(classe);
                        },
                      ),
                      if (isActive)
                        CustomPopupMenuItem(
                          label: 'Arquivar',
                          icon: Icons.archive_outlined,
                          onTap: () async {
                            developer.log(
                              'Arquivando turma ${classe.name}',
                              name: 'ClassesPage',
                            );
                            await _showArchiveClasseDialog(classe);
                          },
                        )
                      else
                        CustomPopupMenuItem(
                          label: 'Relatório',
                          icon: Icons.description_outlined,
                          onTap: () {
                            Get.snackbar(
                              'Relatório',
                              'Abrir relatório da turma arquivada: ${classe.name}',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.blue.shade100,
                              colorText: Colors.blue.shade800,
                            );
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
        onPressed: () async => await _showAddClasseDialog(),
        tooltip: 'Adicionar nova turma',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add_circle_outline, size: 28),
      ),
    );
  }

  Future<void> _showAddClasseDialog() async {
    developer.log('Diálogo de adicionar turma aberto', name: 'ClassesPage');
    controller.classeNameEC.clear();
    controller.classeDescriptionEC.clear();

    final currentYear = DateTime.now().year;

    await Get.dialog(
      CustomDialog(
        title: 'Adicionar Turma',
        icon: Icons.group_add,
        content: Form(
          key: controller.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Constants.primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Constants.primaryColor.withValues(alpha: .3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Constants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ano Letivo: $currentYear',
                      style: TextStyle(
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                validator: Validatorless.required('Nome obrigatório!'),
                maxLines: 1,
                controller: controller.classeNameEC,
                hintText: 'Nome da turma (Ex: 3º Ano A)',
                decoration: InputDecoration(
                  labelText: 'Nome da Turma',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Constants.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                maxLines: 3,
                controller: controller.classeDescriptionEC,
                hintText: 'Breve descrição da turma (Opcional)',
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Constants.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.formKey.currentState!.validate()) {
                try {
                  final currentYear = DateTime.now().year;
                  developer.log(
                    'Salvando nova turma: ${controller.classeNameEC.text} ($currentYear)',
                    name: 'ClassesPage',
                  );
                  await controller.createClasse(
                    Classe(
                      name: controller.classeNameEC.text,
                      description: controller.classeDescriptionEC.text.isEmpty
                          ? null
                          : controller.classeDescriptionEC.text,
                      schoolYear: currentYear,
                      active: true,
                    ),
                  );
                  controller.selectedYear.value = currentYear;
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showEditClasseDialog(Classe classe) async {
    developer.log(
      'Diálogo de edição aberto para turma: ${classe.name}',
      name: 'ClassesPage',
    );
    controller.classeEditNameEC.text = classe.name;
    controller.classeDescriptionEC.text = classe.description ?? '';

    final currentYear = DateTime.now().year;

    await Get.dialog(
      CustomDialog(
        title: 'Editar Turma',
        icon: Icons.edit_calendar,
        content: Form(
          key: controller.formEditKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Constants.primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Constants.primaryColor.withValues(alpha: .3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Constants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ano Letivo: $currentYear',
                      style: TextStyle(
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                validator: Validatorless.required('Nome obrigatório!'),
                maxLines: 1,
                controller: controller.classeEditNameEC,
                hintText: 'Nome da turma',
                decoration: InputDecoration(
                  labelText: 'Nome da Turma',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Constants.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                maxLines: 3,
                controller: controller.classeDescriptionEC,
                hintText: 'Breve descrição da turma (Opcional)',
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Constants.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancelar'),
          ),              ElevatedButton(
                onPressed: () async {
                  if (controller.formEditKey.currentState!.validate()) {
                    try {
                      final currentYear = DateTime.now().year;
                      developer.log(
                        'Salvando edição da turma: ${controller.classeEditNameEC.text} ($currentYear)',
                        name: 'ClassesPage',
                      );
                      await controller.updateClasse(
                        Classe(
                          id: classe.id,
                          name: controller.classeEditNameEC.text,
                          description: controller.classeDescriptionEC.text.isEmpty
                              ? null
                              : controller.classeDescriptionEC.text,
                          schoolYear: currentYear,
                          createdAt: classe.createdAt,
                          active: classe.active,
                        ),
                      );
                      controller.selectedYear.value = currentYear;
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
      barrierDismissible: false,
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
        title: 'Confirmar Arquivamento',
        message: message,
        confirmButtonText: 'Arquivar Turma',
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