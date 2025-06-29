import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Initialize FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final databasePath = Directory.current.path + '/vocatus_app.db';
  print('🔍 Verificando banco de dados em: $databasePath');
  
  if (!File(databasePath).existsSync()) {
    print('❌ Banco de dados não encontrado!');
    return;
  }

  final db = await openDatabase(databasePath);
  
  print('\n📊 Verificando dados de estudantes...');
  
  // Check students table
  final students = await db.query('student');
  print('👥 Total de estudantes: ${students.length}');
  
  if (students.isNotEmpty) {
    print('\n📋 Primeiros 5 estudantes:');
    for (int i = 0; i < students.length && i < 5; i++) {
      final student = students[i];
      print('  - ID: ${student['id']}, Nome: ${student['name']}, Ativo: ${student['active']}');
    }
  }
  
  // Check classe_student enrollment
  final enrollments = await db.query('classe_student');
  print('\n🏫 Total de matrículas (classe_student): ${enrollments.length}');
  
  if (enrollments.isNotEmpty) {
    print('\n📋 Primeiras 5 matrículas:');
    for (int i = 0; i < enrollments.length && i < 5; i++) {
      final enrollment = enrollments[i];
      print('  - Aluno ID: ${enrollment['student_id']}, Classe ID: ${enrollment['classe_id']}, Ativo: ${enrollment['active']}');
    }
  }
  
  // Check classes
  final classes = await db.query('classe');
  print('\n🏫 Total de turmas: ${classes.length}');
  
  if (classes.isNotEmpty) {
    print('\n📋 Primeiras 5 turmas:');
    for (int i = 0; i < classes.length && i < 5; i++) {
      final classe = classes[i];
      print('  - ID: ${classe['id']}, Nome: ${classe['name']}, Ano: ${classe['school_year']}, Ativo: ${classe['active']}');
    }
  }
  
  // Test the specific query used in reports
  print('\n🔍 Testando query específica do relatório...');
  final reportQuery = '''
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
  
  final currentYear = DateTime.now().year;
  final testYears = [currentYear, 2024, 2025];
  
  for (final year in testYears) {
    print('\n📅 Ano $year:');
    final result = await db.rawQuery(reportQuery, [year]);
    print('   Resultado: ${result.length} estudantes encontrados');
    
    if (result.isNotEmpty) {
      print('   Primeiros resultados:');
      for (int i = 0; i < result.length && i < 3; i++) {
        final student = result[i];
        print('     - ${student['name']} (${student['class_name']})');
      }
    }
  }
  
  await db.close();
  print('\n✅ Verificação concluída!');
}
