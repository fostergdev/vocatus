import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/core/widgets/custom_error_dialog.dart';

class OccurrenceSelectController extends GetxController {
  final isLoading = false.obs;
  final availableClasses = <Classe>[].obs;
  final availableAttendances = <Attendance>[].obs;
  final selectedClasse = Rx<Classe?>(null);

  @override
  void onInit() {
    loadAvailableClasses();
    
    
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
      
      final db = await DatabaseHelper.instance.database;
      
      
      final allClassesQuery = '''
        SELECT c.* 
        FROM classe c
        WHERE c.active = 1
        ORDER BY c.school_year DESC, c.name COLLATE NOCASE
      ''';
      
      final allClassesResult = await db.rawQuery(allClassesQuery);
      
      
      for (final classeMap in allClassesResult) {
        final classeId = classeMap['id'];
        final occurrencesCountQuery = '''
          SELECT COUNT(*) as count
          FROM classe c
          INNER JOIN attendance a ON c.id = a.classe_id
          INNER JOIN occurrence o ON a.id = o.attendance_id
          WHERE c.id = ?
        ''';
        
        await db.rawQuery(occurrencesCountQuery, [classeId]);
      }
      
      
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
    } catch (e) {
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
      
      final db = await DatabaseHelper.instance.database;
      
      
      final allAttendancesQuery = '''
        SELECT a.* 
        FROM attendance a
        WHERE a.classe_id = ? AND a.active = 1
        ORDER BY a.date DESC
      ''';
      
      final allAttendancesResult = await db.rawQuery(allAttendancesQuery, [classeId]);
      
      
      for (final attendanceMap in allAttendancesResult) {
        final attendanceId = attendanceMap['id'];
        final occurrencesCountQuery = '''
          SELECT COUNT(*) as count
          FROM occurrence o
          WHERE o.attendance_id = ?
        ''';
        
        await db.rawQuery(occurrencesCountQuery, [attendanceId]);
      }
      
      
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
    } catch (e) {
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
    Get.toNamed('/occurrence', arguments: attendance);
  }
}
