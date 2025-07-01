import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart'; // Mantenha se ainda usar, mas não foi fornecido o código
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import './attendance_register_controller.dart';

class AttendanceRegisterPage extends GetView<AttendanceRegisterController> {
  const AttendanceRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Grade selectedGrade = controller.grade;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedGrade.classe?.name ?? 'Turma',
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
              color: colorScheme.primaryContainer, // Fundo suave (Material 3)
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1.0), // Borda inferior
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${Constants.getDayName(selectedGrade.dayOfWeek)}, ${DateFormat('dd/MM/yyyy').format(controller.selectedDate.value)}',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary, // Cor do texto de data
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: colorScheme.secondary, // Cor do ícone de tempo
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${Grade.formatTimeDisplay(selectedGrade.startTimeOfDay)} - ${Grade.formatTimeDisplay(selectedGrade.endTimeOfDay)}',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant, // Cor do texto de horário
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
                      color: colorScheme.onSurfaceVariant, // Cor do ícone de disciplina
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedGrade.discipline?.name ?? 'Discipina Não Definida',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface, // Cor do texto de disciplina
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Campo de Texto de Conteúdo da Aula
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: CustomTextField(
              hintText: "Conteúdo da Aula",
              maxLines: 3,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              controller: controller.contentController,
              // O `decoration` do CustomTextField já pega as cores do tema
              // mas podemos sobrescrever aqui se quisermos algo específico
              decoration: InputDecoration(
                labelText: "Conteúdo da Aula",
                alignLabelWithHint: true,
                filled: true,
                fillColor: colorScheme.surfaceVariant, // Fundo preenchido
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary, // Borda focada com a cor primária
                    width: 2.0,
                  ),
                ),
                hintText: "Digite o conteúdo da aula...",
                hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                // O suffixIcon já está usando o CustomPopupMenu customizado por você.
                suffixIcon: CustomPopupMenu(
                  items: [
                    CustomPopupMenuItem(
                      label: 'Adicionar Tarefa',
                      icon: Icons.task,
                      onTap: () {
                        if (controller.grade.classe != null) {
                          Get.toNamed(
                            '/homework/home',
                            arguments: controller.grade.classe!,
                          );
                        } else {
                          Get.snackbar(
                            'Erro',
                            'Não foi possível acessar as tarefas. Turma não encontrada.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: colorScheme.errorContainer, // Cor do tema
                            colorText: colorScheme.onErrorContainer, // Cor do tema
                          );
                        }
                      },
                    ),
                    CustomPopupMenuItem(
                      label: 'Registrar Ocorrência',
                      icon: Icons.report,
                      onTap: () async {
                        if (controller.studentAttendances.isNotEmpty) {
                          await controller.saveAttendance();
                        }
                        
                        if (controller.currentAttendanceId.value != null) {
                          final attendance = controller.createAttendanceObject();
                          Get.toNamed('/occurrence', arguments: attendance);
                        } else {
                          Get.snackbar(
                            'Atenção',
                            'É necessário salvar a chamada antes de registrar ocorrências.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: colorScheme.tertiaryContainer, // Cor do tema
                            colorText: colorScheme.onTertiaryContainer, // Cor do tema
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista de Alunos para Chamada
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary)); // Cor do tema
              }
              if (controller.studentAttendances.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        color: colorScheme.onSurfaceVariant, // Cor do ícone
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nenhum aluno encontrado para esta turma/chamada.',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant, // Cor do texto
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Verifique a configuração da turma ou a lista de alunos.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.8), // Cor do texto
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
                    color: colorScheme.surface, // Fundo do Card
                    surfaceTintColor: colorScheme.primaryContainer, // Tinta de elevação
                    child: CheckboxListTile(
                      title: Text(
                        studentAttendance.student?.name ?? 'Aluno desconhecido',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface, // Cor do texto do nome do aluno
                        ),
                      ),
                      subtitle: Text(
                        studentAttendance.presence == PresenceStatus.present
                            ? 'Presente'
                            : 'Ausente',
                        style: textTheme.bodySmall?.copyWith(
                          color: studentAttendance.presence == PresenceStatus.present
                              ? colorScheme.tertiary // Cor para presente (verde)
                              : colorScheme.error, // Cor para ausente (vermelho)
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
                      activeColor: colorScheme.primary, // Cor do Checkbox quando ativo
                      checkColor: colorScheme.onPrimary, // Cor do ícone de check
                      tileColor: colorScheme.surface, // Cor do tile (fundo)
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
                onPressed: controller.isLoading.value ? null : () async {
                  await controller.saveAttendance();
                  Get.back();
                },
                tooltip: 'Salvar Chamada',
                backgroundColor: controller.isLoading.value 
                    ? colorScheme.surfaceVariant 
                    : colorScheme.primary, // Fundo do FAB
                child: controller.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary), // Cor da animação
                        ),
                      )
                    : Icon(Icons.save, color: colorScheme.onPrimary), // Ícone do FAB
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}