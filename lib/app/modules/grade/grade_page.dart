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
        backgroundColor: Constants.primaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          /* IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Filtrar',
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Filtros',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.purple.shade800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => DropdownButtonFormField<int>(
                              value: controller.selectedFilterYear.value,
                              decoration: const InputDecoration(
                                labelText: 'Ano',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  List.generate(
                                        11,
                                        (i) => DateTime.now().year - 5 + i,
                                      )
                                      .map(
                                        (year) => DropdownMenuItem(
                                          value: year,
                                          child: Text(year.toString()),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (year) {
                                if (year != null) {
                                  controller.selectedFilterYear.value = year;
                                  controller.loadAllGrades();
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Transform.scale(
                                  scale: 0.75,
                                  child: Switch(
                                    value:
                                        controller.showOnlyActiveGrades.value,
                                    onChanged: (val) {
                                      controller.showOnlyActiveGrades.value =
                                          val;
                                      controller.loadAllGrades();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    controller.showOnlyActiveGrades.value
                                        ? 'Desarquivadas'
                                        : 'Arquivadas',
                                    style: TextStyle(
                                      color:
                                          controller.showOnlyActiveGrades.value
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ), */
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.grades.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum horário agendado encontrado.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
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
        onPressed: () => _showAddGradeDialog(),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: .1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          grade.classe?.name ?? 'Turma não informada',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: grade.active!
                ? Colors.purple.shade900
                : Colors.grey.shade700,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              grade.discipline?.name ?? 'Disciplina não informada',
              style: TextStyle(
                color: grade.active!
                    ? Colors.grey.shade700
                    : Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.watch_later,
                  size: 16,
                  color: grade.active!
                      ? Colors.purple.shade600
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${Grade.formatTimeDisplay(grade.startTimeOfDay)} - ${Grade.formatTimeDisplay(grade.endTimeOfDay)}',
                  style: TextStyle(
                    color: grade.active!
                        ? Colors.purple.shade600
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (!grade.active!)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Status: Inativo',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: grade.active!
            ? CustomPopupMenu(
                items: [
                  CustomPopupMenuItem(
                    label: 'Editar',
                    icon: Icons.edit,
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
                icon: const Icon(Icons.insert_drive_file, color: Colors.purple),
                tooltip: 'Relatório',
                onPressed: () {
                  // Lógica para relatório
                  Get.snackbar(
                    'Relatório',
                    'Abrir relatório do horário inativo',
                  );
                },
              ),
      ),
    );
  }

  void _showAddGradeDialog() {
    controller.resetAddGradeFields();
    Get.dialog(
      Obx(() {
        return CustomDialog(
          title: 'Adicionar Horário',
          content: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Ano Letivo da Turma',
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedYearForForm.value,
                  items: List.generate(11, (i) => DateTime.now().year - 5 + i)
                      .map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      })
                      .toList(),
                  onChanged: (year) async {
                    controller.selectedYearForForm.value = year!;
                    await controller.loadFilteredClassesForForm(year);
                    controller.selectedClasseForForm.value = null;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Ano obrigatório!';
                    }
                    return null;
                  },
                ),

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
              child: const Text('Adicionar'),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
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
                  items:
                      controller.filteredClassesForForm, // MUDANÇA AQUI TAMBÉM
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
