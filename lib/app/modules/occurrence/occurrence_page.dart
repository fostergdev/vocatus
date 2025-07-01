import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:validatorless/validatorless.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';
// import 'package:vocatus/app/core/widgets/custom_popbutton.dart'; // Remova se não estiver usando
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
          _buildHeader(colorScheme, textTheme), // Passa colorScheme e textTheme
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary)); // Cor do tema
              }
              if (controller.occurrences.isEmpty) {
                return _buildEmptyState(colorScheme, textTheme); // Passa colorScheme e textTheme
              }
              return _buildOccurrencesList(context, colorScheme, textTheme); // Passa context e theme
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton( // Usar FloatingActionButton normal
        onPressed: () => _showAddOccurrenceDialog(context, colorScheme, textTheme), // Passa context e theme
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chamada: ${controller.currentAttendance.date.day}/${controller.currentAttendance.date.month}/${controller.currentAttendance.date.year}',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary, // Cor da data da chamada
            ),
          ),
          if (controller.currentAttendance.content != null) ...[
            const SizedBox(height: 4),
            Text(
              controller.currentAttendance.content!,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), // Cor do conteúdo da chamada
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Obx(
            () => Text(
              '${controller.occurrences.length} ocorrência(s)',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), // Cor do texto de contagem
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
          Icon(Icons.report_outlined, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.4)), // Cor do ícone
          const SizedBox(height: 16),
          Text(
            'Nenhuma ocorrência registrada',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant, // Cor do texto
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para registrar uma nova ocorrência',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.7)), // Cor do texto
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
        return _buildOccurrenceCard(occurrence, context, colorScheme, textTheme); // Passa context e theme
      },
    );
  }

  Widget _buildOccurrenceCard(Occurrence occurrence, BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    final isGeneral = occurrence.isGeneralOccurrence;

    Color thematicTypeColor;
    switch (occurrence.occurrenceType!) {
      case OccurrenceType.comportamento:
        thematicTypeColor = colorScheme.tertiary; // Exemplo: verde/azul
        break;
      case OccurrenceType.saude:
        thematicTypeColor = colorScheme.error; // Exemplo: vermelho
        break;
      case OccurrenceType.atraso:
        thematicTypeColor = colorScheme.secondary; // Exemplo: laranja/amarelo
        break;
      case OccurrenceType.material:
        thematicTypeColor = colorScheme.primary; // Exemplo: cor primária
        break;
      case OccurrenceType.outros: // Se tiver um tipo 'outros'
      default:
        thematicTypeColor = colorScheme.onSurfaceVariant; // Cor neutra
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: thematicTypeColor.withOpacity(0.3), // Borda com cor do tipo de ocorrência
          width: 1,
        ),
      ),
      color: colorScheme.surface, // Fundo do Card
      surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
      shadowColor: colorScheme.shadow.withOpacity(0.1), // Sombra
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOccurrenceDetailsDialog(context, occurrence, colorScheme, textTheme), // Passa context e theme
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
                      color: thematicTypeColor.withOpacity(0.1), // Fundo do ícone
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      occurrence.getTypeIcon(),
                      size: 20,
                      color: thematicTypeColor, // Cor do ícone do tipo de ocorrência
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          occurrence.getTypeDisplayName(),
                          style: textTheme.titleSmall?.copyWith( // Usar titleSmall
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface, // Cor do nome do tipo
                          ),
                        ),
                        Text(
                          isGeneral
                              ? 'Ocorrência Geral'
                              : occurrence.student?.name ?? 'Aluno não identificado',
                          style: textTheme.bodySmall?.copyWith(
                            color: isGeneral
                                ? colorScheme.primary // Cor para geral
                                : colorScheme.onSurfaceVariant, // Cor para aluno
                            fontWeight: isGeneral
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: colorScheme.surfaceContainerHigh, // Fundo do menu
                    onSelected: (value) => _handleOccurrenceAction(value, occurrence, context, colorScheme, textTheme), // Passa context e theme
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: colorScheme.primary), // Cor para editar
                            const SizedBox(width: 8),
                            Text('Editar', style: TextStyle(color: colorScheme.onSurface)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: colorScheme.error), // Cor para excluir
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
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), // Cor da descrição
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant), // Cor do ícone
                  const SizedBox(width: 4),
                  Text(
                    controller.formatOccurrenceDate(occurrence.occurrenceDate),
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), // Cor da data
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
    ColorScheme? colorScheme, // Passa colorScheme
    TextTheme? textTheme, // Passa textTheme
  ]) {
    colorScheme = colorScheme ?? Theme.of(context).colorScheme; // Garante que o colorScheme exista
    textTheme = textTheme ?? Theme.of(context).textTheme; // Garante que o textTheme exista

    // Definir a data da ocorrência para a data da chamada atual se não estiver editando
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
                // Switch para ocorrência geral
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
                    activeColor: colorScheme!.primary, // Cor do switch quando ativo
                    inactiveThumbColor: colorScheme!.onSurfaceVariant,
                    inactiveTrackColor: colorScheme!.surfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Seleção de aluno (apenas se não for ocorrência geral)
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

                // Tipo de ocorrência
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

                // Data da ocorrência (somente visualização)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant, // Fundo do container
                    border: Border.all(color: colorScheme.outline), // Borda
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant), // Ícone
                      const SizedBox(width: 12),
                      Text(
                        'Data: ${controller.currentAttendance.date.day}/${controller.currentAttendance.date.month}/${controller.currentAttendance.date.year}',
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface), // Texto
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
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant, // Cor do botão Cancelar
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
                Get.back(); // Fecha o diálogo após a ação
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary, // Fundo do botão Registrar/Atualizar
              foregroundColor: colorScheme.onPrimary, // Texto do botão
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
    ColorScheme colorScheme, // Passa colorScheme
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
    ColorScheme colorScheme, // Passa colorScheme
    TextTheme textTheme, // Passa textTheme
  ) {
    Get.dialog(
      AlertDialog(
        // Fundo do diálogo de detalhes
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        title: Row(
          children: [
            // Mapeamento das cores do tipo de ocorrência para o ColorScheme
            Icon(
              occurrence.getTypeIcon(),
              color: controller.getOccurrenceTypeColor(occurrence.occurrenceType!), // Usa a cor do tipo (ajustada no controller)
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                occurrence.getTypeDisplayName(),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface, // Cor do título
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
                  Icon(Icons.person, size: 16, color: colorScheme.onSurfaceVariant), // Cor do ícone
                  const SizedBox(width: 8),
                  Text(
                    'Aluno: ${occurrence.student!.name}',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface), // Cor do texto
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (occurrence.isGeneralOccurrence) ...[
              Row(
                children: [
                  Icon(Icons.info, size: 16, color: colorScheme.primary), // Cor do ícone
                  const SizedBox(width: 8),
                  Text(
                    'Ocorrência Geral da Sala',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary, // Cor do texto
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant), // Cor do ícone
                const SizedBox(width: 4),
                Text(
                  'Data: ${occurrence.occurrenceDate.day}/${occurrence.occurrenceDate.month}/${occurrence.occurrenceDate.year}',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface), // Cor do texto
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Descrição:',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface), // Cor do título da descrição
            ),
            const SizedBox(height: 4),
            Text(
              occurrence.description,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), // Cor da descrição
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant, // Cor do botão Fechar
            ),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showEditOccurrenceDialog(context, occurrence, colorScheme, textTheme);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary, // Fundo do botão Editar
              foregroundColor: colorScheme.onPrimary, // Texto do botão
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }
}