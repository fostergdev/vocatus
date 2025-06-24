import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Para formatar datas e horas
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/modules/report_files/report_classe_details/report_classe_details_controller.dart';

class ReportClasseDetailsPage extends GetView<ReportClasseDetailsController> {
  const ReportClasseDetailsPage({super.key});

  // Função auxiliar para formatar TimeOfDay para exibição
  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) {
      return 'N/A';
    }
    // Usa o contexto global para garantir que o MaterialLocalizations esteja disponível
    final localizations = MaterialLocalizations.of(Get.context!);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }

  // Função auxiliar para obter o nome do dia da semana em português
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

  // Widget auxiliar para construir linhas de informação
  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Largura fixa para os rótulos
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Título da AppBar reativo ao nome da turma
        title: Obx(
          () => Text(
            controller.classeDetails.value?.name ?? 'Detalhes da Turma',
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
        iconTheme: const IconThemeData(color: Colors.white), // Ícone de voltar branco
      ),
      body: Obx(() {
        // Exibe CircularProgressIndicator enquanto carrega
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Exibe mensagem de erro se houver
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

        // Exibe mensagem se os detalhes da turma não forem encontrados
        if (controller.classeDetails.value == null) {
          return const Center(
            child: Text(
              'Detalhes da turma não encontrados.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Extrai os dados do controller para uso na UI
        final Classe classe = controller.classeDetails.value!;
        final List<Student> students = controller.allClassStudents;
        final List<Grade> schedules = controller.classSchedules;
        final List<Attendance> attendances = controller.classAttendances;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Seção: Informações da Turma ---
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
                        'Informações da Turma',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Constants.primaryColor,
                        ),
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildInfoRow('ID:', classe.id.toString()),
                      _buildInfoRow('Nome:', classe.name),
                      _buildInfoRow(
                        'Ano Letivo:',
                        classe.schoolYear.toString(),
                      ),
                      _buildInfoRow(
                        'Descrição:',
                        classe.description?.isNotEmpty == true
                            ? classe.description!
                            : 'N/A',
                      ),
                      _buildInfoRow(
                        'Registro:',
                        classe.createdAt != null
                            ? DateFormat(
                                'dd-MM-yyyy \'às\' HH:mm:ss',
                              ).format(classe.createdAt!)
                            : 'N/A',
                      ),
                      _buildInfoRow(
                        'Status:',
                        (classe.active ?? true) ? 'Ativa' : 'Arquivada',
                        color: (classe.active ?? true)
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- ExpansionTile: Alunos da Turma ---
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Alunos da Turma (${students.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor,
                    ),
                  ),
                  leading: Icon(Icons.people, color: Constants.primaryColor),
                  initiallyExpanded: true, // Começa expandido
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: [
                    if (students.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Nenhum aluno associado a esta turma.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Colors.blueGrey,
                              ),
                              title: Text(
                                student.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                (student.active ?? true)
                                    ? 'Ativo na Plataforma'
                                    : 'Arquivado na Plataforma',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (student.active ?? true)
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              onTap: () {
                                Get.toNamed(
                                  '/report_student_details',
                                  arguments: student.id,
                                );
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // --- ExpansionTile: Horários da Turma ---
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Horários da Turma (${schedules.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor,
                    ),
                  ),
                  leading: Icon(Icons.schedule, color: Constants.primaryColor),
                  initiallyExpanded: false, // Começa fechado
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: [
                    if (schedules.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Nenhum horário agendado para esta turma.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: schedules.length,
                        itemBuilder: (context, index) {
                          final grade = schedules[index];
                          String startTime = _formatTimeOfDay(
                            grade.startTimeOfDay,
                          );
                          String endTime = _formatTimeOfDay(grade.endTimeOfDay);
                          // Exibe a disciplina se ela existir, caso contrário, indica que não foi atribuída
                          String disciplineName =
                              grade.discipline?.name ?? 'Disciplina Não Atribuída';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getDayOfWeekName(grade.dayOfWeek)}: $startTime - $endTime',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Disciplina: $disciplineName',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  if (grade.active != null && !grade.active!)
                                    const Text(
                                      'Status: Inativo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // --- ExpansionTile: Histórico de Chamadas da Turma ---
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text(
                    'Histórico de Chamadas (${attendances.length})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor,
                    ),
                  ),
                  leading: Icon(Icons.book, color: Constants.primaryColor),
                  initiallyExpanded: false, // Começa fechado
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  children: [
                    if (attendances.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Nenhuma chamada registrada para esta turma.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: attendances.length,
                        itemBuilder: (context, index) {
                          final attendance = attendances[index];
                          final Grade? gradeAssociated = attendance.grade;

                          String dayNameForAttendance = _getDayOfWeekName(attendance.date.weekday);

                          String timeRangeForAttendance = 'Horário Não Atribuído';
                          String disciplineNameForAttendance = '';

                          if (gradeAssociated != null) {
                            final String start = _formatTimeOfDay(
                              gradeAssociated.startTimeOfDay,
                            );
                            final String end = _formatTimeOfDay(
                              gradeAssociated.endTimeOfDay,
                            );
                            timeRangeForAttendance = '$start - $end';
                            // Aqui o nome da disciplina será exibido se o gradeAssociated.discipline não for nulo
                            if (gradeAssociated.discipline?.name != null &&
                                gradeAssociated.discipline!.name.isNotEmpty) {
                              disciplineNameForAttendance =
                                  ' (${gradeAssociated.discipline!.name})';
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data: ${DateFormat('dd/MM/yyyy').format(attendance.date)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Horário: $dayNameForAttendance, $timeRangeForAttendance$disciplineNameForAttendance',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  if (attendance.content?.isNotEmpty == true)
                                    Text(
                                      'Conteúdo: ${attendance.content!}',
                                      style:TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Registrado em: ${attendance.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(attendance.createdAt!) : 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}