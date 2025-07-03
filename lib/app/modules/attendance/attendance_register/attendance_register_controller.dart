import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'package:vocatus/app/models/schedule.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import 'package:vocatus/app/modules/attendance/attendance_select/attendance_select_controller.dart';
import 'package:vocatus/app/repositories/attendance/attendance_register/attendance_register_repository.dart';
import 'package:vocatus/app/repositories/attendance/attendance_register/i_attendance_register_repository.dart';

class AttendanceRegisterController extends GetxController {
  late final IAttendanceRegisterRepository _attendanceRepository;

  final isLoading = false.obs;
  late final Schedule schedule;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<StudentAttendance> studentAttendances = <StudentAttendance>[].obs;
  final RxnInt currentAttendanceId = RxnInt(null);
  final TextEditingController contentController = TextEditingController();

  
  AttendanceRegisterController({
    IAttendanceRegisterRepository? attendanceRepository,
  }) : _attendanceRepository = attendanceRepository ?? AttendanceRegisterRepository(DatabaseHelper.instance);

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      schedule = Get.arguments['schedule'];
      selectedDate.value = Get.arguments['date'];
    } else {
      
      
      
      
      throw Exception('Schedule and selectedDate must be provided as arguments.');
    }
    loadAttendanceData();
  }

  Future<void> loadAttendanceData() async {
    try {
      isLoading.value = true;
      studentAttendances.clear();
      if (schedule.id == null) {
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
          .getAttendanceByScheduleAndDate(
            schedule.id!,
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
              schedule.classeId,
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
      if (schedule.id == null) {
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
        classeId: schedule.classeId,
        scheduleId: schedule.id!,
        date: selectedDate.value,
        content: contentController.text,
      );

      final savedAttendance = await _attendanceRepository
          .createOrUpdateAttendance(attendance, studentAttendances.toList());
      currentAttendanceId.value = savedAttendance.id;

      if (Get.isRegistered<AttendanceSelectController>()) {
        Get.find<AttendanceSelectController>().loadAvailableSchedules();
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

  Attendance createAttendanceObject() {
    return Attendance(
      id: currentAttendanceId.value,
      classeId: schedule.classeId,
      scheduleId: schedule.id!,
      date: selectedDate.value,
      content: contentController.text,
      active: true,
    );
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}
