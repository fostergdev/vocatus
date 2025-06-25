// app/repositories/reports/reports_repository.dart
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/repositories/reports/i_reports_repository.dart';

class ReportsRepository implements IReportsRepository {
  final DatabaseHelper _dbHelper;

  ReportsRepository(this._dbHelper);

  @override
  Future<List<Map<String, dynamic>>> getClassesRawReport(int year) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT
        c.id AS classe_id,
        c.name AS classe_name,
        c.description, -- Adicionado: descrição da classe
        c.school_year, -- Adicionado: ano da classe
        c.created_at,  -- Adicionado: data de criação da classe
        d.id AS discipline_id, -- <--- ADICIONADO: ID da disciplina
        d.name AS discipline_name,
        g.day_of_week,
        g.start_time,
        g.end_time,
        c.active AS classe_active
      FROM classe c
      LEFT JOIN grade g ON c.id = g.classe_id
      LEFT JOIN discipline d ON g.discipline_id = d.id
      WHERE c.school_year = ?
      ORDER BY c.name, g.day_of_week, g.start_time;
    ''',
      [year],
    );
    return result;
  }

  @override
  Future<Map<String, List<int>>> getMinMaxYearsByTable() async {
    final db = await _dbHelper.database;

    final classesYears = await db.rawQuery(
      'SELECT MIN(school_year) as min, MAX(school_year) as max FROM classe',
    );
    final minClasse = classesYears.first['min'] as int?;
    final maxClasse = classesYears.first['max'] as int?;
    final classesList = (minClasse != null && maxClasse != null)
        ? List.generate(maxClasse - minClasse + 1, (i) => minClasse + i)
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
      'students': studentsList,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getArchivedStudentsByYear(int year) async {
    final db = await _dbHelper.database;
    return await db.rawQuery(
      '''
      SELECT DISTINCT s.*,
             GROUP_CONCAT(cl.name) AS class_names
      FROM classe_student cs
      INNER JOIN classe c ON cs.classe_id = c.id
      INNER JOIN student s ON cs.student_id = s.id
      LEFT JOIN classe cl ON cs.classe_id = cl.id
      WHERE c.school_year = ? AND cs.active = 0 AND c.active = 0
      GROUP BY s.id
      ORDER BY s.name COLLATE NOCASE
    ''',
      [year],
    );
  }
}