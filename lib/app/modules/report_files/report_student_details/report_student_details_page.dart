import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/modules/report_files/report_student_details/report_student_details_controller.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/models/grade.dart';

class ReportStudentDetailsPage extends GetView<ReportStudentDetailsController> {
  const ReportStudentDetailsPage({super.key});

  String getPresenceStatusText(PresenceStatus status) {
    switch (status) {
      case PresenceStatus.present:
        return 'Presente';
      case PresenceStatus.absent:
        return 'Ausente';
      case PresenceStatus.justified:
        return 'Justificado';
      default:
        return 'Desconhecido';
    }
  }

  Color getPresenceStatusColor(PresenceStatus status) {
    switch (status) {
      case PresenceStatus.present:
        return Colors.green.shade700;
      case PresenceStatus.absent:
        return Colors.red.shade700;
      case PresenceStatus.justified:
        return Colors.orange.shade700;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) {
      return 'N/A';
    }
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.studentDetails.value?.name ?? 'Detalhes do Aluno',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }

        if (controller.studentDetails.value == null) {
          return const Center(
            child: Text(
              'Detalhes do aluno não encontrados.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final List<Classe> classesWithAttendances = controller
            .groupedAttendances
            .keys
            .toList();
        classesWithAttendances.sort((a, b) => a.name.compareTo(b.name));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações do Aluno',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Constants.primaryColor,
                        ),
                      ),
                      const Divider(height: 20, thickness: 1),
                      buildInfoRow(
                        'ID:',
                        controller.studentDetails.value!.id.toString(),
                      ),
                      buildInfoRow(
                        'Nome:',
                        controller.studentDetails.value!.name,
                      ),
                      buildInfoRow(
                        'Registro:',
                        controller.studentDetails.value!.createdAt != null
                            ? DateFormat('dd-MM-yyyy \'às\' HH:mm:ss').format(
                                controller.studentDetails.value!.createdAt!,
                              )
                            : 'N/A',
                      ),
                      buildInfoRow(
                        'Status:',
                        (controller.studentDetails.value!.active ?? true)
                            ? 'Ativo'
                            : 'Arquivado',
                        color: (controller.studentDetails.value!.active ?? true)
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Histórico',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor,
                ),
              ),
              const Divider(height: 20, thickness: 1),
              if (controller.studentInactiveEnrollments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Este aluno não possui matrículas em turmas inativas.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.studentInactiveEnrollments.length,
                  itemBuilder: (context, index) {
                    final classe = controller.studentInactiveEnrollments[index];
                    final List<StudentAttendance> attendancesInClass =
                        controller.groupedAttendances[classe] ?? [];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ExpansionTile(
                        leading: Icon(
                          Icons.class_,
                          color: Constants.primaryColor,
                        ),
                        title: Text(
                          classe.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Text('${classe.schoolYear}'),
                        childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        controlAffinity: (attendancesInClass.isEmpty)
                            ? ListTileControlAffinity.leading
                            : ListTileControlAffinity.trailing,
                        children: [
                          if (attendancesInClass.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Nenhuma chamada registrada para este aluno nesta turma inativa.',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: attendancesInClass.length,
                              itemBuilder: (context, idx) {
                                final studentAttendance =
                                    attendancesInClass[idx];
                                final Attendance? attendance =
                                    studentAttendance.attendance;
                                final Grade? gradeDaPresenca =
                                    attendance?.grade;

                                String presenceDate = attendance?.date != null
                                    ? DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(attendance!.date)
                                    : 'Data Desconhecida';

                                String dayOfWeek = '';
                                String horario = '';

                                if (gradeDaPresenca != null) {
                                  dayOfWeek = _getDayOfWeekName(
                                    gradeDaPresenca.dayOfWeek,
                                  );
                                  String start = _formatTimeOfDay(
                                    gradeDaPresenca.startTimeOfDay,
                                  );
                                  String end = _formatTimeOfDay(
                                    gradeDaPresenca.endTimeOfDay,
                                  );
                                  horario = '$start até $end';
                                } else {
                                  dayOfWeek = attendance?.date != null
                                      ? _getDayOfWeekName(
                                          attendance!.date.weekday,
                                        )
                                      : 'Dia Desconhecido';
                                  horario = 'Horário Não Informado';
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Card(
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$dayOfWeek: $presenceDate',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Horário: $horario',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Text(
                                                'Status: ',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Text(
                                                getPresenceStatusText(
                                                  studentAttendance.presence,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: getPresenceStatusColor(
                                                    studentAttendance.presence,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: Text(
                                              'Registrado em: ${studentAttendance.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(studentAttendance.createdAt!) : 'N/A'}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: color ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayOfWeekName(int dayOfWeek) {
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
      case 7:
        return 'Domingo';
      default:
        return 'Dia Desconhecido';
    }
  }
}
