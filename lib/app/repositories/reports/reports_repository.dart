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
        c.description,
        c.school_year,
        c.created_at,
        d.id AS discipline_id,
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

  @override
  Future<List<Map<String, dynamic>>> getAttendanceReportByClassId(
    int classId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT
        s.name AS student_name,
        a.date,
        a.content,
        CASE
          WHEN sa.presence = 0 THEN 'P'
          WHEN sa.presence = 1 THEN 'F'
          ELSE 'Desconhecido'
        END AS status
      FROM attendance a
      JOIN student_attendance sa ON a.id = sa.attendance_id
      JOIN student s ON sa.student_id = s.id
      WHERE a.classe_id = ?
      ORDER BY s.name, a.date;
      ''',
      [classId],
    );
    return result;
  }


  @override
  Future<List<Map<String, dynamic>>> getStudentsByClassId(int classId) async {
    final db = await _dbHelper.database;
    return await db.rawQuery(
      '''
      SELECT s.id, s.name, s.active, s.created_at,
             cs.start_date, cs.end_date, cs.active AS classe_student_active
      FROM student s
      INNER JOIN classe_student cs ON s.id = cs.student_id
      WHERE cs.classe_id = ?
      ORDER BY s.name COLLATE NOCASE;
      ''',
      [classId],
    );
  }

  @override
  Future<Map<String, dynamic>?> getStudentDetails(int studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT s.id, s.name, s.active, s.created_at
      FROM student s
      WHERE s.id = ?;
      ''',
      [studentId],
    );
    return result.isNotEmpty ? result.first : null;
  }
}