import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import 'package:vocatus/app/repositories/attendance/attendance_register/attendance_register_repository.dart';

class AttendanceRegisterController extends GetxController {
  final AttendanceRegisterRepository _attendanceRepository =
      AttendanceRegisterRepository(DatabaseHelper.instance);

  final isLoading = false.obs;

  // A 'Grade' (horário) para a qual a chamada será feita, passada como argumento
  late final Grade grade;

  // Data selecionada para a chamada (agora inicializada com a data passada)
  final Rx<DateTime> selectedDate =
      DateTime.now().obs; // Inicialização provisória

  // Lista de alunos da turma, com seu status de presença
  final RxList<StudentAttendance> studentAttendances =
      <StudentAttendance>[].obs;

  // ID da chamada atual (se já existe uma para a grade e data selecionada)
  final RxnInt currentAttendanceId = RxnInt(null);

  @override
  void onInit() {
    super.onInit();
    // Verifica se os argumentos são um Map e contêm 'grade' e 'date'
    if (Get.arguments is Map &&
        Get.arguments.containsKey('grade') &&
        Get.arguments['grade'] is Grade &&
        Get.arguments.containsKey('date') &&
        Get.arguments['date'] is DateTime) {
      grade = Get.arguments['grade'] as Grade;
      selectedDate.value =
          Get.arguments['date'] as DateTime; // <--- ATENÇÃO AQUI
      loadAttendanceData();
    } else {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro de Navegação',
          message:
              'Nenhum horário agendado ou data foi selecionado corretamente.',
        ),
      );
      throw Exception(
        'Argumentos Grade e/ou Data ausentes ou inválidos para AttendanceRegisterController.',
      );
    }
  }

  // Carrega os dados da chamada: se já existe para a Grade e Data, carrega.
  // Se não, carrega todos os alunos ATIVOS da turma como 'presentes' por padrão.
  Future<void> loadAttendanceData() async {
    try {
      isLoading.value = true;
      if (grade.id == null || grade.classeId == null) {
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message:
                'Dados da aula incompletos. Não foi possível carregar a chamada.',
          ),
        );
        return;
      }

      // Tenta carregar uma chamada existente para esta Grade e Data
      final existingAttendance = await _attendanceRepository
          .getAttendanceByGradeAndDate(
            grade.id!,
            selectedDate.value,
          ); // Usa selectedDate.value

      if (existingAttendance != null) {
        currentAttendanceId.value = existingAttendance.id;
        final fetchedStudentAttendances = await _attendanceRepository
            .getStudentAttendancesByAttendanceId(existingAttendance.id!);
        studentAttendances.assignAll(fetchedStudentAttendances);
      } else {
        currentAttendanceId.value = null;
        // Agora o attendanceRepository busca os alunos da turma
        final studentsInClass = await _attendanceRepository
            .getStudentsByClasseId(
              grade.classeId!,
            ); // classeId não pode ser nulo

        studentAttendances.assignAll(
          studentsInClass
              .map(
                (s) => StudentAttendance(
                  attendanceId: 0, // Será atualizado na hora de salvar
                  studentId: s.id!,
                  presence: PresenceStatus.present,
                  student: s,
                ),
              )
              .toList(),
        );
      }
      studentAttendances.sort(
        (a, b) => (a.student?.name ?? '').compareTo(b.student?.name ?? ''),
      );
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro',
          message: 'Erro ao carregar dados da chamada: ${e.toString()}',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleStudentPresence(StudentAttendance sa, PresenceStatus status) {
    final index = studentAttendances.indexOf(sa);
    if (index != -1) {
      studentAttendances[index] = sa.copyWith(presence: status);
    }
  }

  Future<void> saveAttendance() async {
    try {
      isLoading.value = true;
      if (grade.id == null) {
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message:
                'Dados da aula incompletos. Não foi possível salvar a chamada.',
          ),
        );
        return;
      }

      final attendance = Attendance(
        id: currentAttendanceId.value,
        classeId: grade.classeId!, // Garante que classeId não é nulo
        gradeId: grade.id!,
        date: selectedDate.value, // Usa a data selecionada/passada
      );

      final savedAttendance = await _attendanceRepository
          .createOrUpdateAttendance(attendance, studentAttendances.toList());
      currentAttendanceId.value = savedAttendance.id;
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro ao Salvar Chamada',
          message: e.toString(),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToPreviousDay() {
    selectedDate.value = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day - 1,
    );
    loadAttendanceData();
  }

  void goToNextDay() {
    selectedDate.value = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day + 1,
    );
    loadAttendanceData();
  }

  void goToToday() {
    // Para garantir que a "hoje" seja apenas a data, sem horas/minutos/segundos
    final now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month, now.day);
    loadAttendanceData();
  }
}
