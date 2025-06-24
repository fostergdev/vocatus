// lib/app/modules/report_files/report_student_details/report_student_details_controller.dart

import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import 'package:vocatus/app/repositories/report_files/report_files_repository.dart';
import 'package:vocatus/app/repositories/report_files/i_report_files_repository.dart';

class ReportStudentDetailsController extends GetxController {
  final IReportFilesRepository _repository = ReportFilesRepository(
    DatabaseHelper.instance,
  );

  late int studentId;
  final Rx<Student?> studentDetails = Rx<Student?>(null);
  final RxList<Classe> studentInactiveEnrollments = <Classe>[].obs;
  final RxMap<Classe, RxList<StudentAttendance>> groupedAttendances =
      <Classe, RxList<StudentAttendance>>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is int) {
      studentId = Get.arguments as int;
      fetchStudentDetails();
    } else {
      errorMessage.value = 'Erro: ID do aluno não fornecido ou inválido para o relatório.';
      isLoading.value = false;
    }
  }

  Future<void> fetchStudentDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      groupedAttendances.clear();
      studentInactiveEnrollments.clear();

      final Student? details = await _repository.getStudentById(studentId);
      if (details == null) {
        errorMessage.value = 'Aluno com ID $studentId não encontrado ou não disponível.';
        return;
      }
      studentDetails.value = details;

      final List<Classe> inactiveEnrollments = await _repository.getStudentInactiveEnrollments(studentId);
      studentInactiveEnrollments.assignAll(inactiveEnrollments);
      studentInactiveEnrollments.sort((a, b) => a.name.compareTo(b.name));

      final List<StudentAttendance> allStudentAttendances =
          await _repository.getStudentAttendanceHistory(studentId);

      for (var sa in allStudentAttendances) {
        final classe = sa.attendance?.classe;
        if (classe != null && studentInactiveEnrollments.any((inactiveClasse) => inactiveClasse.id == classe.id)) {
          if (!groupedAttendances.containsKey(classe)) {
            groupedAttendances[classe] = <StudentAttendance>[].obs;
          }
          groupedAttendances[classe]!.add(sa);
        }
      }

      groupedAttendances.forEach((classe, attendancesList) {
        attendancesList.sort((a, b) {
          final dateA = a.attendance?.date;
          final dateB = b.attendance?.date;
          if (dateA == null || dateB == null) return 0;
          return dateA.compareTo(dateB);
        });
      });

    } catch (e) {
      errorMessage.value = 'Erro ao carregar os detalhes do relatório do aluno: $e';
    } finally {
      isLoading.value = false;
    }
  }
}