import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';
// import 'package:vocatus/app/core/widgets/custom_popbutton.dart'; // Remova se não estiver usando
import 'package:vocatus/app/models/homework.dart';
import 'package:vocatus/app/models/discipline.dart';
import './homework_controller.dart';

class HomeworkPage extends GetView<HomeworkController> {
  const HomeworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tarefas de ${controller.currentClasse.name}',
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
        actions: [
          CustomPopupMenu(
            icon: Icons.filter_list,
            items: [
              CustomPopupMenuItem(
                label: 'Todos',
                icon: Icons.all_inbox,
                onTap: () => controller.clearAllFilters(),
              ),
              CustomPopupMenuItem(
                label: 'Pendentes',
                icon: Icons.pending,
                onTap: () => controller.setFilterStatus(HomeworkStatus.pending),
              ),
              CustomPopupMenuItem(
                label: 'Concluídas',
                icon: Icons.check_circle,
                onTap: () => controller.setFilterStatus(HomeworkStatus.completed),
              ),
              CustomPopupMenuItem(
                label: 'Canceladas',
                icon: Icons.cancel,
                onTap: () => controller.setFilterStatus(HomeworkStatus.cancelled),
              ),
              CustomPopupMenuItem(
                label: 'Em Atraso',
                icon: Icons.warning,
                onTap: () => controller.setFilterOverdue(true),
              ),
              CustomPopupMenuItem(
                label: 'Hoje',
                icon: Icons.today,
                onTap: () => controller.setFilterToday(true),
              ),
              CustomPopupMenuItem(
                label: 'Próximas',
                icon: Icons.upcoming,
                onTap: () => controller.setFilterUpcoming(true),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(colorScheme, textTheme), // Passa colorScheme e textTheme
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary)); // Cor do tema
              }
              if (controller.homeworks.isEmpty) {
                return _buildEmptyState(colorScheme, textTheme); // Passa colorScheme e textTheme
              }
              return _buildHomeworkList(context, colorScheme, textTheme); // Passa context e theme
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton( // Usar FloatingActionButton normal
        onPressed: () => _showAddHomeworkDialog(context, colorScheme, textTheme), // Passa context e theme
        backgroundColor: colorScheme.primary, // Fundo do FAB
        foregroundColor: colorScheme.onPrimary, // Ícone/texto do FAB
        elevation: 8,
        child: const Icon(Icons.add, size: 28), // Ícone de '+' padrão
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${DateTime.now().year}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary, // Cor do ano
              ),
            ),
          ),
          Obx(() => Text(
            '${controller.homeworks.length} tarefa(s)',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant, // Cor do texto de contagem
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.4), // Cor do ícone
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa encontrada',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant, // Cor do texto
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para adicionar uma nova tarefa',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7), // Cor do texto
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkList(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.homeworks.length,
      itemBuilder: (context, index) {
        final homework = controller.homeworks[index];
        return _buildHomeworkCard(homework, context, colorScheme, textTheme); // Passa context e theme
      },
    );
  }

  Widget _buildHomeworkCard(Homework homework, BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final isOverdue = controller.isOverdue(homework);
    final isDueToday = controller.isDueToday(homework);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue
              ? colorScheme.error.withOpacity(0.3) // Borda para atrasado
              : isDueToday
                  ? colorScheme.secondary.withOpacity(0.3) // Borda para hoje
                  : Colors.transparent, // Borda transparente
          width: 1,
        ),
      ),
      color: colorScheme.surface, // Fundo do Card
      surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
      shadowColor: colorScheme.shadow.withOpacity(0.1), // Sombra
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showHomeworkDetailsDialog(context, homework, colorScheme, textTheme), // Passa context e theme
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      homework.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface, // Cor do título da tarefa
                      ),
                    ),
                  ),
                  _buildStatusChip(homework.status, colorScheme, textTheme), // Passa theme
                ],
              ),
              if (homework.discipline != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.subject,
                      size: 16,
                      color: colorScheme.onSurfaceVariant, // Cor do ícone
                    ),
                    const SizedBox(width: 4),
                    Text(
                      homework.discipline!.name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant, // Cor do texto
                      ),
                    ),
                  ],
                ),
              ],
              if (homework.description != null && homework.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  homework.description!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant, // Cor da descrição
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isOverdue
                            ? colorScheme.error // Cor para atrasado
                            : isDueToday
                                ? colorScheme.secondary // Cor para hoje
                                : colorScheme.onSurfaceVariant, // Cor padrão
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.formatDueDate(homework.dueDate),
                        style: textTheme.bodyMedium?.copyWith(
                          color: isOverdue
                              ? colorScheme.error
                              : isDueToday
                                  ? colorScheme.secondary
                                  : colorScheme.onSurfaceVariant,
                          fontWeight: isOverdue || isDueToday
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    color: colorScheme.surfaceContainerHigh, // Fundo do menu
                    onSelected: (value) => _handleHomeworkAction(value, homework, context, colorScheme, textTheme), // Passa context e theme
                    itemBuilder: (context) => [
                      if (homework.status == HomeworkStatus.pending)
                        PopupMenuItem(
                          value: 'complete',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: colorScheme.tertiary), // Cor para concluída (verde)
                              const SizedBox(width: 8),
                              Text('Marcar como Concluída', style: TextStyle(color: colorScheme.onSurface)),
                            ],
                          ),
                        ),
                      if (homework.status == HomeworkStatus.completed)
                        PopupMenuItem(
                          value: 'pending',
                          child: Row(
                            children: [
                              Icon(Icons.pending, color: colorScheme.secondary), // Cor para pendente (laranja/amarelo)
                              const SizedBox(width: 8),
                              Text('Marcar como Pendente', style: TextStyle(color: colorScheme.onSurface)),
                            ],
                          ),
                        ),
                      if (homework.status != HomeworkStatus.cancelled)
                        PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: colorScheme.error), // Cor para cancelar (vermelho)
                              const SizedBox(width: 8),
                              Text('Cancelar', style: TextStyle(color: colorScheme.onSurface)),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: colorScheme.primary), // Cor para editar (primária)
                            const SizedBox(width: 8),
                            Text('Editar', style: TextStyle(color: colorScheme.onSurface)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: colorScheme.error), // Cor para excluir (vermelho)
                            const SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: colorScheme.onSurface)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(HomeworkStatus status, ColorScheme colorScheme, TextTheme textTheme) {
    Color statusColor = controller.getStatusColor(status); // Esta função ainda retorna Colors.red, Colors.green etc.
    // Mapeie as cores de status para as cores do tema
    Color thematicStatusColor;
    switch (status) {
      case HomeworkStatus.pending:
        thematicStatusColor = colorScheme.secondary; // Geralmente laranja/amarelo
        break;
      case HomeworkStatus.completed:
        thematicStatusColor = colorScheme.tertiary; // Geralmente verde
        break;
      case HomeworkStatus.cancelled:
        thematicStatusColor = colorScheme.error; // Vermelho
        break;
      default:
        thematicStatusColor = colorScheme.onSurfaceVariant; // Cor neutra para outros status
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: thematicStatusColor.withOpacity(0.1), // Fundo suave da cor do status
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: thematicStatusColor.withOpacity(0.3), // Borda mais escura
        ),
      ),
      child: Text(
        controller.getStatusDisplayName(status),
        style: textTheme.labelLarge?.copyWith( // Usar labelLarge
          fontSize: 12, // Mantendo o tamanho original
          color: thematicStatusColor, // Cor do texto principal
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleHomeworkAction(String action, Homework homework, BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    switch (action) {
      case 'complete':
        controller.markAsCompleted(homework);
        break;
      case 'pending':
        controller.markAsPending(homework);
        break;
      case 'cancel':
        controller.markAsCancelled(homework);
        break;
      case 'edit':
        _showEditHomeworkDialog(context, homework, colorScheme, textTheme);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, homework, colorScheme);
        break;
    }
  }

  void _showAddHomeworkDialog(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    controller.clearForm();
    _showHomeworkFormDialog(context, 'Adicionar Tarefa', false, null, colorScheme, textTheme);
  }

  void _showEditHomeworkDialog(BuildContext context, Homework homework, ColorScheme colorScheme, TextTheme textTheme) {
    controller.prepareEditHomework(homework);
    _showHomeworkFormDialog(context, 'Editar Tarefa', true, homework, colorScheme, textTheme);
  }

  void _showHomeworkFormDialog(
    BuildContext context, 
    String dialogTitle, 
    bool isEdit, 
    [Homework? homework, ColorScheme? colorScheme, TextTheme? textTheme]
  ) {
    colorScheme = colorScheme ?? Theme.of(context).colorScheme; // Garante que o colorScheme exista
    textTheme = textTheme ?? Theme.of(context).textTheme; // Garante que o textTheme exista

    Get.dialog(
      CustomDialog(
        title: dialogTitle,
        icon: isEdit ? Icons.edit : Icons.add,
        content: Form(
          key: controller.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: controller.titleEC,
                hintText: 'Título da Tarefa',
                validator: Validatorless.required('Título é obrigatório'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.descriptionEC,
                hintText: 'Descrição (opcional)',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Obx(() => CustomDrop<Discipline>(
                items: controller.availableDisciplines,
                value: controller.selectedDiscipline.value,
                labelBuilder: (discipline) => discipline.name,
                onChanged: (discipline) => controller.selectedDiscipline.value = discipline,
                hint: 'Selecione a Disciplina (opcional)',
              )),
              const SizedBox(height: 16),
              // Campo de Seleção de Data de Entrega
              Obx(() => InkWell(
                onTap: () => _selectDueDate(context, colorScheme!), // Passa colorScheme
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme!.outline), // Borda do tema
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.surfaceVariant, // Fundo do campo
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant), // Ícone do tema
                      const SizedBox(width: 12),
                      Text(
                        controller.selectedDueDate.value != null
                            ? 'Data de Entrega: ${controller.selectedDueDate.value!.day}/${controller.selectedDueDate.value!.month}/${controller.selectedDueDate.value!.year}'
                            : 'Selecionar Data de Entrega',
                        style: textTheme?.bodyLarge?.copyWith(
                          color: controller.selectedDueDate.value != null
                              ? colorScheme.onSurface // Cor do texto preenchido
                              : colorScheme.onSurfaceVariant, // Cor do hint
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 16),
              Obx(() => CustomDrop<HomeworkStatus>(
                items: HomeworkStatus.values,
                value: controller.selectedStatus.value,
                labelBuilder: (status) => controller.getStatusDisplayName(status),
                onChanged: (status) => controller.selectedStatus.value = status!,
                hint: 'Selecione o Status',
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearForm();
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant, // Cor do tema
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.formKey.currentState!.validate()) {
                if (isEdit && homework != null) {
                  final updatedHomework = homework.copyWith(
                    title: controller.titleEC.text.trim(),
                    description: controller.descriptionEC.text.trim().isEmpty
                        ? null
                        : controller.descriptionEC.text.trim(),
                    disciplineId: controller.selectedDiscipline.value?.id,
                    dueDate: controller.selectedDueDate.value!,
                    status: controller.selectedStatus.value,
                  );
                  await controller.updateHomework(updatedHomework);
                } else {
                  await controller.createHomework();
                }
                Get.back(); // Fecha o diálogo após a ação
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary, // Cor do tema
              foregroundColor: colorScheme.onPrimary, // Cor do tema
            ),
            child: Text(isEdit ? 'Atualizar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  void _selectDueDate(BuildContext context, ColorScheme colorScheme) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDueDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: colorScheme.primary,
              onSurface: colorScheme.onSurface,
              onPrimary: colorScheme.onPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.selectedDueDate.value = picked;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Homework homework, ColorScheme colorScheme) {
    Get.dialog(
      CustomConfirmationDialogWithCode(
        title: 'Excluir Tarefa',
        message: 'Tem certeza que deseja excluir a tarefa "${homework.title}"?',
        confirmButtonText: 'EXCLUIR',
        onConfirm: () => controller.deleteHomework(homework),
      ),
    );
  }

  void _showHomeworkDetailsDialog(BuildContext context, Homework homework, ColorScheme colorScheme, TextTheme textTheme) {
    Get.dialog(
      AlertDialog(
        // Fundo do diálogo de detalhes
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        title: Text(
          homework.title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (homework.discipline != null) ...[
              Row(
                children: [
                  Icon(Icons.subject, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Disciplina: ${homework.discipline!.name}',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Entrega: ${homework.dueDate.day}/${homework.dueDate.month}/${homework.dueDate.year}',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Status: ${controller.getStatusDisplayName(homework.status)}',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                ),
              ],
            ),
            if (homework.description != null && homework.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Descrição:',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                homework.description!,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showEditHomeworkDialog(context, homework, colorScheme, textTheme);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }
}