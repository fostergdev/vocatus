import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';
import 'dart:developer';

class OccurrenceSelectController extends GetxController {
  final isLoading = false.obs;
  final availableClasses = <Classe>[].obs;
  final availableAttendances = <Attendance>[].obs;
  final selectedClasse = Rx<Classe?>(null);

  @override
  void onInit() {
    log('OccurrenceSelectController.onInit - Inicializando controller', name: 'OccurrenceSelectController');
    loadAvailableClasses();
    
    // Listener para mudança de turma selecionada
    selectedClasse.listen((classe) {
      if (classe != null) {
        loadAttendancesForClasse(classe.id!);
      } else {
        availableAttendances.clear();
      }
    });
    
    super.onInit();
  }

  Future<void> loadAvailableClasses() async {
    try {
      isLoading.value = true;
      log('OccurrenceSelectController.loadAvailableClasses - Carregando turmas que possuem ocorrências', name: 'OccurrenceSelectController');
      
      final db = await DatabaseHelper.instance.database;
      
      // Primeiro, vamos verificar todas as turmas ativas (para debug)
      final allClassesQuery = '''
        SELECT c.* 
        FROM classe c
        WHERE c.active = 1
        ORDER BY c.school_year DESC, c.name COLLATE NOCASE
      ''';
      
      final allClassesResult = await db.rawQuery(allClassesQuery);
      log('OccurrenceSelectController.loadAvailableClasses - DEBUG: Total de turmas ativas: ${allClassesResult.length}', name: 'OccurrenceSelectController');
      
      // Verificar para cada turma quantas ocorrências ela tem
      for (final classeMap in allClassesResult) {
        final classeId = classeMap['id'];
        final classeName = classeMap['name'];
        
        final occurrencesCountQuery = '''
          SELECT COUNT(*) as count
          FROM classe c
          INNER JOIN attendance a ON c.id = a.classe_id
          INNER JOIN occurrence o ON a.id = o.attendance_id
          WHERE c.id = ?
        ''';
        
        final occurrencesCountResult = await db.rawQuery(occurrencesCountQuery, [classeId]);
        final occurrencesCount = occurrencesCountResult.first['count'] as int;
        
        log('OccurrenceSelectController.loadAvailableClasses - DEBUG: Turma "$classeName" (ID: $classeId) tem $occurrencesCount ocorrências', name: 'OccurrenceSelectController');
      }
      
      // Buscar turmas que têm ocorrências (via attendance que tem occurrences)
      final classesWithOccurrencesQuery = '''
        SELECT DISTINCT c.* 
        FROM classe c
        INNER JOIN attendance a ON c.id = a.classe_id
        INNER JOIN occurrence o ON a.id = o.attendance_id
        WHERE c.active = 1
        ORDER BY c.school_year DESC, c.name COLLATE NOCASE
      ''';
      
      final result = await db.rawQuery(classesWithOccurrencesQuery);
      final classes = result.map((map) => Classe.fromMap(map)).toList();
      
      availableClasses.value = classes;
      
      log('OccurrenceSelectController.loadAvailableClasses - ${classes.length} turmas com ocorrências carregadas', name: 'OccurrenceSelectController');
      
      // Log de debug para verificar as turmas carregadas
      for (final classe in classes) {
        log('OccurrenceSelectController.loadAvailableClasses - Turma: ${classe.name} (${classe.schoolYear})', name: 'OccurrenceSelectController');
      }
    } catch (e) {
      log('OccurrenceSelectController.loadAvailableClasses - Erro: $e', name: 'OccurrenceSelectController');
      Get.dialog(
        CustomErrorDialog(
          title: 'Erro',
          message: 'Erro ao carregar turmas: $e',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAttendancesForClasse(int classeId) async {
    try {
      isLoading.value = true;
      log('OccurrenceSelectController.loadAttendancesForClasse - Carregando chamadas com ocorrências para turma: $classeId', name: 'OccurrenceSelectController');
      
      final db = await DatabaseHelper.instance.database;
      
      // Primeiro, vamos verificar todas as chamadas da turma (para debug)
      final allAttendancesQuery = '''
        SELECT a.* 
        FROM attendance a
        WHERE a.classe_id = ? AND a.active = 1
        ORDER BY a.date DESC
      ''';
      
      final allAttendancesResult = await db.rawQuery(allAttendancesQuery, [classeId]);
      log('OccurrenceSelectController.loadAttendancesForClasse - DEBUG: Total de chamadas ativas para turma: ${allAttendancesResult.length}', name: 'OccurrenceSelectController');
      
      // Agora vamos verificar quais dessas chamadas têm ocorrências
      for (final attendanceMap in allAttendancesResult) {
        final attendanceId = attendanceMap['id'];
        final attendanceDate = attendanceMap['date'];
        
        final occurrencesCountQuery = '''
          SELECT COUNT(*) as count
          FROM occurrence o
          WHERE o.attendance_id = ?
        ''';
        
        final occurrencesCountResult = await db.rawQuery(occurrencesCountQuery, [attendanceId]);
        final occurrencesCount = occurrencesCountResult.first['count'] as int;
        
        log('OccurrenceSelectController.loadAttendancesForClasse - DEBUG: Chamada $attendanceId (data: $attendanceDate) tem $occurrencesCount ocorrências', name: 'OccurrenceSelectController');
      }
      
      // Buscar apenas chamadas que têm ocorrências registradas
      final attendancesWithOccurrencesQuery = '''
        SELECT DISTINCT a.* 
        FROM attendance a
        INNER JOIN occurrence o ON a.id = o.attendance_id
        WHERE a.classe_id = ? AND a.active = 1
        ORDER BY a.date DESC
      ''';
      
      final result = await db.rawQuery(attendancesWithOccurrencesQuery, [classeId]);
      final attendances = result.map((map) => Attendance.fromMap(map)).toList();
      availableAttendances.value = attendances;
      
      log('OccurrenceSelectController.loadAttendancesForClasse - ${attendances.length} chamadas com ocorrências carregadas', name: 'OccurrenceSelectController');
      
      // Log detalhado das chamadas retornadas
      for (final attendance in attendances) {
        log('OccurrenceSelectController.loadAttendancesForClasse - Chamada retornada: ID=${attendance.id}, Data=${formatDate(attendance.date)}', name: 'OccurrenceSelectController');
      }
    } catch (e) {
      log('OccurrenceSelectController.loadAttendancesForClasse - Erro: $e', name: 'OccurrenceSelectController');
      Get.snackbar(
        'Erro',
        'Erro ao carregar chamadas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  void navigateToOccurrences(Attendance attendance) {
    log('OccurrenceSelectController.navigateToOccurrences - Navegando para ocorrências da chamada: ${attendance.id}', name: 'OccurrenceSelectController');
    Get.toNamed('/occurrence', arguments: attendance);
  }
}
