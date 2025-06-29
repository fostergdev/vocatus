import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_confirmation_dialog_with_code.dart';
import 'package:vocatus/app/core/widgets/custom_drop.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_dialog.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/modules/grade/grade_controller.dart';

class GradesPage extends GetView<GradesController> {
  const GradesPage({super.key});

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 0:
        return 'Domingo';
      default:
        return 'Desconhecido';
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Horário: ${controller.selectedFilterYear.value}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
        actions: [],
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
                      const CircularProgressIndicator(
                        color: Constants.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Carregando horários...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (controller.grades.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Nenhum horário agendado para este ano.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Que tal adicionar um novo horário agora?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              final sortedDays = controller.grades.keys.map(int.parse).toList()
                ..sort();

              return ListView.builder(
                itemCount: sortedDays.length,
                itemBuilder: (context, dayIndex) {
                  final dayOfWeek = sortedDays[dayIndex];
                  final gradesForDay = controller.grades[dayOfWeek.toString()]!;

                  return _buildDayCard(dayOfWeek, gradesForDay);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          _showAddGradeDialog();
        },
        tooltip: 'Adicionar Horário',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.purple.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDayCard(int dayOfWeek, List<Grade> gradesForDay) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        collapsedBackgroundColor: Colors.purple.shade50,
        backgroundColor: Colors.white,
        iconColor: Colors.purple.shade800,
        collapsedIconColor: Colors.purple.shade800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _getDayName(dayOfWeek),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade900,
            ),
          ),
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: gradesForDay
                  .map((grade) => _buildScheduleItem(grade))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Grade grade) {
    final isActive = grade.active ?? true;
    final textColor = isActive ? Colors.purple.shade900 : Colors.grey.shade700;
    final subtitleColor = isActive
        ? Colors.grey.shade700
        : Colors.grey.shade500;
    final iconColor = isActive ? Constants.primaryColor : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isActive
              ? Constants.primaryColor.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
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
              ? Constants.primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          child: Icon(Icons.school_outlined, color: iconColor, size: 24),
        ),
        title: Text(
          grade.classe?.name ?? 'Turma não informada',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
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
              grade.discipline?.name ?? 'Disciplina não informada',
              style: TextStyle(color: subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule_outlined, size: 18, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  '${Grade.formatTimeDisplay(grade.startTimeOfDay)} - ${Grade.formatTimeDisplay(grade.endTimeOfDay)}',
                  style: TextStyle(
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
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'INATIVO',
                    style: TextStyle(
                      color: Colors.red.shade700,
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
                    onTap: () => _showEditGradeDialog(grade),
                  ),
                  CustomPopupMenuItem(
                    label: 'Arquivar',
                    icon: Icons.archive_outlined,
                    onTap: () => _showToggleGradeStatusDialog(grade),
                  ),
                ],
              )
            : IconButton(
                icon: Icon(
                  Icons.description_outlined,
                  color: Colors.purple.shade600,
                ),
                tooltip: 'Relatório',
                onPressed: () {
                  Get.snackbar(
                    'Relatório',
                    'Abrir relatório do horário inativo',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.purple.shade50,
                    colorText: Constants.primaryColor,
                  );
                },
              ),
      ),
    );
  }

  void _showAddGradeDialog() async {
    controller.resetAddGradeFields();

    await controller.loadFilteredClassesForForm(
      controller.selectedYearForForm.value,
    );

    if (controller.filteredClassesForForm.isEmpty) {
      Get.dialog(
        CustomDialog(
          title: 'AVISO',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Não há turmas ativas disponíveis para adicionar horários no ano selecionado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Por favor, adicione uma turma primeiro ou verifique o ano de filtro.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
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
                    onChanged: (c) =>
                        controller.selectedClasseForForm.value = c,
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.purple.shade800,
                          width: 2,
                        ),
                      ),
                    ),
                    value: controller.selectedDayOfWeekForForm.value,
                    items: _daysOfWeek.map((day) {
                      return DropdownMenuItem(
                        value: day['value'] as int,
                        child: Text(day['label'] as String),
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
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: Grade.formatTimeDisplay(
                                controller.startTimeForForm.value,
                              ),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Início',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.purple.shade800,
                                  width: 2,
                                ),
                              ),
                              suffixIcon: const Icon(Icons.access_time_filled),
                            ),
                            onTap: () async {
                              final TimeOfDay?
                              pickedTime = await showTimePicker(
                                context: Get.context!,
                                initialTime: controller.startTimeForForm.value,
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.purple.shade800,
                                        onSurface: Colors.black,
                                      ),
                                      buttonTheme: const ButtonThemeData(
                                        textTheme: ButtonTextTheme.primary,
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
                              text: Grade.formatTimeDisplay(
                                controller.endTimeForForm.value,
                              ),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Fim',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.purple.shade800,
                                  width: 2,
                                ),
                              ),
                              suffixIcon: const Icon(Icons.access_time_filled),
                            ),
                            onTap: () async {
                              final TimeOfDay?
                              pickedTime = await showTimePicker(
                                context: Get.context!,
                                initialTime: controller.endTimeForForm.value,
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.purple.shade800,
                                        onSurface: Colors.black,
                                      ),
                                      buttonTheme: const ButtonThemeData(
                                        textTheme: ButtonTextTheme.primary,
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
                              final int startTimeInt = Grade.timeOfDayToInt(
                                controller.startTimeForForm.value,
                              );
                              final int endTimeInt = Grade.timeOfDayToInt(
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
                  foregroundColor: Colors.grey.shade700,
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
                    await controller.createGrade(
                      Grade(
                        classeId: controller.selectedClasseForForm.value!.id!,
                        disciplineId:
                            controller.selectedDisciplineForForm.value?.id,
                        dayOfWeek: controller.selectedDayOfWeekForForm.value,
                        startTimeTotalMinutes: Grade.timeOfDayToInt(
                          controller.startTimeForForm.value,
                        ),
                        endTimeTotalMinutes: Grade.timeOfDayToInt(
                          controller.endTimeForForm.value,
                        ),
                        gradeYear: controller.selectedYearForForm.value,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade800,
                  foregroundColor: Colors.white,
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

  void _showEditGradeDialog(Grade grade) {
    controller.fillEditGradeFields(grade);
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
                  decoration: const InputDecoration(
                    labelText: 'Dia da Semana',
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedDayOfWeekForForm.value,
                  items: _daysOfWeek.map((day) {
                    return DropdownMenuItem(
                      value: day['value'] as int,
                      child: Text(day['label'] as String),
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
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: Grade.formatTimeDisplay(
                              controller.startTimeForForm.value,
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Início',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: const Icon(Icons.access_time),
                          ),
                          onTap: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: Get.context!,
                              initialTime: controller.startTimeForForm.value,
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
                            text: Grade.formatTimeDisplay(
                              controller.endTimeForForm.value,
                            ),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Fim',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: const Icon(Icons.access_time),
                          ),
                          onTap: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: Get.context!,
                              initialTime: controller.endTimeForForm.value,
                            );
                            if (pickedTime != null) {
                              controller.endTimeForForm.value = pickedTime;
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório!';
                            }
                            final int startTimeInt = Grade.timeOfDayToInt(
                              controller.startTimeForForm.value,
                            );
                            final int endTimeInt = Grade.timeOfDayToInt(
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
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.formEditKey.currentState!.validate()) {
                  await controller.updateGrade(
                    grade.copyWith(
                      classeId: controller.selectedClasseForForm.value!.id!,
                      disciplineId:
                          controller.selectedDisciplineForForm.value?.id,
                      dayOfWeek: controller.selectedDayOfWeekForForm.value,
                      startTimeTotalMinutes: Grade.timeOfDayToInt(
                        controller.startTimeForForm.value,
                      ),
                      endTimeTotalMinutes: Grade.timeOfDayToInt(
                        controller.endTimeForForm.value,
                      ),
                    ),
                  );
                  Get.back();
                }
              },
              child: const Text('Atualizar'),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }

  void _showToggleGradeStatusDialog(Grade grade) {
    final isCurrentlyActive = grade.active ?? true;

    if (!isCurrentlyActive) {
      Get.dialog(
        CustomDialog(
          title: 'Ação não permitida',
          content: const Text('Não é possível reativar um horário inativado.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Fechar'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      return;
    }

    final message =
        'Tem certeza que deseja INATIVAR o horário das ${Grade.formatTimeDisplay(grade.startTimeOfDay)} - ${Grade.formatTimeDisplay(grade.endTimeOfDay)} (${_getDayName(grade.dayOfWeek)}) da turma "${grade.classe?.name ?? 'N/A'}"?\n\n'
        'ATENÇÃO: Esta ação é irreversível. Não será possível reativar este horário depois.\n\n'
        'Você ainda poderá acessar os dados deste horário para consulta/histórico, mas não poderá reativá-lo.';

    Get.dialog(
      CustomConfirmationDialogWithCode(
        title: 'Inativar Horário',
        message: message,
        confirmButtonText: 'Inativar',
        onConfirm: () async {
          await controller.toggleGradeStatus(grade);
        },
      ),
      barrierDismissible: false,
    );
  }
}



/* // Em _showAddGradeDialog e _showEditGradeDialog, dentro do CustomDialog:
CustomDialog(
  title: 'Adicionar Horário', // ou 'Editar Horário'
  icon: Icons.add_alarm, // Para adicionar horário (exemplo)
  // ou Icons.edit_calendar, // Para editar horário
  content: Form(
    key: controller.formKey, // ou controller.formEditKey
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ... (seus CustomDrop e DropdownButtonFormField)
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
          // Adicionar um foco/cor de destaque quando selecionado
          decoration: InputDecoration(
            labelText: 'Turma',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Constants.primaryColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        CustomDrop<Discipline>(
          items: controller.availableDisciplines,
          value: controller.selectedDisciplineForForm.value,
          labelBuilder: (d) => d.name,
          onChanged: (d) => controller.selectedDisciplineForForm.value = d,
          hint: 'Selecione a Disciplina (Opcional)',
          decoration: InputDecoration(
            labelText: 'Disciplina',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Constants.primaryColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Dia da Semana',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Constants.primaryColor, width: 2),
            ),
          ),
          value: controller.selectedDayOfWeekForForm.value,
          items: _daysOfWeek.map((day) {
            return DropdownMenuItem(
              value: day['value'] as int,
              child: Text(day['label'] as String),
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
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: Grade.formatTimeDisplay(
                      controller.startTimeForForm.value,
                    ),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Início',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Constants.primaryColor, width: 2),
                    ),
                    suffixIcon: const Icon(Icons.access_time_filled), // Ícone preenchido
                  ),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: Get.context!,
                      initialTime: controller.startTimeForForm.value,
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Constants.primaryColor, // Cor principal no seletor de tempo
                              onSurface: Colors.black, // Cor do texto
                            ),
                            buttonTheme: const ButtonThemeData(
                              textTheme: ButtonTextTheme.primary,
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
            const SizedBox(width: 12), // Espaçamento maior
            Expanded(
              child: Obx(
                () => TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: Grade.formatTimeDisplay(
                      controller.endTimeForForm.value,
                    ),
                  ),
                  decoration: InputDecoration(
                    labelText: 'Fim',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Constants.primaryColor, width: 2),
                    ),
                    suffixIcon: const Icon(Icons.access_time_filled),
                  ),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: Get.context!,
                      initialTime: controller.endTimeForForm.value,
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Constants.primaryColor,
                              onSurface: Colors.black,
                            ),
                            buttonTheme: const ButtonThemeData(
                              textTheme: ButtonTextTheme.primary,
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
                    final int startTimeInt = Grade.timeOfDayToInt(
                      controller.startTimeForForm.value,
                    );
                    final int endTimeInt = Grade.timeOfDayToInt(
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
        foregroundColor: Colors.grey.shade700, // Cor de texto do botão
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Cancelar'),
    ),
    ElevatedButton(
      onPressed: () async {
        if (controller.formKey.currentState!.validate()) { // ou formEditKey
          Get.back();
          await controller.createGrade( // ou updateGrade
            Grade(
              classeId: controller.selectedClasseForForm.value!.id!,
              disciplineId: controller.selectedDisciplineForForm.value?.id,
              dayOfWeek: controller.selectedDayOfWeekForForm.value,
              startTimeTotalMinutes: Grade.timeOfDayToInt(
                controller.startTimeForForm.value,
              ),
              endTimeTotalMinutes: Grade.timeOfDayToInt(
                controller.endTimeForForm.value,
              ),
              gradeYear: controller.selectedYearForForm.value,
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Constants.primaryColor, // Cor de fundo do botão
        foregroundColor: Colors.white, // Cor do texto do botão
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Text('Adicionar'), // ou 'Atualizar'
    ),
  ],
), */