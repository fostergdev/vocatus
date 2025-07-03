import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/occurrence.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/repositories/occurrence/occurrence_repository.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';

class OccurrenceController extends GetxController {
  final OccurrenceRepository _occurrenceRepository = OccurrenceRepository(
    DatabaseHelper.instance,
  );

  final Attendance currentAttendance = Get.arguments as Attendance;

  final isLoading = false.obs;
  final occurrences = <Occurrence>[].obs;
  final availableStudents = <Student>[].obs;

  final descriptionEC = TextEditingController();
  final titleEC = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final selectedStudent = Rx<Student?>(null);
  final selectedType = Rx<OccurrenceType?>(null);
  final selectedDate = Rx<DateTime?>(null);
  final isGeneralOccurrence = false.obs;

  final filterType = Rx<OccurrenceType?>(null);
  final showGeneralOnly = false.obs;
  final showStudentOnly = false.obs;

  @override
  void onInit() {
    selectedDate.value = DateTime.now();
    loadOccurrences();
    loadAvailableStudents();
    super.onInit();
  }

  @override
  void onClose() {
    descriptionEC.dispose();
    titleEC.dispose();
    super.onClose();
  }

  Future<void> loadOccurrences() async {
    try {
      isLoading.value = true;
      
      List<Occurrence> result = await _occurrenceRepository.getOccurrencesByAttendanceId(
        currentAttendance.id!,
      );
      
      
      result = _applyFilters(result);
      
      occurrences.value = result;
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro',
          message: 'Erro ao carregar ocorrências: $e',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAvailableStudents() async {
    try {
      final result = await _occurrenceRepository.getStudentsFromAttendance(
        currentAttendance.id!,
      );
      
      availableStudents.value = result;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar alunos: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> createOccurrence() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedDate.value == null) {
      Get.snackbar(
        'Erro',
        'Selecione a data da ocorrência',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    try {
      final occurrence = Occurrence(
        attendanceId: currentAttendance.id!,
        studentId: isGeneralOccurrence.value ? null : selectedStudent.value?.id,
        occurrenceType: selectedType.value,
        title: titleEC.text.trim(),
        description: descriptionEC.text.trim(),
        occurrenceDate: selectedDate.value!,
      );

      await _occurrenceRepository.createOccurrence(occurrence);
      
      clearForm();
      Get.back();
      loadOccurrences();
      
      Get.snackbar(
        'Sucesso',
        'Ocorrência registrada com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro ao Criar Ocorrência',
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> updateOccurrence(Occurrence occurrence) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedDate.value == null) return;

    try {
      final updatedOccurrence = occurrence.copyWith(
        studentId: isGeneralOccurrence.value ? null : selectedStudent.value?.id,
        occurrenceType: selectedType.value,
        title: titleEC.text.trim(),
        description: descriptionEC.text.trim(),
        occurrenceDate: selectedDate.value!,
      );

      await _occurrenceRepository.updateOccurrence(updatedOccurrence);
      
      clearForm();
      Get.back();
      loadOccurrences();
      
      Get.snackbar(
        'Sucesso',
        'Ocorrência atualizada com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro ao Atualizar Ocorrência',
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteOccurrence(Occurrence occurrence) async {
    try {
      await _occurrenceRepository.deleteOccurrence(occurrence.id!);
      
      loadOccurrences();
      
      Get.snackbar(
        'Sucesso',
        'Ocorrência excluída com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro ao Excluir Ocorrência',
          message: e.toString(),
        ),
      );
    }
  }

  void clearForm() {
    descriptionEC.clear();
    titleEC.clear();
    selectedStudent.value = null;
    selectedType.value = null;
    selectedDate.value = DateTime.now();
    isGeneralOccurrence.value = false;
  }

  void prepareEditOccurrence(Occurrence occurrence) {
    descriptionEC.text = occurrence.description;
    titleEC.text = occurrence.title ?? '';
    selectedStudent.value = occurrence.student;
    selectedType.value = occurrence.occurrenceType;
    selectedDate.value = occurrence.occurrenceDate;
    isGeneralOccurrence.value = occurrence.isGeneralOccurrence;
  }

  void setFilterType(OccurrenceType? type) {
    filterType.value = type;
    showGeneralOnly.value = false;
    showStudentOnly.value = false;
    loadOccurrences();
  }

  void setFilterGeneral(bool general) {
    showGeneralOnly.value = general;
    showStudentOnly.value = false;
    filterType.value = null;
    loadOccurrences();
  }

  void setFilterStudent(bool student) {
    showStudentOnly.value = student;
    showGeneralOnly.value = false;
    filterType.value = null;
    loadOccurrences();
  }

  void clearAllFilters() {
    filterType.value = null;
    showGeneralOnly.value = false;
    showStudentOnly.value = false;
    loadOccurrences();
  }

  List<Occurrence> _applyFilters(List<Occurrence> occurrences) {
    List<Occurrence> filtered = occurrences;

    if (filterType.value != null) {
      filtered = filtered.where((o) => o.occurrenceType == filterType.value).toList();
    }

    if (showGeneralOnly.value) {
      filtered = filtered.where((o) => o.isGeneralOccurrence).toList();
    }

    if (showStudentOnly.value) {
      filtered = filtered.where((o) => o.isStudentOccurrence).toList();
    }

    return filtered;
  }

  String formatOccurrenceDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String getOccurrenceTypeDisplayName(OccurrenceType? type) {
    if (type == null) return 'Não especificado';
    switch (type) {
      case OccurrenceType.comportamento:
        return 'Comportamento';
      case OccurrenceType.saude:
        return 'Saúde';
      case OccurrenceType.atraso:
        return 'Atraso';
      case OccurrenceType.material:
        return 'Material';
      case OccurrenceType.geral:
        return 'Geral';
      case OccurrenceType.outros:
        return 'Outros';
    }
  }

  Color getOccurrenceTypeColor(OccurrenceType? type) {
    if (type == null) return Colors.grey;
    switch (type) {
      case OccurrenceType.comportamento:
        return Colors.orange;
      case OccurrenceType.saude:
        return Colors.red;
      case OccurrenceType.atraso:
        return Colors.purple;
      case OccurrenceType.material:
        return Colors.brown;
      case OccurrenceType.geral:
        return Colors.blue;
      case OccurrenceType.outros:
        return Colors.grey;
    }
  }

  IconData getOccurrenceTypeIcon(OccurrenceType? type) {
    if (type == null) return Icons.report;
    switch (type) {
      case OccurrenceType.comportamento:
        return Icons.psychology;
      case OccurrenceType.saude:
        return Icons.local_hospital;
      case OccurrenceType.atraso:
        return Icons.access_time;
      case OccurrenceType.material:
        return Icons.inventory;
      case OccurrenceType.geral:
        return Icons.info;
      case OccurrenceType.outros:
        return Icons.more_horiz;
    }
  }
}