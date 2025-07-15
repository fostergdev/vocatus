import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';

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
            color: colorScheme.onPrimary, 
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha:0.9), 
                colorScheme.primary, 
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
        iconTheme: IconThemeData(color: colorScheme.onPrimary), 
        actions: [
          CustomPopupMenu(
            icon: Icons.filter_list,
            iconColor: colorScheme.onPrimary,
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
          _buildHeader(colorScheme, textTheme), 
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary)); 
              }
              if (controller.homeworks.isEmpty) {
                return _buildEmptyState(colorScheme, textTheme); 
              }
              return _buildHomeworkList(context, colorScheme, textTheme); 
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small( 
        onPressed: () => _showAddHomeworkDialog(context, colorScheme, textTheme), 
        backgroundColor: colorScheme.primary, 
        foregroundColor: colorScheme.onPrimary, 
        elevation: 8,
        child: const Icon(Icons.add, size: 28), 
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
                color: colorScheme.primary, 
              ),
            ),
          ),
          Obx(() => Text(
            '${controller.homeworks.length} tarefa(s)',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant, 
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
            color: colorScheme.onSurfaceVariant.withValues(alpha:0.4), 
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa encontrada',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant, 
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para adicionar uma nova tarefa',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha:0.7), 
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
        return _buildHomeworkCard(homework, context, colorScheme, textTheme); 
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
              ? colorScheme.error.withValues(alpha: 0.3) 
              : isDueToday
                  ? colorScheme.secondary.withValues(alpha: 0.3) 
                  : Colors.transparent, 
          width: 1,
        ),
      ),
      color: colorScheme.surface, 
      surfaceTintColor: colorScheme.surfaceTint, 
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1), 
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showHomeworkDetailsDialog(context, homework, colorScheme, textTheme), 
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
                        color: colorScheme.onSurface, 
                      ),
                    ),
                  ),
                  _buildStatusChip(homework.status, colorScheme, textTheme),
                ],
              ),
              if (homework.discipline != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.subject,
                      size: 16,
                      color: colorScheme.onSurfaceVariant, 
                    ),
                    const SizedBox(width: 4),
                    Text(
                      homework.discipline!.name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant, 
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
                    color: colorScheme.onSurfaceVariant, 
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
                            ? colorScheme.error 
                            : isDueToday
                                ? colorScheme.secondary 
                                : colorScheme.onSurfaceVariant, 
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
                    color: colorScheme.surfaceContainerHigh, 
                    onSelected: (value) => _handleHomeworkAction(value, homework, context, colorScheme, textTheme), 
                    itemBuilder: (context) => [
                      if (homework.status == HomeworkStatus.pending)
                        PopupMenuItem(
                          value: 'complete',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: colorScheme.tertiary), 
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
                              Icon(Icons.pending, color: colorScheme.secondary), 
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
                              Icon(Icons.cancel, color: colorScheme.error), 
                              const SizedBox(width: 8),
                              Text('Cancelar', style: TextStyle(color: colorScheme.onSurface)),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: colorScheme.primary), 
                            const SizedBox(width: 8),
                            Text('Editar', style: TextStyle(color: colorScheme.onSurface)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: colorScheme.error), 
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

    Color thematicStatusColor;
    switch (status) {
      case HomeworkStatus.pending:
        thematicStatusColor = colorScheme.secondary; 
        break;
      case HomeworkStatus.completed:
        thematicStatusColor = colorScheme.tertiary; 
        break;
      case HomeworkStatus.cancelled:
        thematicStatusColor = colorScheme.error; 
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: thematicStatusColor.withValues(alpha:0.1), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: thematicStatusColor.withValues(alpha:0.3), 
        ),
      ),
      child: Text(
        controller.getStatusDisplayName(status),
        style: textTheme.labelLarge?.copyWith( 
          fontSize: 12, 
          color: thematicStatusColor, 
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
    colorScheme = colorScheme ?? Theme.of(context).colorScheme; 
    textTheme = textTheme ?? Theme.of(context).textTheme; 

    Get.dialog(
      CustomDialog(
        title: dialogTitle,
        icon: isEdit ? Icons.edit : Icons.add,
        content: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              CustomTextField(
                controller: controller.titleEC,
                hintText: 'Título da Tarefa',
                validator: Validatorless.required('Título é obrigatório'),
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: controller.descriptionEC,
                hintText: 'Descrição (opcional)',
                maxLines: 3,
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
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
              
              Obx(() => InkWell(
                onTap: () => _selectDueDate(context, colorScheme!), 
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme!.outline), 
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.surface, 
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant), 
                      const SizedBox(width: 12),
                      Text(
                        controller.selectedDueDate.value != null
                            ? 'Entrega: ${controller.selectedDueDate.value!.day}/${controller.selectedDueDate.value!.month}/${controller.selectedDueDate.value!.year}'
                            : 'Data de Entrega',
                        style: textTheme?.bodyLarge?.copyWith(
                          color: controller.selectedDueDate.value != null
                              ? colorScheme.onSurface 
                              : colorScheme.onSurfaceVariant, 
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
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearForm();
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant, 
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.formKey.currentState!.validate()) {
                try {
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
                  
                  Get.back();
                } catch (e) {
                  
                  Get.snackbar(
                    'Erro',
                    'Não foi possível ${isEdit ? 'atualizar' : 'adicionar'} a tarefa: $e',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: colorScheme!.errorContainer,
                    colorText: colorScheme.onErrorContainer,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary, 
              foregroundColor: colorScheme.onPrimary, 
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