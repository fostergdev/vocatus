import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';

import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/repositories/reports/reports_repository.dart';
import 'package:vocatus/app/repositories/occurrence/occurrence_repository.dart';

class OccurrenceController extends GetxController {
  final ReportsRepository _reportsRepository = ReportsRepository(
    DatabaseHelper.instance,
  );
  final OccurrenceRepository _occurrenceRepository = OccurrenceRepository(
    DatabaseHelper.instance,
  );

  final RxBool isLoading = true.obs;
  final Rx<Attendance?> attendance = Rx<Attendance?>(null);
  final RxMap<String, List<Map<String, dynamic>>> groupedOccurrences = RxMap<String, List<Map<String, dynamic>>>({});
  final RxList<Student> studentsInClass = <Student>[].obs;

  final TextEditingController descriptionController = TextEditingController();
  final RxString selectedOccurrenceType = 'Comportamento'.obs;
  final RxList<Student> selectedStudents = <Student>[].obs;
  final RxBool isGeneralOccurrence = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Attendance) {
      attendance.value = Get.arguments as Attendance;
      loadData();
    } else {
      isLoading.value = false;
      Get.snackbar('Erro', 'Dados da chamada não fornecidos.');
    }
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      if (attendance.value == null) {
        Get.snackbar('Erro', 'Dados da chamada incompletos.');
        return;
      }

      // Load occurrences for this attendance
      final rawOccurrences = await _reportsRepository.getOccurrencesReportByClassId(attendance.value!.classeId); 
      print('Raw Occurrences from ReportsRepository (OccurrenceController): $rawOccurrences'); // DEBUG
      final Map<String, List<Map<String, dynamic>>> tempGroupedOccurrences = {};

      for (var occ in rawOccurrences) {
        final type = occ['type'] as String? ?? 'Outros'; // Use 'type' as defined in SQL COALESCE
        if (!tempGroupedOccurrences.containsKey(type)) {
          tempGroupedOccurrences[type] = [];
        }
        tempGroupedOccurrences[type]!.add(occ);
      }

      // Sort occurrences within each group by date (descending)
      tempGroupedOccurrences.forEach((key, value) {
        value.sort((a, b) {
          final dateA = DateTime.parse(a['occurrence_date'] ?? a['date']);
          final dateB = DateTime.parse(b['occurrence_date'] ?? b['date']);
          return dateB.compareTo(dateA);
        });
      });
      groupedOccurrences.value = tempGroupedOccurrences;

      // Load students in this class for selection
      final studentsData = await _reportsRepository.getStudentsByClassId(attendance.value!.classeId);
      studentsInClass.assignAll(studentsData.map((data) => Student.fromMap(data)).toList());

    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar as ocorrências: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleStudentSelection(Student student) {
    if (selectedStudents.contains(student)) {
      selectedStudents.remove(student);
    } else {
      selectedStudents.add(student);
    }
  }

  Future<void> addOccurrence() async {
    if (descriptionController.text.isEmpty) {
      Get.snackbar('Erro', 'A descrição da ocorrência não pode ser vazia.');
      return;
    }

    if (!isGeneralOccurrence.value && selectedStudents.isEmpty) {
      Get.snackbar('Erro', 'Selecione pelo menos um aluno ou marque como ocorrência geral.');
      return;
    }

    try {
      isLoading.value = true;
      print('DEBUG: attendance.value!.id: ${attendance.value!.id}');
      print('DEBUG: attendance.value!.date: ${attendance.value!.date}');
      final newOccurrence = {
        'attendance_id': attendance.value!.id,
        'occurrence_type': selectedOccurrenceType.value,
        'description': descriptionController.text,
        'occurrence_date': attendance.value!.date.toIso8601String().split('T')[0],
        'active': 1,
      };

      if (isGeneralOccurrence.value) {
        await _occurrenceRepository.createOccurrence(newOccurrence);
      } else {
        for (var student in selectedStudents) {
          await _occurrenceRepository.createOccurrence({
            ...newOccurrence,
            'student_id': student.id,
          });
        }
      }
      descriptionController.clear();
      selectedStudents.clear();
      isGeneralOccurrence.value = false;
      await loadData(); // Reload occurrences after adding
      Get.snackbar('Sucesso', 'Ocorrência(s) registrada(s) com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível registrar a ocorrência: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}