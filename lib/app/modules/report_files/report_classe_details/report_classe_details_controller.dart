import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/repositories/report_files/i_report_files_repository.dart';
import 'package:vocatus/app/repositories/report_files/report_files_repository.dart';

class ReportClasseDetailsController extends GetxController {
  final IReportFilesRepository _reportRepository = ReportFilesRepository(
    DatabaseHelper.instance,
  );

  late int classeId;
  final Rx<Classe?> classeDetails = Rx<Classe?>(null);
  final RxList<Student> allClassStudents = <Student>[].obs;
  final RxList<Grade> classSchedules = <Grade>[].obs;
  final RxList<Attendance> classAttendances = <Attendance>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is int) {
      classeId = Get.arguments as int;
      fetchClasseDetails();
    } else {
      errorMessage.value = 'Erro: ID da turma não fornecido ou inválido para o relatório.';
      isLoading.value = false;
    }
  }

  Future<void> fetchClasseDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      classeDetails.value = null;
      allClassStudents.clear();
      classSchedules.clear();
      classAttendances.clear();

      final Classe? details = await _reportRepository.getClasseById(classeId);
      if (details == null) {
        errorMessage.value = 'Turma com ID $classeId não encontrada ou arquivada.';
        isLoading.value = false;
        return;
      }
      classeDetails.value = details;

      final List<Student> students = await _reportRepository.getStudentsAssociatedWithClasseHistory(classeId);
      allClassStudents.assignAll(students);
      allClassStudents.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      final List<Grade> schedules = await _reportRepository.getClasseSchedulesHistory(classeId);
      classSchedules.assignAll(schedules);
      classSchedules.sort((a, b) {
        if (a.dayOfWeek != b.dayOfWeek) {
          return a.dayOfWeek.compareTo(b.dayOfWeek);
        }
        return a.startTimeTotalMinutes.compareTo(b.startTimeTotalMinutes);
      });

      final List<Attendance> attendances = await _reportRepository.getClasseAttendances(classeId);
      classAttendances.assignAll(attendances);
      classAttendances.sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      errorMessage.value = 'Erro ao carregar detalhes da turma: $e';
    } finally {
      isLoading.value = false;
    }
  }
}