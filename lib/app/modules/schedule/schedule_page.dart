import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart'; 
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';

import 'package:vocatus/app/core/widgets/custom_dialog.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/schedule.dart';
import 'package:vocatus/app/modules/schedule/schedule_controller.dart';



class SchedulePage extends GetView<ScheduleController> {
  const SchedulePage({super.key});

  final List<Map<String, dynamic>> _daysOfWeek = const [
    {'value': 1, 'label': 'Segunda-feira'},
    {'value': 2, 'label': 'Terça-feira'},
    {'value': 3, 'label': 'Quarta-feira'},
    {'value': 4, 'label': 'Quinta-feira'},
    {'value': 5, 'label': 'Sexta-feira'},
    {'value': 6, 'label': 'Sábado'},
    {'value': 0, 'label': 'Domingo'},
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Horário: ${controller.selectedFilterYear.value}',
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
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary), 
                      const SizedBox(height: 16),
                      Text(
                        'Carregando horários...',
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant), 
                      ),
                    ],
                  ),
                );
              }
              if (controller.schedules.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 80,
                        color: colorScheme.onSurfaceVariant.withValues(alpha:0.3), 
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nenhum horário agendado para este ano.',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant, 
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Que tal adicionar um novo horário agora?',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant), 
                      ),
                    ],
                  ),
                );
              }
              final sortedDays = controller.schedules.keys.map(int.parse).toList()
                ..sort();

              return ListView.builder(
                itemCount: sortedDays.length,
                itemBuilder: (context, dayIndex) {
                  final dayOfWeek = sortedDays[dayIndex];
                  final schedulesForDay = controller.schedules[dayOfWeek.toString()]!;

                  return _buildDayCard(context, dayOfWeek, schedulesForDay, colorScheme, textTheme); 
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton( 
        onPressed: () async {
          _showAddScheduleDialog(context, colorScheme, textTheme); 
        },
        tooltip: 'Adicionar Horário',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
        backgroundColor: colorScheme.primary, 
        foregroundColor: colorScheme.onPrimary, 
        elevation: 8,
        child: const Icon(Icons.add, size: 28), 
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, int dayOfWeek, List<Schedule> schedulesForDay, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.primaryContainer,
      shadowColor: colorScheme.shadow.withValues(alpha:0.2),
      child: ExpansionTile(
        
        collapsedBackgroundColor: colorScheme.primaryContainer, 
        backgroundColor: colorScheme.surface, 
        iconColor: colorScheme.primary, 
        collapsedIconColor: colorScheme.onPrimaryContainer, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            Constants.getDayName(dayOfWeek),
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface, 
            ),
          ),
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface, 
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: schedulesForDay
                  .map((schedule) => _buildScheduleItem(context, schedule, colorScheme, textTheme)) 
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, Schedule schedule, ColorScheme colorScheme, TextTheme textTheme) {
    final isActive = schedule.active ?? true;
    final textColor = isActive ? colorScheme.onSurface : colorScheme.onSurfaceVariant;
    final subtitleColor = isActive ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withValues(alpha:0.7);
    final iconColor = isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha:0.1), 
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isActive
              ? colorScheme.primary.withValues(alpha:0.2) 
              : colorScheme.outlineVariant, 
          width: 0.8,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: isActive
              ? colorScheme.primary.withValues(alpha:0.1) 
              : colorScheme.surfaceContainerHighest, 
          child: Icon(Icons.school_outlined, color: iconColor, size: 24),
        ),
        title: Text(
          schedule.classe?.name ?? 'Turma não informada',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 17,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              schedule.discipline?.name ?? 'Disciplina não informada',
              style: textTheme.bodyMedium?.copyWith(color: subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule_outlined, size: 18, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  '${Schedule.formatTimeDisplay(schedule.startTimeOfDay)} - ${Schedule.formatTimeDisplay(schedule.endTimeOfDay)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (!isActive)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
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
                    'INATIVO',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onErrorContainer, 
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
          ],
        ),
        trailing: isActive
            ? CustomPopupMenu(
                items: [
                  CustomPopupMenuItem(
                    label: 'Editar',
                    icon: Icons.edit_outlined,
                    onTap: () => _showEditScheduleDialog(context, schedule, colorScheme, textTheme), 
                  ),
                  CustomPopupMenuItem(
                    label: 'Arquivar',
                    icon: Icons.archive_outlined,
                    onTap: () => _showToggleScheduleStatusDialog(context, schedule, colorScheme), 
                  ),
                ],
              )
            : IconButton(
                icon: Icon(
                  Icons.description_outlined,
                  color: colorScheme.onSurfaceVariant, 
                ),
                tooltip: 'Relatório',
                onPressed: () {
                  Get.snackbar(
                    'Relatório',
                    'Abrir relatório do horário inativo',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: colorScheme.tertiaryContainer, 
                    colorText: colorScheme.onTertiaryContainer, 
                  );
                },
              ),
      ),
    );
  }

  
  void _showAddScheduleDialog(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) async {
    controller.resetAddScheduleFields();

    await controller.loadFilteredClassesForForm(
      controller.selectedYearForForm.value,
    );

    if (controller.filteredClassesForForm.isEmpty) {
      Get.dialog(
        CustomDialog(
          title: 'AVISO',
          icon: Icons.info_outline, 
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 60), 
              const SizedBox(height: 16),
              Text(
                'Não há turmas ativas disponíveis para adicionar horários no ano selecionado.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface), 
              ),
              const SizedBox(height: 8),
              Text(
                'Por favor, adicione uma turma primeiro ou verifique o ano de filtro.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant), 
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary, 
              ),
              child: const Text('Entendi'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      Get.dialog(
        Obx(() {
          return CustomDialog(
            title: 'Adicionar Horário',
            icon: Icons.add_alarm,
            content: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomDrop<Classe>(
                    items: controller.filteredClassesForForm,
                    value: controller.selectedClasseForForm.value,
                    labelBuilder: (c) => '${c.name} (${c.schoolYear})',
                    onChanged: (c) => controller.selectedClasseForForm.value = c,
                    hint: 'Selecione a Turma',
                    validator: (value) {
                      if (value == null) {
                        return 'Turma obrigatória!';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomDrop<Discipline>(
                    items: controller.availableDisciplines,
                    value: controller.selectedDisciplineForForm.value,
                    labelBuilder: (d) => d.name,
                    onChanged: (d) => controller.selectedDisciplineForForm.value = d,
                    hint: 'Selecione a Disciplina (Opcional)',
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Dia da Semana',
                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant), 
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2.0), 
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.error, width: 1.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.error, width: 2.0),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest, 
                    ),
                    value: controller.selectedDayOfWeekForForm.value,
                    items: _daysOfWeek.map((day) {
                      return DropdownMenuItem(
                        value: day['value'] as int,
                        child: Text(
                          day['label'] as String,
                          style: TextStyle(color: colorScheme.onSurface), 
                        ),
                      );
                    }).toList(),
                    onChanged: (day) {
                      controller.selectedDayOfWeekForForm.value = day!;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Dia obrigatório!';
                      }
                      return null;
                    },
                    dropdownColor: colorScheme.surfaceContainerHigh, 
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface), 
                    iconEnabledColor: colorScheme.onSurfaceVariant, 
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: Schedule.formatTimeDisplay(
                                controller.startTimeForForm.value,
                              ),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Início',
                              labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.error, width: 1.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.error, width: 2.0),
                              ),
                              suffixIcon: Icon(Icons.access_time_filled, color: colorScheme.onSurfaceVariant),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest,
                            ),
                            style: TextStyle(color: colorScheme.onSurface),
                            cursorColor: colorScheme.primary,
                            onTap: () async {
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context, 
                                initialTime: controller.startTimeForForm.value,
                                builder: (BuildContext context, Widget? child) {
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
                              if (pickedTime != null) {
                                controller.startTimeForForm.value = pickedTime;
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório!';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: Schedule.formatTimeDisplay(
                                controller.endTimeForForm.value,
                              ),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Fim',
                              labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.error, width: 1.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: colorScheme.error, width: 2.0),
                              ),
                              suffixIcon: Icon(Icons.access_time_filled, color: colorScheme.onSurfaceVariant),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest,
                            ),
                            style: TextStyle(color: colorScheme.onSurface),
                            cursorColor: colorScheme.primary,
                            onTap: () async {
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context, 
                                initialTime: controller.endTimeForForm.value,
                                builder: (BuildContext context, Widget? child) {
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
                              if (pickedTime != null) {
                                controller.endTimeForForm.value = pickedTime;
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Obrigatório!';
                              }
                              final int startTimeInt = Schedule.timeOfDayToInt(
                                controller.startTimeForForm.value,
                              );
                              final int endTimeInt = Schedule.timeOfDayToInt(
                                controller.endTimeForForm.value,
                              );

                              if (startTimeInt == endTimeInt) {
                                return 'Início e fim não podem ser iguais';
                              }
                              if (endTimeInt < startTimeInt) {
                                return 'Fim não pode ser antes do início';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
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
                    Get.back();
                    await controller.createSchedule(
                      Schedule(
                        classeId: controller.selectedClasseForForm.value!.id!,
                        disciplineId:
                            controller.selectedDisciplineForForm.value?.id,
                        dayOfWeek: controller.selectedDayOfWeekForForm.value,
                        startTimeTotalMinutes: Schedule.timeOfDayToInt(
                          controller.startTimeForForm.value,
                        ),
                        endTimeTotalMinutes: Schedule.timeOfDayToInt(
                          controller.endTimeForForm.value,
                        ),
                        scheduleYear: controller.selectedYearForForm.value,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary, 
                  foregroundColor: colorScheme.onPrimary, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text('Adicionar'),
              ),
            ],
          );
        }),
        barrierDismissible: false,
      );
    }
  }

  
  void _showEditScheduleDialog(BuildContext context, Schedule schedule, ColorScheme colorScheme, TextTheme textTheme) {
    controller.fillEditScheduleFields(schedule);
    Get.dialog(
      Obx(() {
        return CustomDialog(
          title: 'Editar Horário',
          icon: Icons.edit_calendar,
          content: Form(
            key: controller.formEditKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomDrop<Classe>(
                  items: controller.filteredClassesForForm,
                  value: controller.selectedClasseForForm.value,
                  labelBuilder: (c) => '${c.name} (${c.schoolYear})',
                  onChanged: (c) => controller.selectedClasseForForm.value = c,
                  hint: 'Selecione a Turma',
                  validator: (value) {
                    if (value == null) {
                      return 'Turma obrigatória!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomDrop<Discipline>(
                  items: controller.availableDisciplines,
                  value: controller.selectedDisciplineForForm.value,
                  labelBuilder: (d) => d.name,
                  onChanged: (d) =>
                      controller.selectedDisciplineForForm.value = d,
                  hint: 'Selecione a Disciplina (Opcional)',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Dia da Semana',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.error, width: 1.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.error, width: 2.0),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                  value: controller.selectedDayOfWeekForForm.value,
                  items: _daysOfWeek.map((day) {
                    return DropdownMenuItem(
                      value: day['value'] as int,
                      child: Text(
                        day['label'] as String,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                  onChanged: (day) {
                    controller.selectedDayOfWeekForForm.value = day!;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Dia obrigatório!';
                    }
                    return null;
                  },
                  dropdownColor: colorScheme.surfaceContainerHigh,
                  style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                  iconEnabledColor: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: Schedule.formatTimeDisplay(
                              controller.startTimeForForm.value,
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Início',
                            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.error, width: 1.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.error, width: 2.0),
                            ),
                            suffixIcon: Icon(Icons.access_time_filled, color: colorScheme.onSurfaceVariant),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          style: TextStyle(color: colorScheme.onSurface),
                          cursorColor: colorScheme.primary,
                          onTap: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: controller.startTimeForForm.value,
                              builder: (BuildContext context, Widget? child) {
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
                            if (pickedTime != null) {
                              controller.startTimeForForm.value = pickedTime;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório!';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Obx(
                        () => TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: Schedule.formatTimeDisplay(
                              controller.endTimeForForm.value,
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Fim',
                            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.error, width: 1.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.error, width: 2.0),
                            ),
                            suffixIcon: Icon(Icons.access_time_filled, color: colorScheme.onSurfaceVariant),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          style: TextStyle(color: colorScheme.onSurface),
                          cursorColor: colorScheme.primary,
                          onTap: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: controller.endTimeForForm.value,
                              builder: (BuildContext context, Widget? child) {
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
                            if (pickedTime != null) {
                              controller.endTimeForForm.value = pickedTime;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório!';
                            }
                            final int startTimeInt = Schedule.timeOfDayToInt(
                              controller.startTimeForForm.value,
                            );
                            final int endTimeInt = Schedule.timeOfDayToInt(
                              controller.endTimeForForm.value,
                            );

                            if (startTimeInt == endTimeInt) {
                              return 'Início e fim não podem ser iguais';
                            }
                            if (endTimeInt < startTimeInt) {
                              return 'Fim não pode ser antes do início';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
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
                  await controller.updateSchedule(
                    schedule.copyWith(
                      classeId: controller.selectedClasseForForm.value!.id!,
                      disciplineId:
                          controller.selectedDisciplineForForm.value?.id,
                      dayOfWeek: controller.selectedDayOfWeekForForm.value,
                      startTimeTotalMinutes: Schedule.timeOfDayToInt(
                        controller.startTimeForForm.value,
                      ),
                      endTimeTotalMinutes: Schedule.timeOfDayToInt(
                        controller.endTimeForForm.value,
                      ),
                    ),
                  );
                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, 
                foregroundColor: colorScheme.onPrimary, 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Atualizar'),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }

  
  void _showToggleScheduleStatusDialog(BuildContext context, Schedule schedule, ColorScheme colorScheme) {
    final isCurrentlyActive = schedule.active ?? true;

    if (!isCurrentlyActive) {
      Get.dialog(
        CustomDialog(
          title: 'Ação não permitida',
          icon: Icons.block, 
          content: Text(
            'Não é possível reativar um horário inativado.',
            style: TextStyle(color: colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary, 
              ),
              child: const Text('Fechar'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      return;
    }

    final message =
        'Tem certeza que deseja INATIVAR o horário das ${Schedule.formatTimeDisplay(schedule.startTimeOfDay)} - ${Schedule.formatTimeDisplay(schedule.endTimeOfDay)} (${Constants.getDayName(schedule.dayOfWeek)}) da turma "${schedule.classe?.name ?? 'N/A'}"?\n\n'
        'ATENÇÃO: Esta ação é irreversível. Não será possível reativar este horário depois.\n\n'
        'Você ainda poderá acessar os dados deste horário para consulta/histórico, mas não poderá reativá-lo.';

    Get.dialog(
      CustomConfirmationDialogWithCode(
        title: 'Inativar Horário',
        message: message,
        confirmButtonText: 'Inativar',
        onConfirm: () async {
          await controller.toggleScheduleStatus(schedule);
        },
      ),
      barrierDismissible: false,
    );
  }
}