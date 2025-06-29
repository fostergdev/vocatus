// Debug script to test student reports query
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 Testando consulta de relatórios de estudantes...');
  
  final dbHelper = DatabaseHelper.instance;
  final db = await dbHelper.database;
  
  // Test the years query first
  print('\n📅 Testando consulta de anos...');
  final yearsQuery = '''
    SELECT MIN(c.school_year) as min, MAX(c.school_year) as max
    FROM classe_student cs
    INNER JOIN classe c ON cs.classe_id = c.id
    WHERE cs.active = 1
  ''';
  
  final yearsResult = await db.rawQuery(yearsQuery);
  print('Resultado anos: $yearsResult');
  
  if (yearsResult.isNotEmpty) {
    final minYear = yearsResult.first['min'] as int?;
    final maxYear = yearsResult.first['max'] as int?;
    print('Min Year: $minYear, Max Year: $maxYear');
    
    if (minYear != null && maxYear != null) {
      final years = List.generate(maxYear - minYear + 1, (i) => minYear + i);
      print('Anos disponíveis: $years');
      
      // Test the main students query for each year
      for (final year in years) {
        print('\n📋 Testando ano $year...');
        
        final studentsQuery = '''
          SELECT DISTINCT
            s.id,
            s.name,
            s.active,
            c.name AS class_name,
            c.school_year,
            -- Attendance statistics
            (
              SELECT COUNT(DISTINCT a.id)
              FROM attendance a
              INNER JOIN student_attendance sa ON a.id = sa.attendance_id
              WHERE sa.student_id = s.id AND a.active = 1
            ) AS total_classes,
            (
              SELECT COUNT(*)
              FROM attendance a
              INNER JOIN student_attendance sa ON a.id = sa.attendance_id
              WHERE sa.student_id = s.id AND sa.presence = 1 AND a.active = 1
            ) AS total_presences,
            (
              SELECT COUNT(*)
              FROM attendance a
              INNER JOIN student_attendance sa ON a.id = sa.attendance_id
              WHERE sa.student_id = s.id AND sa.presence = 0 AND a.active = 1
            ) AS total_absences,
            -- Occurrence statistics
            (
              SELECT COUNT(*)
              FROM occurrence o
              INNER JOIN attendance a ON o.attendance_id = a.id
              WHERE o.student_id = s.id AND o.active = 1
            ) AS total_occurrences
          FROM student s
          INNER JOIN classe_student cs ON s.id = cs.student_id
          INNER JOIN classe c ON cs.classe_id = c.id
          WHERE c.school_year = ? AND cs.active = 1
          ORDER BY s.name COLLATE NOCASE;
        ''';
        
        final studentsResult = await db.rawQuery(studentsQuery, [year]);
        print('Estudantes encontrados para $year: ${studentsResult.length}');
        
        if (studentsResult.isNotEmpty) {
          print('Primeiros 3 estudantes:');
          for (int i = 0; i < studentsResult.length && i < 3; i++) {
            final student = studentsResult[i];
            print('  - ${student['name']} (Turma: ${student['class_name']})');
            print('    Total aulas: ${student['total_classes']}, Presenças: ${student['total_presences']}');
          }
        } else {
          print('  ❌ Nenhum estudante encontrado para o ano $year');
        }
      }
    }
  }
  
  // Also check basic tables
  print('\n📊 Verificação das tabelas básicas:');
  final students = await db.query('student', where: 'active = 1');
  final classes = await db.query('classe', where: 'active = 1');
  final enrollments = await db.query('classe_student', where: 'active = 1');
  
  print('Estudantes ativos: ${students.length}');
  print('Turmas ativas: ${classes.length}');
  print('Matrículas ativas: ${enrollments.length}');
  
  if (classes.isNotEmpty) {
    print('\nTurmas encontradas:');
    for (final classe in classes) {
      print('  - ID: ${classe['id']}, Nome: ${classe['name']}, Ano: ${classe['school_year']}');
    }
  }
  
  if (enrollments.isNotEmpty) {
    print('\nPrimeiras 5 matrículas:');
    for (int i = 0; i < enrollments.length && i < 5; i++) {
      final enrollment = enrollments[i];
      print('  - Estudante ${enrollment['student_id']} → Turma ${enrollment['classe_id']}');
    }
  }
  
  print('\n✅ Debug concluído!');
  exit(0);
}
