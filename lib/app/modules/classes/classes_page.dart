import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/constants/constants.dart'; // Mantenha, mas já sem primaryColor
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
// import 'package:vocatus/app/core/widgets/custom_popbutton.dart'; // Remova se não estiver usando
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

    developer.log('ClassesPage build chamada', name: 'ClassesPage');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Turmas',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary, // Texto da AppBar
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary, // Cor de fundo da AppBar
        elevation: 8,

        iconTheme: IconThemeData(
          color: colorScheme.onPrimary,
        ), // Cor dos ícones da AppBar
        actions: const [
          // Adicione ações da AppBar se houver
        ],
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
                CircularProgressIndicator(
                  color: colorScheme.primary,
                ), // Indicador com cor primária
                const SizedBox(height: 16),
                Text(
                  'Carregando turmas...',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ), // Cor do texto
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
                  color: colorScheme.onSurfaceVariant.withOpacity(
                    0.3,
                  ), // Cor do ícone
                ),
                const SizedBox(height: 20),
                Text(
                  'Nenhuma turma encontrada para o ano ${controller.selectedFilterYear.value}.',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant, // Cor do texto
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Que tal adicionar uma nova turma agora?',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ), // Cor do texto
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
                // Fundo do Card e sombra
                color: colorScheme.surface,
                surfaceTintColor: colorScheme.primaryContainer,
                shadowColor: colorScheme.shadow.withOpacity(
                  0.2,
                ), // Sombra com cor do tema
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isActive
                        ? colorScheme.primary.withOpacity(
                            0.1,
                          ) // Fundo do avatar ativo
                        : colorScheme.surfaceVariant, // Fundo do avatar inativo
                    child: Icon(
                      Icons.school,
                      color: isActive
                          ? colorScheme
                                .primary // Cor do ícone ativo
                          : colorScheme
                                .onSurfaceVariant, // Cor do ícone inativo
                      size: 28,
                    ),
                  ),
                  title: Text(
                    Constants.capitalize(classe.name),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? colorScheme
                                .onSurface // Cor do título ativo
                          : colorScheme
                                .onSurfaceVariant, // Cor do título inativo
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
                            color: colorScheme
                                .onSurfaceVariant, // Cor da descrição
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
                            color: colorScheme
                                .onSurfaceVariant, // Cor do ícone de calendário
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${classe.schoolYear}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme
                                  .onSurfaceVariant, // Cor do texto do ano
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
                              color: colorScheme
                                  .errorContainer, // Fundo para "Arquivada"
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ARQUIVADA',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme
                                    .onErrorContainer, // Texto para "Arquivada"
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: CustomPopupMenu(
                    // icon: Icons.more_vert, // CustomPopupMenu já tem ícone padrão e cor do tema
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
                        label: 'Relatórios',
                        icon: Icons.assessment,
                        onTap: () {
                          developer.log(
                            'Abrindo relatório unificado da turma ${classe.name}',
                            name: 'ClassesPage',
                          );
                          Get.toNamed(
                            '/reports/class-unified',
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
                          await _showEditClasseDialog(
                            context,
                            classe,
                            colorScheme,
                            textTheme,
                          ); // Passa context e colorScheme
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
                            await _showArchiveClasseDialog(
                              context,
                              classe,
                              colorScheme,
                            ); // Passa context e colorScheme
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
      floatingActionButton: FloatingActionButton(
        // Usar FloatingActionButton normal para um tamanho padrão maior
        onPressed: () async => await _showAddClasseDialog(
          context,
          colorScheme,
          textTheme,
        ), // Passa context, colorScheme e textTheme
        tooltip: 'Adicionar nova turma',
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ), // Um pouco mais arredondado
        backgroundColor: colorScheme.primary, // Fundo do FAB
        foregroundColor: colorScheme.onPrimary, // Ícone/texto do FAB
        elevation: 8,
        child: const Icon(
          Icons.add,
          size: 28,
        ), // Ícone de '+' padrão é mais comum e reconhecível
      ),
    );
  }

  // --- Diálogo de Adicionar Turma ---
  Future<void> _showAddClasseDialog(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) async {
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
                  color: colorScheme.primaryContainer, // Fundo do container
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3), // Borda
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: colorScheme.primary, // Cor do ícone
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ano Letivo: $currentYear',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer, // Cor do texto
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
                // A decoração padrão do CustomTextField já é responsiva ao tema
                // Não é necessário redefinir `decoration` aqui a menos que haja um motivo específico
                // para sobrescrever o estilo padrão que vem do CustomTextField.
                // Exemplo se você realmente precisar sobrescrever:
                // decoration: InputDecoration(
                //   labelText: 'Nome da Turma',
                //   border: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   focusedBorder: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(12),
                //     borderSide: BorderSide(
                //       color: colorScheme.primary, // Usando cor do tema
                //       width: 2,
                //     ),
                //   ),
                // ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                maxLines: 3,
                controller: controller.classeDescriptionEC,
                hintText: 'Breve descrição da turma (Opcional)',
                // Novamente, o CustomTextField já é responsivo ao tema.
                // decoration: InputDecoration(
                //   labelText: 'Descrição',
                //   alignLabelWithHint: true,
                //   border: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   focusedBorder: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(12),
                //     borderSide: BorderSide(
                //       color: colorScheme.primary, // Usando cor do tema
                //       width: 2,
                //     ),
                //   ),
                // ),
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
              foregroundColor:
                  colorScheme.onSurfaceVariant, // Cor do texto do botão
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
              backgroundColor: colorScheme.primary, // Cor de fundo do botão
              foregroundColor: colorScheme.onPrimary, // Cor do texto do botão
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

  // --- Diálogo de Editar Turma ---
  Future<void> _showEditClasseDialog(
    BuildContext context,
    Classe classe,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) async {
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
                  color: colorScheme.primaryContainer, // Fundo do container
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3), // Borda
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: colorScheme.primary, // Cor do ícone
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ano Letivo: $currentYear',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer, // Cor do texto
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
                // A decoração já é responsiva ao tema.
              ),
              const SizedBox(height: 16),
              CustomTextField(
                maxLines: 3,
                controller: controller.classeDescriptionEC,
                hintText: 'Breve descrição da turma (Opcional)',
                // A decoração já é responsiva ao tema.
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
              foregroundColor:
                  colorScheme.onSurfaceVariant, // Cor do texto do botão
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
              backgroundColor: colorScheme.primary, // Cor de fundo do botão
              foregroundColor: colorScheme.onPrimary, // Cor do texto do botão
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

  // --- Diálogo de Arquivar Turma ---
  Future<void> _showArchiveClasseDialog(
    BuildContext context,
    Classe classe,
    ColorScheme colorScheme,
  ) async {
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
