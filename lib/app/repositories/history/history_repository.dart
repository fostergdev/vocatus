import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/repositories/history/i_history_repository.dart';

class HistoryRepository implements IHistoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<Map<String, List<int>>> getMinMaxYearsByTable() async {
    final db = await _dbHelper.database;

    final classesYears = await db.rawQuery(
      'SELECT MIN(school_year) as min, MAX(school_year) as max FROM classe WHERE active = 0',
    );
    final minClasse = classesYears.first['min'] as int?;
    final maxClasse = classesYears.first['max'] as int?;
    final classesList = (minClasse != null && maxClasse != null)
        ? List.generate(maxClasse - minClasse + 1, (i) => minClasse + i)
        : <int>[];

    final gradeYears = await db.rawQuery(
      'SELECT MIN(grade_year) as min, MAX(grade_year) as max FROM grade WHERE active = 0',
    );
    final minGrade = gradeYears.first['min'] as int?;
    final maxGrade = gradeYears.first['max'] as int?;
    final gradesList = (minGrade != null && maxGrade != null)
        ? List.generate(maxGrade - minGrade + 1, (i) => minGrade + i)
        : <int>[];

    final studentYears = await db.rawQuery('''
      SELECT MIN(c.school_year) as min, MAX(c.school_year) as max
      FROM classe_student cs
      INNER JOIN classe c ON cs.classe_id = c.id
      WHERE cs.active = 0
    ''');
    final minStudent = studentYears.first['min'] as int?;
    final maxStudent = studentYears.first['max'] as int?;
    final studentsList = (minStudent != null && maxStudent != null)
        ? List.generate(maxStudent - minStudent + 1, (i) => minStudent + i)
        : <int>[];

    return {
      'classes': classesList,
      'grades': gradesList,
      'students': studentsList,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getArchivedClassesByYear(int year) async {
    final db = await _dbHelper.database;
    return await db.query(
      'classe',
      where: 'school_year = ? AND active = 0',
      whereArgs: [year],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getArchivedStudentsByYear(int year) async {
    final db = await _dbHelper.database;
    return await db.rawQuery(
      '''
      SELECT DISTINCT s.* -- <--- ADICIONE O DISTINCT AQUI
      FROM classe_student cs
      INNER JOIN classe c ON cs.classe_id = c.id
      INNER JOIN student s ON cs.student_id = s.id
      WHERE c.school_year = ? AND cs.active = 0
      ORDER BY s.name COLLATE NOCASE -- Opcional: ordenar por nome
    ''',
      [year],
    );
  }
}
