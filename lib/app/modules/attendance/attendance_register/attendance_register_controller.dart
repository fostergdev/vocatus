import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import 'package:vocatus/app/modules/attendance/attendance_select/attendance_select_controller.dart';
import 'package:vocatus/app/repositories/attendance/attendance_register/attendance_register_repository.dart';

class AttendanceRegisterController extends GetxController {
  final AttendanceRegisterRepository _attendanceRepository =
      AttendanceRegisterRepository(DatabaseHelper.instance);

  final isLoading = false.obs;
  late final Grade grade;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<StudentAttendance> studentAttendances = <StudentAttendance>[].obs;
  final RxnInt currentAttendanceId = RxnInt(null);
  final TextEditingController contentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map &&
        Get.arguments.containsKey('grade') &&
        Get.arguments['grade'] is Grade &&
        Get.arguments.containsKey('date') &&
        Get.arguments['date'] is DateTime) {
      grade = Get.arguments['grade'] as Grade;
      selectedDate.value = Get.arguments['date'] as DateTime;
      loadAttendanceData();
    } else {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro de Navegação',
          message:
              'Nenhum horário agendado ou data foi selecionada corretamente.',
        ),
      );
      throw Exception(
        'Argumentos Grade e/ou Data ausentes ou inválidos para AttendanceRegisterController.',
      );
    }
  }

  Future<void> loadAttendanceData() async {
    try {
      isLoading.value = true;
      if (grade.id == null) {
        Get.dialog(
          CustomErrorDialog(
            title: 'Erro',
            message:
                'Dados da aula incompletos. Não foi possível carregar a chamada.',
          ),
        );
        return;
      }

      final existingAttendance = await _attendanceRepository
          .getAttendanceByGradeAndDate(
            grade.id!,
            selectedDate.value,
          );

      if (existingAttendance != null) {
        currentAttendanceId.value = existingAttendance.id;
        contentController.text = existingAttendance.content ?? '';
        final fetchedStudentAttendances = await _attendanceRepository
            .getStudentAttendancesByAttendanceId(existingAttendance.id!);
        studentAttendances.assignAll(fetchedStudentAttendances);
      } else {
        currentAttendanceId.value = null;
        contentController.clear();
        final studentsInClass = await _attendanceRepository
            .getStudentsByClasseId(
              grade.classeId!,
            );

        studentAttendances.assignAll(
          studentsInClass
              .map(
                (s) => StudentAttendance(
                  attendanceId: 0,
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
        classeId: grade.classeId!,
        gradeId: grade.id!,
        date: selectedDate.value,
        content: contentController.text,
      );

      final savedAttendance = await _attendanceRepository
          .createOrUpdateAttendance(attendance, studentAttendances.toList());
      currentAttendanceId.value = savedAttendance.id;

      if (Get.isRegistered<AttendanceSelectController>()) {
        Get.find<AttendanceSelectController>().loadAvailableGrades();
      }
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
    final now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month, now.day);
    loadAttendanceData();
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}
