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
      WHERE cs.active = 1
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
        COALESCE(s.name, 'Nome não informado') AS student_name,
        COALESCE(a.date, '') AS date,
        COALESCE(a.content, '') AS content,
        CASE
          WHEN sa.presence = 1 THEN 'P'
          WHEN sa.presence = 0 THEN 'A'
          ELSE 'N'
        END AS status
      FROM student s
      LEFT JOIN student_attendance sa ON s.id = sa.student_id
      LEFT JOIN attendance a ON sa.attendance_id = a.id
      INNER JOIN classe_student cs ON s.id = cs.student_id
      WHERE cs.classe_id = ? AND cs.active = 1 AND s.active = 1
        AND a.date IS NOT NULL
      ORDER BY s.name, a.date;
    ''',
      [classId],
    );
    return result;
  }

  // New methods for student reports
  @override
  Future<List<Map<String, dynamic>>> getStudentsWithReportsData(int year) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
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
    ''',
      [year],
    );
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentAttendanceReport(int studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT
        a.id AS attendance_id,
        a.date,
        a.content,
        c.name AS class_name,
        d.name AS discipline_name,
        sa.presence,
        CASE
          WHEN sa.presence = 1 THEN 'Presente'
          ELSE 'Ausente'
        END AS attendance_status
      FROM attendance a
      INNER JOIN student_attendance sa ON a.id = sa.attendance_id
      INNER JOIN classe c ON a.classe_id = c.id
      LEFT JOIN grade g ON a.grade_id = g.id
      LEFT JOIN discipline d ON g.discipline_id = d.id
      WHERE sa.student_id = ? AND a.active = 1
      ORDER BY a.date DESC;
    ''',
      [studentId],
    );
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentOccurrencesReport(int studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT
        o.id,
        o.occurrence_type,
        o.description,
        o.occurrence_date,
        a.date AS attendance_date,
        c.name AS class_name,
        d.name AS discipline_name
      FROM occurrence o
      INNER JOIN attendance a ON o.attendance_id = a.id
      INNER JOIN classe c ON a.classe_id = c.id
      LEFT JOIN grade g ON a.grade_id = g.id
      LEFT JOIN discipline d ON g.discipline_id = d.id
      WHERE o.student_id = ? AND o.active = 1
      ORDER BY o.occurrence_date DESC;
    ''',
      [studentId],
    );
    return result;
  }

  @override
  Future<Map<String, dynamic>?> getStudentDetails(int studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'student',
      where: 'id = ?',
      whereArgs: [studentId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentsByClassId(int classId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT s.*, cs.active as link_active
      FROM student s
      INNER JOIN classe_student cs ON cs.student_id = s.id
      WHERE cs.classe_id = ? AND cs.active = 1
      ORDER BY s.name COLLATE NOCASE
      ''',
      [classId],
    );
    return result;
  }
}