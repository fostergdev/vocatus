import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/occurrence.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/repositories/occurrence/occurrence_repository.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'dart:developer';

class OccurrenceController extends GetxController {
  final OccurrenceRepository _occurrenceRepository = OccurrenceRepository(
    DatabaseHelper.instance,
  );

  final Attendance currentAttendance = Get.arguments as Attendance;

  final isLoading = false.obs;
  final occurrences = <Occurrence>[].obs;
  final availableStudents = <Student>[].obs;

  final descriptionEC = TextEditingController();
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
    log('OccurrenceController.onInit - Inicializando controller para chamada: ${currentAttendance.id}', name: 'OccurrenceController');
    selectedDate.value = DateTime.now();
    loadOccurrences();
    loadAvailableStudents();
    super.onInit();
  }

  @override
  void onClose() {
    log('OccurrenceController.onClose - Limpando recursos do controller', name: 'OccurrenceController');
    descriptionEC.dispose();
    super.onClose();
  }

  Future<void> loadOccurrences() async {
    try {
      isLoading.value = true;
      log('OccurrenceController.loadOccurrences - Carregando ocorrências da chamada', name: 'OccurrenceController');
      
      List<Occurrence> result = await _occurrenceRepository.getOccurrencesByAttendanceId(
        currentAttendance.id!,
      );
      
      // Aplicar filtros se necessário
      result = _applyFilters(result);
      
      occurrences.value = result;
      log('OccurrenceController.loadOccurrences - ${result.length} ocorrências carregadas', name: 'OccurrenceController');
    } catch (e) {
      log('OccurrenceController.loadOccurrences - Erro: $e', name: 'OccurrenceController');
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
      log('OccurrenceController.loadAvailableStudents - Carregando alunos da chamada', name: 'OccurrenceController');
      
      final result = await _occurrenceRepository.getStudentsFromAttendance(
        currentAttendance.id!,
      );
      
      availableStudents.value = result;
      log('OccurrenceController.loadAvailableStudents - ${result.length} alunos carregados', name: 'OccurrenceController');
    } catch (e) {
      log('OccurrenceController.loadAvailableStudents - Erro: $e', name: 'OccurrenceController');
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
      log('OccurrenceController.createOccurrence - Criando nova ocorrência', name: 'OccurrenceController');
      
      final occurrence = Occurrence(
        attendanceId: currentAttendance.id!,
        studentId: isGeneralOccurrence.value ? null : selectedStudent.value?.id,
        occurrenceType: selectedType.value,
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
      
      log('OccurrenceController.createOccurrence - Ocorrência criada com sucesso', name: 'OccurrenceController');
    } catch (e) {
      log('OccurrenceController.createOccurrence - Erro: $e', name: 'OccurrenceController');
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
      log('OccurrenceController.updateOccurrence - Atualizando ocorrência: ${occurrence.id}', name: 'OccurrenceController');
      
      final updatedOccurrence = occurrence.copyWith(
        studentId: isGeneralOccurrence.value ? null : selectedStudent.value?.id,
        occurrenceType: selectedType.value,
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
      
      log('OccurrenceController.updateOccurrence - Ocorrência atualizada com sucesso', name: 'OccurrenceController');
    } catch (e) {
      log('OccurrenceController.updateOccurrence - Erro: $e', name: 'OccurrenceController');
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
      log('OccurrenceController.deleteOccurrence - Excluindo ocorrência: ${occurrence.id}', name: 'OccurrenceController');
      
      await _occurrenceRepository.deleteOccurrence(occurrence.id!);
      
      loadOccurrences();
      
      Get.snackbar(
        'Sucesso',
        'Ocorrência excluída com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
      
      log('OccurrenceController.deleteOccurrence - Ocorrência excluída com sucesso', name: 'OccurrenceController');
    } catch (e) {
      log('OccurrenceController.deleteOccurrence - Erro: $e', name: 'OccurrenceController');
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
    selectedStudent.value = null;
    selectedType.value = null;
    selectedDate.value = DateTime.now();
    isGeneralOccurrence.value = false;
  }

  void prepareEditOccurrence(Occurrence occurrence) {
    descriptionEC.text = occurrence.description;
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
