import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';

import 'package:vocatus/app/models/occurrence.dart';
import 'package:vocatus/app/models/student.dart';
import './occurrence_controller.dart';

class OccurrencePage extends GetView<OccurrenceController> {
  const OccurrencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ocorrências',
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
          _buildHeader(colorScheme, textTheme), 
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary)); 
              }
              if (controller.occurrences.isEmpty) {
                return _buildEmptyState(colorScheme, textTheme); 
              }
              return _buildOccurrencesList(context, colorScheme, textTheme); 
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton( 
        onPressed: () => _showAddOccurrenceDialog(context, colorScheme, textTheme), 
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chamada: ${controller.currentAttendance.date.day}/${controller.currentAttendance.date.month}/${controller.currentAttendance.date.year}',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary, 
            ),
          ),
          if (controller.currentAttendance.content != null) ...[
            const SizedBox(height: 4),
            Text(
              controller.currentAttendance.content!,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), 
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Obx(
            () => Text(
              '${controller.occurrences.length} ocorrência(s)',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), 
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.report_outlined, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha:0.4)), 
          const SizedBox(height: 16),
          Text(
            'Nenhuma ocorrência registrada',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant, 
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para registrar uma nova ocorrência',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha:0.7)), 
          ),
        ],
      ),
    );
  }

  Widget _buildOccurrencesList(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.occurrences.length,
      itemBuilder: (context, index) {
        final occurrence = controller.occurrences[index];
        return _buildOccurrenceCard(occurrence, context, colorScheme, textTheme); 
      },
    );
  }

  Widget _buildOccurrenceCard(Occurrence occurrence, BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final isGeneral = occurrence.isGeneralOccurrence;

    Color thematicTypeColor;
    switch (occurrence.occurrenceType!) {
      case OccurrenceType.comportamento:
        thematicTypeColor = colorScheme.tertiary; 
        break;
      case OccurrenceType.saude:
        thematicTypeColor = colorScheme.error; 
        break;
      case OccurrenceType.atraso:
        thematicTypeColor = colorScheme.secondary; 
        break;
      case OccurrenceType.material:
        thematicTypeColor = colorScheme.primary; 
        break;
      case OccurrenceType.outros: 
      default:
        thematicTypeColor = colorScheme.onSurfaceVariant; 
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: thematicTypeColor.withValues(alpha:0.3), 
          width: 1,
        ),
      ),
      color: colorScheme.surface, 
      surfaceTintColor: colorScheme.primaryContainer, 
      shadowColor: colorScheme.shadow.withValues(alpha:0.1), 
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOccurrenceDetailsDialog(context, occurrence, colorScheme, textTheme), 
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
                      color: thematicTypeColor.withValues(alpha:0.1), 
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      occurrence.getTypeIcon(),
                      size: 20,
                      color: thematicTypeColor, 
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          occurrence.getTypeDisplayName(),
                          style: textTheme.titleSmall?.copyWith( 
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface, 
                          ),
                        ),
                        Text(
                          isGeneral
                              ? 'Ocorrência Geral'
                              : occurrence.student?.name ?? 'Aluno não identificado',
                          style: textTheme.bodySmall?.copyWith(
                            color: isGeneral
                                ? colorScheme.primary 
                                : colorScheme.onSurfaceVariant, 
                            fontWeight: isGeneral
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: colorScheme.surfaceContainerHigh, 
                    onSelected: (value) => _handleOccurrenceAction(value, occurrence, context, colorScheme, textTheme), 
                    itemBuilder: (context) => [
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
              const SizedBox(height: 12),
              Text(
                occurrence.description,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), 
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant), 
                  const SizedBox(width: 4),
                  Text(
                    controller.formatOccurrenceDate(occurrence.occurrenceDate),
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), 
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOccurrenceAction(
    String action,
    Occurrence occurrence,
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    switch (action) {
      case 'edit':
        _showEditOccurrenceDialog(context, occurrence, colorScheme, textTheme);
        break;
      case 'delete':
        _showDeleteConfirmationDialog(context, occurrence, colorScheme);
        break;
    }
  }

  void _showAddOccurrenceDialog(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    controller.clearForm();
    _showOccurrenceFormDialog(context, 'Registrar Ocorrência', false, null, colorScheme, textTheme);
  }

  void _showEditOccurrenceDialog(BuildContext context, Occurrence occurrence, ColorScheme colorScheme, TextTheme textTheme) {
    controller.prepareEditOccurrence(occurrence);
    _showOccurrenceFormDialog(context, 'Editar Ocorrência', true, occurrence, colorScheme, textTheme);
  }

  void _showOccurrenceFormDialog(
    BuildContext context,
    String dialogTitle,
    bool isEdit, [
    Occurrence? occurrence,
    ColorScheme? colorScheme, 
    TextTheme? textTheme, 
  ]) {
    colorScheme = colorScheme ?? Theme.of(context).colorScheme; 
    textTheme = textTheme ?? Theme.of(context).textTheme; 

    
    if (!isEdit) {
      controller.selectedDate.value = controller.currentAttendance.date;
    }

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
                
                Obx(
                  () => SwitchListTile(
                    title: Text(
                      'Ocorrência Geral da Sala',
                      style: textTheme?.bodyLarge?.copyWith(color: colorScheme?.onSurface),
                    ),
                    subtitle: Text(
                      'Marque se a ocorrência se refere à toda a turma',
                      style: textTheme?.bodyMedium?.copyWith(color: colorScheme!.onSurfaceVariant),
                    ),
                    value: controller.isGeneralOccurrence.value,
                    onChanged: (value) {
                      controller.isGeneralOccurrence.value = value;
                      if (value) {
                        controller.selectedStudent.value = null;
                      }
                    },
                    activeColor: colorScheme!.primary, 
                    inactiveThumbColor: colorScheme.onSurfaceVariant,
                    inactiveTrackColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 16),

                
                Obx(
                  () => controller.isGeneralOccurrence.value
                      ? const SizedBox.shrink()
                      : Column(
                          children: [
                            CustomDrop<Student>(
                              items: controller.availableStudents,
                              value: controller.selectedStudent.value,
                              labelBuilder: (student) => student.name,
                              onChanged: (student) =>
                                  controller.selectedStudent.value = student,
                              hint: 'Selecione o Aluno',
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                ),

                
                Obx(
                  () => CustomDrop<OccurrenceType>(
                    items: OccurrenceType.values,
                    value: controller.selectedType.value,
                    labelBuilder: (type) =>
                        controller.getOccurrenceTypeDisplayName(type),
                    onChanged: (type) => controller.selectedType.value = type,
                    hint: 'Selecione o Tipo de Ocorrência',
                  ),
                ),
                const SizedBox(height: 16),

                
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest, 
                    border: Border.all(color: colorScheme.outline), 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant), 
                      const SizedBox(width: 12),
                      Text(
                        'Data: ${controller.currentAttendance.date.day}/${controller.currentAttendance.date.month}/${controller.currentAttendance.date.year}',
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface), 
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                
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
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant, 
            ),
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
                Get.back(); 
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary, 
              foregroundColor: colorScheme.onPrimary, 
            ),
            child: Text(isEdit ? 'Atualizar' : 'Registrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    Occurrence occurrence,
    ColorScheme colorScheme, 
  ) {
    Get.dialog(
      CustomConfirmationDialogWithCode(
        title: 'Excluir Ocorrência',
        message: 'Tem certeza que deseja excluir esta ocorrência?',
        confirmButtonText: 'EXCLUIR',
        onConfirm: () => controller.deleteOccurrence(occurrence),
      ),
    );
  }

  void _showOccurrenceDetailsDialog(
    BuildContext context,
    Occurrence occurrence,
    ColorScheme colorScheme, 
    TextTheme textTheme, 
  ) {
    Get.dialog(
      AlertDialog(
        
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        title: Row(
          children: [
            
            Icon(
              occurrence.getTypeIcon(),
              color: controller.getOccurrenceTypeColor(occurrence.occurrenceType!), 
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                occurrence.getTypeDisplayName(),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface, 
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (occurrence.isStudentOccurrence &&
                occurrence.student != null) ...[
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: colorScheme.onSurfaceVariant), 
                  const SizedBox(width: 8),
                  Text(
                    'Aluno: ${occurrence.student!.name}',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface), 
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (occurrence.isGeneralOccurrence) ...[
              Row(
                children: [
                  Icon(Icons.info, size: 16, color: colorScheme.primary), 
                  const SizedBox(width: 8),
                  Text(
                    'Ocorrência Geral da Sala',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary, 
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant), 
                const SizedBox(width: 4),
                Text(
                  'Data: ${occurrence.occurrenceDate.day}/${occurrence.occurrenceDate.month}/${occurrence.occurrenceDate.year}',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface), 
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Descrição:',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface), 
            ),
            const SizedBox(height: 4),
            Text(
              occurrence.description,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), 
            ),
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
              _showEditOccurrenceDialog(context, occurrence, colorScheme, textTheme);
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