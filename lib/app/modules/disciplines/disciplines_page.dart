import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/constants/constants.dart'; // Mantenha, mas sem primaryColor
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
// import 'package:vocatus/app/core/widgets/custom_popbutton.dart'; // Remova se não estiver usando
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/models/discipline.dart';
import './disciplines_controller.dart';

class DisciplinesPage extends GetView<DisciplinesController> {
  const DisciplinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Disciplinas',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary, // Texto da AppBar
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.9), // Usa a cor primária do tema
                colorScheme.primary, // Usa a cor primária do tema
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
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Cor dos ícones da AppBar
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colorScheme.primary), // Cor do tema
          );
        }
        if (controller.disciplines.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined, // Ícone mais relevante para disciplinas
                  size: 80,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
                const SizedBox(height: 20),
                Text(
                  'Nenhuma disciplina encontrada',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Adicione uma nova disciplina para começar.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
                    color: colorScheme.surface, // Fundo do Card
                    surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
                    shadowColor: colorScheme.shadow.withOpacity(0.1), // Sombra suave
                    child: ListTile(
                      title: Text(
                        Constants.capitalize(discipline.name),
                        style: textTheme.titleMedium?.copyWith( // Usar titleMedium
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface, // Cor do texto do título
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
                                await _showEditDisciplineDialog(context, discipline, colorScheme, textTheme),
                          ),
                          CustomPopupMenuItem(
                            label: 'Excluir',
                            icon: Icons.delete,
                            onTap: () async =>
                                await _showDeleteDisciplineDialog(context, discipline, colorScheme, textTheme),
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
      floatingActionButton: FloatingActionButton( // Usar FloatingActionButton normal
        onPressed: () async {
          await _showAddDisciplineDialog(context, colorScheme, textTheme);
        },
        tooltip: 'Adicionar Disciplina',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Mais arredondado
        backgroundColor: colorScheme.primary, // Fundo do FAB
        foregroundColor: colorScheme.onPrimary, // Ícone/texto do FAB
        elevation: 8,
        child: const Icon(Icons.add, size: 28), // Ícone de '+' padrão
      ),
    );
  }

  // --- Diálogo de Adicionar Disciplina ---
  Future<void> _showAddDisciplineDialog(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) async {
    controller.nameEC.clear();
    await Get.defaultDialog(
      title: 'Adicionar Disciplina',
      titleStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface), // Estilo do título do Get.defaultDialog
      backgroundColor: colorScheme.surface, // Fundo do diálogo
      content: Form(
        key: controller.formKey,
        child: Column(
          children: [
            CustomTextField(
              validator: Validatorless.required('Nome obrigatório!'),
              maxLines: 1,
              controller: controller.nameEC,
              hintText: 'Nome da Disciplina',
              // CustomTextField já cuida das cores de texto/bordas
            ),
            const SizedBox(height: 16),
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
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary, // Fundo do botão Confirmar
          foregroundColor: colorScheme.onPrimary, // Texto do botão Confirmar
        ),
        child: const Text('Adicionar'),
      ),
      cancel: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surfaceVariant, // Fundo do botão Cancelar (opcional)
          foregroundColor: colorScheme.onSurfaceVariant, // Texto do botão Cancelar
        ),
        child: const Text('Cancelar'),
      ),
    );
  }

  // --- Diálogo de Editar Disciplina ---
  Future<void> _showEditDisciplineDialog(BuildContext context, Discipline discipline, ColorScheme colorScheme, TextTheme textTheme) async {
    controller.nameEditEC.text = discipline.name;
    await Get.defaultDialog(
      title: 'Editar Disciplina',
      titleStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
      backgroundColor: colorScheme.surface,
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
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        child: const Text('Salvar'),
      ),
      cancel: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surfaceVariant,
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
        child: const Text('Cancelar'),
      ),
    );
  }

  // --- Diálogo de Excluir Disciplina ---
  Future<void> _showDeleteDisciplineDialog(BuildContext context, Discipline discipline, ColorScheme colorScheme, TextTheme textTheme) async {
    await Get.defaultDialog(
      title: 'Excluir Disciplina',
      titleStyle: textTheme.titleLarge?.copyWith(color: colorScheme.error), // Título de exclusão em vermelho
      backgroundColor: colorScheme.errorContainer, // Fundo do diálogo de exclusão
      content: Text(
        'Você tem certeza que deseja excluir a disciplina "${discipline.name}"?',
        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onErrorContainer), // Texto da mensagem
        textAlign: TextAlign.center, // Centraliza o texto da mensagem
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.onSurfaceVariant, // Fundo do botão "Cancelar" (neutro)
          foregroundColor: colorScheme.surface, // Cor do texto do botão "Cancelar" (contrasta com onSurfaceVariant)
        ),
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
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.error, // Fundo do botão "Excluir" (vermelho de erro)
          foregroundColor: colorScheme.onError, // Texto do botão "Excluir"
        ),
        child: const Text('Excluir'),
      ),
    );
  }
}