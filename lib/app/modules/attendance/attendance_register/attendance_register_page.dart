import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_popbutton.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import './attendance_register_controller.dart';

class AttendanceRegisterPage extends GetView<AttendanceRegisterController> {
  const AttendanceRegisterPage({super.key});

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'SEG';
      case 2:
        return 'TER';
      case 3:
        return 'QUA';
      case 4:
        return 'QUI';
      case 5:
        return 'SEX';
      case 6:
        return 'SÁB';
      case 0:
        return 'DOM';
      default:
        return 'Desconhecido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Grade selectedGrade = controller.grade;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedGrade.classe?.name ?? 'Turma',
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
              color: Constants.primaryColor.withValues(
                alpha: .05,
              ), // Fundo suave
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_getDayName(selectedGrade.dayOfWeek)}, ${DateFormat('dd/MM/yyyy').format(controller.selectedDate.value)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Constants.primaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: Colors.purple.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${Grade.formatTimeDisplay(selectedGrade.startTimeOfDay)} - ${Grade.formatTimeDisplay(selectedGrade.endTimeOfDay)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.purple.shade700,
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
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedGrade.discipline?.name ??
                          'Discipina Não Definida',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Campo de Texto de Conteúdo da Aula - Novo Layout
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ), // Aumenta o padding superior
            child: CustomTextField(
              hintText: "Conteúdo da Aula",
              maxLines: 3,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              controller: controller.contentController,
              decoration: InputDecoration(
                labelText: "Conteúdo da Aula",
                alignLabelWithHint: true,
                filled: true, // Fundo preenchido
                fillColor: Colors.grey.shade100, // Cor de preenchimento
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), // Mais arredondado
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Constants.primaryColor,
                    width: 2.0,
                  ),
                ),
                hintText: "Digite o conteúdo da aula...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
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
                        // Navegar para o módulo de homework da turma atual
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
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade800,
                          );
                        }
                      },
                    ),
                    CustomPopupMenuItem(
                      label: 'Registrar Ocorrência',
                      icon: Icons.report,
                      onTap: () async {
                        // Primeiro salva a chamada se houver dados
                        if (controller.studentAttendances.isNotEmpty) {
                          await controller.saveAttendance();
                        }
                        
                        // Verifica se há uma chamada salva para navegar
                        if (controller.currentAttendanceId.value != null) {
                          // Cria um objeto Attendance para passar como argumento
                          final attendance = controller.createAttendanceObject();
                          Get.toNamed('/occurrence', arguments: attendance);
                        } else {
                          Get.snackbar(
                            'Atenção',
                            'É necessário salvar a chamada antes de registrar ocorrências.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange.shade100,
                            colorText: Colors.orange.shade800,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista de Alunos para Chamada - Novo Layout
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.studentAttendances.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        color: Colors.grey.shade400,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Nenhum aluno encontrado para esta turma/chamada.',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Verifique a configuração da turma ou a lista de alunos.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
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
                    child: CheckboxListTile(
                      title: Text(
                        studentAttendance.student?.name ?? 'Aluno desconhecido',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        studentAttendance.presence == PresenceStatus.present
                            ? 'Presente'
                            : 'Ausente',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              studentAttendance.presence ==
                                  PresenceStatus.present
                              ? Colors.green
                              : Colors.red,
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
                    ? Colors.grey 
                    : Constants.primaryColor,
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
