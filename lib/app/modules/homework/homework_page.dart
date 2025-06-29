import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/models/homework.dart';
import 'package:vocatus/app/models/discipline.dart';
import './homework_controller.dart';

class HomeworkPage extends GetView<HomeworkController> {
  const HomeworkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tarefas de ${controller.currentClasse.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Constants.primaryColor.withValues(alpha: .9),
                Constants.primaryColor,
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
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.homeworks.isEmpty) {
                return _buildEmptyState();
              }
              return _buildHomeworkList();
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHomeworkDialog(context),
        backgroundColor: Constants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${DateTime.now().year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Constants.primaryColor,
              ),
            ),
          ),
          Obx(() => Text(
            '${controller.homeworks.length} tarefa(s)',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para adicionar uma nova tarefa',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.homeworks.length,
      itemBuilder: (context, index) {
        final homework = controller.homeworks[index];
        return _buildHomeworkCard(homework, context);
      },
    );
  }

  Widget _buildHomeworkCard(Homework homework, BuildContext context) {
    final isOverdue = controller.isOverdue(homework);
    final isDueToday = controller.isDueToday(homework);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.3)
              : isDueToday
                  ? Colors.orange.withValues(alpha: 0.3)
                  : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showHomeworkDetailsDialog(context, homework),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(homework.status),
                ],
              ),
              if (homework.discipline != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.subject,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      homework.discipline!.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              if (homework.description != null && homework.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  homework.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
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
                            ? Colors.red
                            : isDueToday
                                ? Colors.orange
                                : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.formatDueDate(homework.dueDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: isOverdue
                              ? Colors.red
                              : isDueToday
                                  ? Colors.orange
                                  : Colors.grey[600],
                          fontWeight: isOverdue || isDueToday
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleHomeworkAction(value, homework, context),
                    itemBuilder: (context) => [
                      if (homework.status == HomeworkStatus.pending)
                        const PopupMenuItem(
                          value: 'complete',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Marcar como Concluída'),
                            ],
                          ),
                        ),
                      if (homework.status == HomeworkStatus.completed)
                        const PopupMenuItem(
                          value: 'pending',
                          child: Row(
                            children: [
                              Icon(Icons.pending, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Marcar como Pendente'),
                            ],
                          ),
                        ),
                      if (homework.status != HomeworkStatus.cancelled)
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Cancelar'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir'),
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

  Widget _buildStatusChip(HomeworkStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: controller.getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.getStatusColor(status).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        controller.getStatusDisplayName(status),
        style: TextStyle(
          fontSize: 12,
          color: controller.getStatusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleHomeworkAction(String action, Homework homework, BuildContext context) {
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
        _showEditHomeworkDialog(context, homework);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, homework);
        break;
    }
  }

  void _showAddHomeworkDialog(BuildContext context) {
    controller.clearForm();
    _showHomeworkFormDialog(context, 'Adicionar Tarefa', false);
  }

  void _showEditHomeworkDialog(BuildContext context, Homework homework) {
    controller.prepareEditHomework(homework);
    _showHomeworkFormDialog(context, 'Editar Tarefa', true, homework);
  }

  void _showHomeworkFormDialog(BuildContext context, String title, bool isEdit, [Homework? homework]) {
    Get.dialog(
      CustomDialog(
        title: title,
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
              Obx(() => InkWell(
                onTap: () => _selectDueDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        controller.selectedDueDate.value != null
                            ? 'Data de Entrega: ${controller.selectedDueDate.value!.day}/${controller.selectedDueDate.value!.month}/${controller.selectedDueDate.value!.year}'
                            : 'Selecionar Data de Entrega',
                        style: TextStyle(
                          color: controller.selectedDueDate.value != null
                              ? Colors.black
                              : Colors.grey[600],
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Atualizar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }

  void _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDueDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.selectedDueDate.value = picked;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Homework homework) {
    Get.dialog(
      CustomConfirmationDialogWithCode(
        title: 'Excluir Tarefa',
        message: 'Tem certeza que deseja excluir a tarefa "${homework.title}"?',
        confirmButtonText: 'EXCLUIR',
        onConfirm: () => controller.deleteHomework(homework),
      ),
    );
  }

  void _showHomeworkDetailsDialog(BuildContext context, Homework homework) {
    Get.dialog(
      AlertDialog(
        title: Text(homework.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (homework.discipline != null) ...[
              Row(
                children: [
                  const Icon(Icons.subject, size: 16),
                  const SizedBox(width: 8),
                  Text('Disciplina: ${homework.discipline!.name}'),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text('Entrega: ${homework.dueDate.day}/${homework.dueDate.month}/${homework.dueDate.year}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info, size: 16),
                const SizedBox(width: 8),
                Text('Status: ${controller.getStatusDisplayName(homework.status)}'),
              ],
            ),
            if (homework.description != null && homework.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Descrição:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(homework.description!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showEditHomeworkDialog(context, homework);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }
}
