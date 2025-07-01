import 'package:flutter/material.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 Debug dos dados de relatórios...');
  
  final dbHelper = DatabaseHelper.instance;
  final db = await dbHelper.database;
  
  print('\n📊 Verificando anos disponíveis...');
  
  // Verificar anos das turmas
  final classesYears = await db.rawQuery('''
    SELECT MIN(school_year) as min, MAX(school_year) as max
    FROM classe
    WHERE active = 1
  ''');
  print('Anos das turmas: ${classesYears.first}');
  
  // Verificar anos dos estudantes
  final studentYears = await db.rawQuery('''
    SELECT MIN(c.school_year) as min, MAX(c.school_year) as max
    FROM classe_student cs
    INNER JOIN classe c ON cs.classe_id = c.id
    WHERE cs.active = 1
  ''');
  print('Anos dos estudantes: ${studentYears.first}');
  
  // Verificar dados para o ano atual
  final currentYear = DateTime.now().year;
  print('\n📅 Verificando dados para o ano atual ($currentYear)...');
  
  final studentsCurrentYear = await db.rawQuery('''
    SELECT DISTINCT
      s.id,
      s.name,
      s.active,
      c.name AS class_name,
      c.school_year
    FROM student s
    INNER JOIN classe_student cs ON s.id = cs.student_id
    INNER JOIN classe c ON cs.classe_id = c.id
    WHERE c.school_year = ? AND cs.active = 1
    ORDER BY s.name COLLATE NOCASE
    LIMIT 5;
  ''', [currentYear]);
  
  print('Estudantes encontrados para $currentYear: ${studentsCurrentYear.length}');
  for (var student in studentsCurrentYear) {
    print('  - ${student['name']} (Turma: ${student['class_name']})');
  }
  
  // Verificar anos disponíveis na tabela classe
  print('\n📚 Todas as turmas por ano:');
  final allClasses = await db.rawQuery('''
    SELECT school_year, COUNT(*) as count, active
    FROM classe
    GROUP BY school_year, active
    ORDER BY school_year DESC
  ''');
  
  for (var row in allClasses) {
    print('  Ano ${row['school_year']}: ${row['count']} turmas (ativo: ${row['active']})');
  }
  
  // Verificar dados para anos próximos
  final testYears = [currentYear, currentYear + 1, currentYear - 1, 2024, 2025];
  
  for (final year in testYears) {
    final students = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM student s
      INNER JOIN classe_student cs ON s.id = cs.student_id
      INNER JOIN classe c ON cs.classe_id = c.id
      WHERE c.school_year = ? AND cs.active = 1
    ''', [year]);
    
    final count = students.first['count'] as int;
    if (count > 0) {
      print('📈 Ano $year: $count estudantes matriculados');
    }
  }
  
  print('\n✅ Debug concluído!');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Relatórios',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Debug Relatórios'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bug_report,
                color: Colors.blue,
                size: 80,
              ),
              SizedBox(height: 20),
              Text(
                'Verifique o console para os resultados do debug',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
