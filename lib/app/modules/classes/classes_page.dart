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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Turmas',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        elevation: 8,
        iconTheme: IconThemeData(
          color: colorScheme.onPrimary,
        ),
        actions: const [
          
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Carregando turmas...',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        } else if (controller.classes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 80,
                  color: colorScheme.onSurfaceVariant.withValues(alpha:
                    0.3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nenhuma turma encontrada para o ano ${controller.selectedFilterYear.value}.',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Que tal adicionar uma nova turma agora?',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        } else {
          final filteredClasses = controller.classes.toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          return ListView.builder(
            itemCount: filteredClasses.length,
            itemBuilder: (context, index) {
              final classe = filteredClasses[index];
              final isActive = classe.active ?? true;
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: colorScheme.surface,
                surfaceTintColor: colorScheme.primaryContainer,
                shadowColor: colorScheme.shadow.withValues(alpha:
                  0.2,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isActive
                        ? colorScheme.primary.withValues(alpha:
                            0.1,
                          )
                        : colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.school,
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    Constants.capitalize(classe.name),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
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
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${classe.schoolYear}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ARQUIVADA',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: CustomPopupMenu(
                    items: [
                      CustomPopupMenuItem(
                        label: 'Alunos',
                        icon: Icons.people_outline,
                        onTap: () async {
                          await Get.toNamed(
                            '/students/home',
                            arguments: classe,
                          );
                        },
                      ),
                      CustomPopupMenuItem(
                        label: 'Relatórios',
                        icon: Icons.assessment,
                        onTap: () {
                          Get.toNamed(
                            '/reports/home',
                            arguments: classe,
                          );
                        },
                      ),
                      CustomPopupMenuItem(
                        label: 'Editar',
                        icon: Icons.edit_outlined,
                        onTap: () async {
                          await _showEditClasseDialog(
                            context,
                            classe,
                            colorScheme,
                            textTheme,
                          );
                        },
                      ),
                      if (isActive)
                        CustomPopupMenuItem(
                          label: 'Arquivar',
                          icon: Icons.archive_outlined,
                          onTap: () async {
                            await _showArchiveClasseDialog(
                              context,
                              classe,
                              colorScheme,
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
        onPressed: () async => await _showAddClasseDialog(
          context,
          colorScheme,
          textTheme,
        ),
        tooltip: 'Adicionar nova turma',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 8,
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
    );
  }

  Future<void> _showAddClasseDialog(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) async {
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
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ano Letivo: $currentYear',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
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
              ),
              const SizedBox(height: 16),
              CustomTextField(
                maxLines: 3,
                controller: controller.classeDescriptionEC,
                hintText: 'Breve descrição da turma (Opcional)',
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
              foregroundColor: colorScheme.onSurfaceVariant,
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
                  Get.dialog(
                    CustomErrorDialog(title: 'Erro', message: e.toString()),
                    barrierDismissible: false,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
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

  Future<void> _showEditClasseDialog(
    BuildContext context,
    Classe classe,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) async {
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
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ano Letivo: $currentYear',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
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
              ),
              const SizedBox(height: 16),
              CustomTextField(
                maxLines: 3,
                controller: controller.classeDescriptionEC,
                hintText: 'Breve descrição da turma (Opcional)',
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
              foregroundColor: colorScheme.onSurfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.formEditKey.currentState!.validate()) {
                try {
                  final currentYear = DateTime.now().year;
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
                  Get.dialog(
                    CustomErrorDialog(title: 'Erro', message: e.toString()),
                    barrierDismissible: false,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
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

  Future<void> _showArchiveClasseDialog(
    BuildContext context,
    Classe classe,
    ColorScheme colorScheme,
  ) async {
    final String message =
        'Você tem certeza que deseja ARQUIVAR a turma "${Constants.capitalize(classe.name)} (${classe.schoolYear})"?\n\n'
        'Ao arquivar, esta turma será removida da lista de turmas ativas, mas todos os seus dados e históricos (alunos, chamadas, etc.) serão MANTIDOS para consulta.\n\n'
        'Você poderá acessá-la posteriormente na tela de Relatórios para visualizar seus dados.';

    await Get.dialog(
      CustomConfirmationDialogWithCode(
        title: 'Confirmar Arquivamento',
        message: message,
        confirmButtonText: 'Arquivar Turma',
        onConfirm: () async {
          try {
            await controller.archiveClasse(classe);
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
      barrierDismissible: false,
    );
  }
}