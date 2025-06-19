import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar datas
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/widgets/custom_text_field.dart';
import 'package:vocatus/app/models/grade.dart'; // Modelo Grade para usar formatTimeDisplay
import 'package:vocatus/app/models/student_attendance.dart'; // Modelo StudentAttendance e enum PresenceStatus
import './attendance_register_controller.dart'; // O controller de registro

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
          ),
        ),
        centerTitle: true,
        backgroundColor: Constants.primaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getDayName(selectedGrade.dayOfWeek)}: ${DateFormat('dd/MM/yyyy').format(controller.selectedDate.value)} ${Grade.formatTimeDisplay(selectedGrade.startTimeOfDay)} - ${Grade.formatTimeDisplay(selectedGrade.endTimeOfDay)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                Text(
                  'Disciplina: ${selectedGrade.discipline?.name ?? 'Não Definida'}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: CustomTextField(
              hintText: "Conteúdo",
              maxLines: 1,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: "Conteúdo",
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: "Digite o conteúdo da aula...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.studentAttendances.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum aluno encontrado para esta turma/chamada.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.builder(
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
                        studentAttendance.student?.active ?? true
                            ? 'Ativo na Turma'
                            : 'Inativo na Turma',
                        style: TextStyle(
                          fontSize: 12,
                          color: studentAttendance.student?.active ?? true
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
                onPressed: () async {
                  await controller.saveAttendance();
                  Get.back();
                },
                tooltip: 'Salvar Chamada',
                backgroundColor: Constants.primaryColor,
                child: const Icon(Icons.save, color: Colors.white),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
