import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/models/occurrence.dart';
import 'package:vocatus/app/models/student.dart';
import './occurrence_controller.dart';

class OccurrencePage extends GetView<OccurrenceController> {
  const OccurrencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ocorrências',
          style: TextStyle(
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
            iconColor: Colors.white,
            items: [
              CustomPopupMenuItem(
                label: 'Todas',
                icon: Icons.all_inbox,
                onTap: () => controller.clearAllFilters(),
              ),
              CustomPopupMenuItem(
                label: 'Gerais da Sala',
                icon: Icons.info,
                onTap: () => controller.setFilterGeneral(true),
              ),
              CustomPopupMenuItem(
                label: 'De Alunos',
                icon: Icons.person,
                onTap: () => controller.setFilterStudent(true),
              ),
              CustomPopupMenuItem(
                label: 'Comportamento',
                icon: Icons.psychology,
                onTap: () => controller.setFilterType(OccurrenceType.comportamento),
              ),
              CustomPopupMenuItem(
                label: 'Saúde',
                icon: Icons.local_hospital,
                onTap: () => controller.setFilterType(OccurrenceType.saude),
              ),
              CustomPopupMenuItem(
                label: 'Atraso',
                icon: Icons.access_time,
                onTap: () => controller.setFilterType(OccurrenceType.atraso),
              ),
              CustomPopupMenuItem(
                label: 'Material',
                icon: Icons.inventory,
                onTap: () => controller.setFilterType(OccurrenceType.material),
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
              if (controller.occurrences.isEmpty) {
                return _buildEmptyState();
              }
              return _buildOccurrencesList();
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOccurrenceDialog(context),
        backgroundColor: Constants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chamada: ${controller.currentAttendance.date.day}/${controller.currentAttendance.date.month}/${controller.currentAttendance.date.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Constants.primaryColor,
            ),
          ),
          if (controller.currentAttendance.content != null) ...[
            const SizedBox(height: 4),
            Text(
              controller.currentAttendance.content!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Obx(() => Text(
            '${controller.occurrences.length} ocorrência(s)',
            style: const TextStyle(
              fontSize: 14,
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
            Icons.report_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma ocorrência registrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para registrar uma nova ocorrência',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccurrencesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.occurrences.length,
      itemBuilder: (context, index) {
        final occurrence = controller.occurrences[index];
        return _buildOccurrenceCard(occurrence, context);
      },
    );
  }

  Widget _buildOccurrenceCard(Occurrence occurrence, BuildContext context) {
    final isGeneral = occurrence.isGeneralOccurrence;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: occurrence.getTypeColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOccurrenceDetailsDialog(context, occurrence),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: occurrence.getTypeColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      occurrence.getTypeIcon(),
                      size: 20,
                      color: occurrence.getTypeColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          occurrence.getTypeDisplayName(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          isGeneral ? 'Ocorrência Geral' : occurrence.student?.name ?? 'Aluno não identificado',
                          style: TextStyle(
                            fontSize: 14,
                            color: isGeneral ? Colors.blue[600] : Colors.grey[600],
                            fontWeight: isGeneral ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleOccurrenceAction(value, occurrence, context),
                    itemBuilder: (context) => [
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
              const SizedBox(height: 12),
              Text(
                occurrence.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    controller.formatOccurrenceDate(occurrence.occurrenceDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOccurrenceAction(String action, Occurrence occurrence, BuildContext context) {
    switch (action) {
      case 'edit':
        _showEditOccurrenceDialog(context, occurrence);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, occurrence);
        break;
    }
  }

  void _showAddOccurrenceDialog(BuildContext context) {
    controller.clearForm();
    _showOccurrenceFormDialog(context, 'Registrar Ocorrência', false);
  }

  void _showEditOccurrenceDialog(BuildContext context, Occurrence occurrence) {
    controller.prepareEditOccurrence(occurrence);
    _showOccurrenceFormDialog(context, 'Editar Ocorrência', true, occurrence);
  }

  void _showOccurrenceFormDialog(BuildContext context, String title, bool isEdit, [Occurrence? occurrence]) {
    // Definir a data da ocorrência para a data da chamada atual se não estiver editando
    if (!isEdit) {
      controller.selectedDate.value = controller.currentAttendance.date;
    }
    
    Get.dialog(
      CustomDialog(
        title: title,
        icon: isEdit ? Icons.edit : Icons.add,
        content: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Switch para ocorrência geral
                Obx(() => SwitchListTile(
                  title: const Text('Ocorrência Geral da Sala'),
                  subtitle: const Text('Marque se a ocorrência se refere à toda a turma'),
                  value: controller.isGeneralOccurrence.value,
                  onChanged: (value) {
                    controller.isGeneralOccurrence.value = value;
                    if (value) {
                      controller.selectedStudent.value = null;
                    }
                  },
                  activeColor: Constants.primaryColor,
                )),
                const SizedBox(height: 16),
                
                // Seleção de aluno (apenas se não for ocorrência geral)
                Obx(() => controller.isGeneralOccurrence.value
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          CustomDrop<Student>(
                            items: controller.availableStudents,
                            value: controller.selectedStudent.value,
                            labelBuilder: (student) => student.name,
                            onChanged: (student) => controller.selectedStudent.value = student,
                            hint: 'Selecione o Aluno',
                          ),
                          const SizedBox(height: 16),
                        ],
                      )),
                
                // Tipo de ocorrência
                Obx(() => CustomDrop<OccurrenceType>(
                  items: OccurrenceType.values,
                  value: controller.selectedType.value,
                  labelBuilder: (type) => controller.getOccurrenceTypeDisplayName(type),
                  onChanged: (type) => controller.selectedType.value = type,
                  hint: 'Selecione o Tipo de Ocorrência',
                )),
                const SizedBox(height: 16),
                
                // Data da ocorrência (somente visualização)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        'Data: ${controller.currentAttendance.date.day}/${controller.currentAttendance.date.month}/${controller.currentAttendance.date.year}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Descrição
                CustomTextField(
                  controller: controller.descriptionEC,
                  hintText: 'Descreva a ocorrência...',
                  maxLines: 4,
                  validator: Validatorless.required('Descrição é obrigatória'),
                ),
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.formKey.currentState!.validate()) {
                if (isEdit && occurrence != null) {
                  await controller.updateOccurrence(occurrence);
                } else {
                  await controller.createOccurrence();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Atualizar' : 'Registrar'),
          ),
        ],
      ),
    );
  }


  void _showDeleteConfirmationDialog(BuildContext context, Occurrence occurrence) {
    Get.dialog(
      CustomConfirmationDialogWithCode(
        title: 'Excluir Ocorrência',
        message: 'Tem certeza que deseja excluir esta ocorrência?',
        confirmButtonText: 'EXCLUIR',
        onConfirm: () => controller.deleteOccurrence(occurrence),
      ),
    );
  }

  void _showOccurrenceDetailsDialog(BuildContext context, Occurrence occurrence) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              occurrence.getTypeIcon(),
              color: occurrence.getTypeColor(),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(occurrence.getTypeDisplayName())),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (occurrence.isStudentOccurrence && occurrence.student != null) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 8),
                  Text('Aluno: ${occurrence.student!.name}'),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (occurrence.isGeneralOccurrence) ...[
              const Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Ocorrência Geral da Sala', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text('Data: ${occurrence.occurrenceDate.day}/${occurrence.occurrenceDate.month}/${occurrence.occurrenceDate.year}'),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Descrição:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(occurrence.description),
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
              _showEditOccurrenceDialog(context, occurrence);
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
