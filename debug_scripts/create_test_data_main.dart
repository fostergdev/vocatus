import 'package:flutter/material.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Inicializando dados de teste...');
  
  final dbHelper = DatabaseHelper.instance;
  final db = await dbHelper.database;
  
  print('📋 Verificando dados existentes...');
  
  // Check existing data
  final existingStudents = await db.query('student');
  final existingClasses = await db.query('classe');
  final existingEnrollments = await db.query('classe_student');
  
  print('👥 Estudantes existentes: ${existingStudents.length}');
  print('🏫 Turmas existentes: ${existingClasses.length}');
  print('📝 Matrículas existentes: ${existingEnrollments.length}');
  
  // If no data exists, create test data
  if (existingStudents.isEmpty || existingClasses.isEmpty) {
    print('\n📝 Criando dados de teste...');
    
    // Create discipline if not exists
    final disciplines = await db.query('discipline');
    int disciplineId = 1;
    if (disciplines.isEmpty) {
      disciplineId = await db.insert('discipline', {
        'name': 'Matemática',
        'active': 1,
      });
      print('✅ Disciplina criada: ID $disciplineId');
    }
    
    // Create class if not exists
    int classId = 1;
    if (existingClasses.isEmpty) {
      classId = await db.insert('classe', {
        'name': '1º Ano A',
        'description': 'Primeira turma do primeiro ano',
        'school_year': 2024,
        'discipline_id': disciplineId,
        'active': 1,
      });
      print('✅ Turma criada: ID $classId');
    } else {
      classId = existingClasses.first['id'] as int;
    }
    
    // Create students if not exists
    if (existingStudents.isEmpty) {
      final studentNames = [
        'João Silva',
        'Maria Santos', 
        'Pedro Oliveira',
        'Ana Costa',
        'Lucas Pereira',
        'Julia Fernandes',
        'Carlos Rodrigues',
        'Beatriz Lima',
        'Gabriel Alves',
        'Isabella Martins'
      ];
      
      final studentIds = <int>[];
      
      for (final name in studentNames) {
        final studentId = await db.insert('student', {
          'name': name,
          'active': 1,
        });
        studentIds.add(studentId);
        print('✅ Estudante criado: $name (ID $studentId)');
      }
      
      // Create enrollments
      for (final studentId in studentIds) {
        await db.insert('classe_student', {
          'student_id': studentId,
          'classe_id': classId,
          'active': 1,
        });
      }
      print('✅ Matrículas criadas para ${studentIds.length} estudantes');
      
      // Create some attendance records for testing
      final attendanceId = await db.insert('attendance', {
        'date': '2024-12-01',
        'content': 'Aula de matemática - operações básicas',
        'classe_id': classId,
        'active': 1,
      });
      
      // Create attendance records for students
      for (int i = 0; i < studentIds.length; i++) {
        final studentId = studentIds[i];
        // Mix of present/absent for testing
        final presence = i % 3 == 0 ? 0 : 1; // Some absent, most present
        
        await db.insert('student_attendance', {
          'student_id': studentId,
          'attendance_id': attendanceId,
          'presence': presence,
        });
      }
      print('✅ Registros de frequência criados');
      
      // Create some occurrences for testing
      for (int i = 0; i < 3; i++) {
        final studentId = studentIds[i];
        await db.insert('occurrence', {
          'student_id': studentId,
          'attendance_id': attendanceId,
          'status': 'late',
          'observations': 'Chegou atrasado à aula',
          'active': 1,
        });
      }
      print('✅ Ocorrências de teste criadas');
    }
  }
  
  // Final verification
  print('\n🔍 Verificação final...');
  final finalStudents = await db.query('student');
  final finalClasses = await db.query('classe');
  final finalEnrollments = await db.query('classe_student');
  final attendance = await db.query('attendance');
  final studentAttendance = await db.query('student_attendance');
  final occurrences = await db.query('occurrence');
  
  print('👥 Total de estudantes: ${finalStudents.length}');
  print('🏫 Total de turmas: ${finalClasses.length}');
  print('📝 Total de matrículas: ${finalEnrollments.length}');
  print('📅 Total de aulas: ${attendance.length}');
  print('✅ Presenças registradas: ${studentAttendance.length}');
  print('⚠️ Ocorrências: ${occurrences.length}');
  
  print('\n🎉 Dados de teste configurados com sucesso!');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocatus - Dados de Teste',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dados de Teste Criados'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
              SizedBox(height: 20),
              Text(
                'Dados de teste criados com sucesso!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Agora você pode executar o app principal.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
