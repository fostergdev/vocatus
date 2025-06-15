import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/constants/constants.dart';
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
        title: const Text(
          'Horários Globais',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Constants.primaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar Horários',
            color: Colors.white,
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                'Horários para o ano: ${controller.selectedFilterYear.value}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            );
          }),
          Obx(() {
            final filters = <String>[];
            if (controller.selectedFilterClasse.value != null) {
              filters.add(
                'Turma: ${controller.selectedFilterClasse.value!.name}',
              );
            }
            if (controller.selectedFilterDiscipline.value != null) {
              filters.add(
                'Disciplina: ${controller.selectedFilterDiscipline.value!.name}',
              );
            }
            if (controller.selectedFilterDayOfWeek.value != null) {
              filters.add(
                'Dia: ${_getDayName(controller.selectedFilterDayOfWeek.value!)}',
              );
            }
            if (!controller.showOnlyActiveGrades.value) {
              filters.add('Status: Inativos');
            } else {
              filters.add('Status: Ativos');
            }

            if (filters.isEmpty ||
                (filters.length == 1 &&
                    filters.first.startsWith('Status: Ativos'))) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: filters
                    .map((filter) => Chip(label: Text(filter)))
                    .toList(),
              ),
            );
          }),
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
            color: Colors.purple.withOpacity(0.1),
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
        leading: CircleAvatar(
          backgroundColor: grade.active! ? Colors.blueAccent : Colors.grey,
          child: Icon(
            Icons.schedule,
            color: grade.active!
                ? Colors.purple.shade800
                : Colors.grey.shade600,
          ),
        ),
        title: Text(
          '${grade.classe?.name ?? 'Turma não informada'} (${grade.classe?.schoolYear ?? ''})',
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
        trailing: CustomPopupMenu(
          items: [
            CustomPopupMenuItem(
              label: 'Editar',
              icon: Icons.edit,
              onTap: () => _showEditGradeDialog(grade),
            ),
            CustomPopupMenuItem(
              label: grade.active! ? 'Inativar' : 'Ativar',
              icon: grade.active! ? Icons.visibility_off : Icons.visibility,
              onTap: () => _showToggleGradeStatusDialog(grade),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGradeDialog() {
    controller.resetAddGradeFields();
    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return CustomDialog(
            title: 'Processando...',
            content: const Center(child: CircularProgressIndicator()),
            actions: [],
          );
        }
        return CustomDialog(
          title: 'Adicionar Horário',
          icon: Icons.add_alarm,
          content: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomDrop<Classe>(
                  items: controller.availableClasses,
                  value: controller.selectedClasseForForm.value,
                  labelBuilder: (c) => '${c.name} (${c.schoolYear})',
                  onChanged: (c) => controller.selectedClasseForForm.value = c,
                  hint: 'Selecione a Turma',
                  // CORREÇÃO: Validação customizada para Dropdown (verifica se 'value' é nulo)
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
                  // CORREÇÃO: Validação customizada para Dropdown (verifica se 'value' é nulo)
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
                            if (value == null || value.isEmpty)
                              return 'Obrigatório!';
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
                            if (value == null || value.isEmpty)
                              return 'Obrigatório!';
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
                    ),
                  );
                  Get.back();
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
        if (controller.isLoading.value) {
          return CustomDialog(
            title: 'Processando...',
            content: const Center(child: CircularProgressIndicator()),
            actions: [],
          );
        }
        return CustomDialog(
          title: 'Editar Horário',
          icon: Icons.edit_calendar,
          content: Form(
            key: controller.formEditKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomDrop<Classe>(
                  items: controller.availableClasses,
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
                            if (value == null || value.isEmpty)
                              return 'Obrigatório!';
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
                            if (value == null || value.isEmpty)
                              return 'Obrigatório!';
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
    final actionText = isCurrentlyActive ? 'Inativar' : 'Ativar';
    final message = isCurrentlyActive
        ? 'Tem certeza que deseja INATIVAR o horário das ${Grade.formatTimeDisplay(grade.startTimeOfDay)} - ${Grade.formatTimeDisplay(grade.endTimeOfDay)} (${_getDayName(grade.dayOfWeek)}) da turma "${grade.classe?.name ?? 'N/A'}"?\n\nEle não aparecerá mais nas listas ativas, mas o histórico será mantido e você poderá reativá-lo.'
        : 'Tem certeza que deseja ATIVAR o horário das ${Grade.formatTimeDisplay(grade.startTimeOfDay)} - ${Grade.formatTimeDisplay(grade.endTimeOfDay)} (${_getDayName(grade.dayOfWeek)}) da turma "${grade.classe?.name ?? 'N/A'}"?\n\nEle voltará a aparecer nas listas ativas.';

    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return CustomDialog(
            title: 'Processando...',
            content: const Center(child: CircularProgressIndicator()),
            actions: [],
          );
        }
        return CustomDialog(
          title: '$actionText Horário',
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await controller.toggleGradeStatus(grade);
                Get.back();
              },
              child: Text(actionText),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }

  void _showFilterDialog() {
    controller.resetFilterFields();
    Get.dialog(
      Obx(() {
        if (controller.isLoading.value) {
          return CustomDialog(
            title: 'Processando...',
            content: const Center(child: CircularProgressIndicator()),
            actions: [],
          );
        }
        return CustomDialog(
          title: 'Filtrar Horários',
          icon: Icons.filter_list,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomDrop<Classe>(
                items: controller.availableClasses,
                value: controller.selectedFilterClasse.value,
                labelBuilder: (c) => '${c.name} (${c.schoolYear})',
                onChanged: (c) => controller.selectedFilterClasse.value = c,
                hint: 'Filtrar por Turma',
              ),
              const SizedBox(height: 16),
              CustomDrop<Discipline>(
                items: controller.availableDisciplines,
                value: controller.selectedFilterDiscipline.value,
                labelBuilder: (d) => d.name,
                onChanged: (d) => controller.selectedFilterDiscipline.value = d,
                hint: 'Filtrar por Disciplina',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Dia da Semana',
                  border: OutlineInputBorder(),
                ),
                value: controller.selectedFilterDayOfWeek.value,
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Todos os Dias'),
                  ),
                  ..._daysOfWeek.map((day) {
                    return DropdownMenuItem(
                      value: day['value'] as int,
                      child: Text(day['label'] as String),
                    );
                  }).toList(),
                ],
                onChanged: (day) {
                  controller.selectedFilterDayOfWeek.value = day;
                },
                hint: const Text('Filtrar por Dia'),
                // CORREÇÃO: Validação customizada para Dropdown (verifica se 'value' é nulo)
                validator: (value) {
                  if (value == null) {
                    return 'Campo obrigatório!'; // Pode ser "Selecione um dia" ou vazio para "Todos"
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Ano Letivo',
                  border: OutlineInputBorder(),
                ),
                value: controller.selectedFilterYear.value,
                items: List.generate(11, (i) => DateTime.now().year - 5 + i)
                    .map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    })
                    .toList(),
                onChanged: (year) {
                  controller.selectedFilterYear.value = year!;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Mostrar apenas ativos'),
                value: controller.showOnlyActiveGrades.value,
                onChanged: (value) {
                  controller.showOnlyActiveGrades.value = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.resetFilterFields();
                controller.loadAllGrades();
                Get.back();
              },
              child: const Text('Resetar Filtros'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.loadAllGrades();
                Get.back();
              },
              child: const Text('Aplicar Filtros'),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }
}
