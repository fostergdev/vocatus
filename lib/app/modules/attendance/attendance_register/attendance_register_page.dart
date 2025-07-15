import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/models/schedule.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import './attendance_register_controller.dart';

class AttendanceRegisterPage extends GetView<AttendanceRegisterController> {
  const AttendanceRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Schedule selectedSchedule = controller.schedule;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedSchedule.classe?.name ?? 'Turma',
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
                colorScheme.primary.withValues(alpha: 0.9),
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
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${Constants.getDayName(selectedSchedule.dayOfWeek)}, ${DateFormat('dd/MM/yyyy').format(controller.selectedDate.value)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${Schedule.formatTimeDisplay(selectedSchedule.startTimeOfDay)} - ${Schedule.formatTimeDisplay(selectedSchedule.endTimeOfDay)}',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedSchedule.discipline?.name ??
                          'Discipina Não Definida',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: CustomTextField(
              hintText:
                  "Conteúdo da Aula", 
              maxLines: 3,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              controller: controller.contentController,
              decoration: InputDecoration(
                
                labelText: "Conteúdo da Aula",
                alignLabelWithHint: true,
                
                
                
                
                enabledBorder: OutlineInputBorder(
                  
                  borderRadius: BorderRadius.circular(
                    16,
                  ), 
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                suffixIcon: CustomPopupMenu(
                  
                  items: [
                    CustomPopupMenuItem(
                      label: 'Adicionar Tarefa',
                      icon: Icons.task,
                      onTap: () {
                        if (controller.schedule.classe != null) {
                          Get.toNamed(
                            '/homework/home',
                            arguments: controller.schedule.classe!,
                          );
                        } else {
                          Get.snackbar(
                            'Erro',
                            'Não foi possível acessar as tarefas. Turma não encontrada.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: colorScheme.errorContainer,
                            colorText: colorScheme.onErrorContainer,
                          );
                        }
                      },
                    ),
                    CustomPopupMenuItem(
                      label: 'Registrar Ocorrência',
                      icon: Icons.report,
                      onTap: () {
                        final attendance = controller.createAttendanceObject();
                        Get.toNamed('/occurrence', arguments: attendance);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                );
              }
              if (controller.studentAttendances.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        color: colorScheme.onSurfaceVariant,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nenhum aluno encontrado para esta turma/chamada.',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Verifique a configuração da turma ou a lista de alunos.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                itemCount: controller.studentAttendances.length,
                itemBuilder: (context, index) {
                  final studentAttendance =
                      controller.studentAttendances[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    color: colorScheme.surface,
                    surfaceTintColor: colorScheme.primaryContainer,
                    child: CheckboxListTile(
                      title: Text(
                        studentAttendance.student?.name ?? 'Aluno desconhecido',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        studentAttendance.presence == PresenceStatus.present
                            ? 'Presente'
                            : 'Ausente',
                        style: textTheme.bodySmall?.copyWith(
                          color:
                              studentAttendance.presence ==
                                  PresenceStatus.present
                              ? colorScheme.tertiary
                              : colorScheme.error,
                        ),
                      ),
                      value:
                          studentAttendance.presence == PresenceStatus.present,
                      onChanged: (bool? value) {
                        controller.toggleStudentPresence(
                          studentAttendance,
                          value == true
                              ? PresenceStatus.present
                              : PresenceStatus.absent,
                        );
                      },
                      controlAffinity: ListTileControlAffinity.trailing,
                      activeColor: colorScheme.primary,
                      checkColor: colorScheme.onPrimary,
                      tileColor: colorScheme.surface,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => controller.studentAttendances.isNotEmpty
            ? FloatingActionButton.small(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        await controller.saveAttendance();
                        Get.back();
                      },
                tooltip: 'Salvar Chamada',
                backgroundColor: controller.isLoading.value
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.primary,
                child: controller.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Icon(Icons.save, color: colorScheme.onPrimary),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
