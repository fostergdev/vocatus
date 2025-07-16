import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
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
        s.day_of_week,
        s.start_time,
        s.end_time,
        c.active AS classe_active
      FROM classe c
      LEFT JOIN schedule s ON c.id = s.classe_id
      LEFT JOIN discipline d ON s.discipline_id = d.id
      WHERE c.school_year = ?
      ORDER BY c.name, s.day_of_week, s.start_time;
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
    ''');
    final minStudent = studentYears.first['min'] as int?;
    final maxStudent = studentYears.first['max'] as int?;
    final studentsList = (minStudent != null && maxStudent != null)
        ? List.generate(maxStudent - minStudent + 1, (i) => minStudent + i)
        : <int>[];

    return {'classes': classesList, 'students': studentsList};
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
      a.id AS attendance_id,
      a.date,
      a.content,
      c.name AS class_name,
      d.name AS discipline_name,
      sch.start_time,
      sch.end_time,
      sa.presence,
      s.id AS student_id,
      s.name AS student_name,
      CASE
        WHEN sa.presence = 1 THEN 'P' -- Presente
        WHEN sa.presence = 0 THEN 'F' -- Ausente
        WHEN sa.presence = 2 THEN 'J' -- Justificado
        ELSE 'N/A'
      END AS status
    FROM attendance a
    INNER JOIN student_attendance sa ON a.id = sa.attendance_id
    INNER JOIN student s ON sa.student_id = s.id
    INNER JOIN classe c ON a.classe_id = c.id
    LEFT JOIN schedule sch ON a.schedule_id = sch.id
    LEFT JOIN discipline d ON sch.discipline_id = d.id
    WHERE a.classe_id = ? AND a.active = 1
    ORDER BY a.date DESC, sch.start_time, s.name COLLATE NOCASE;
    ''',
      [classId],
    );
    return result;
  }

  @override // Se IReportsRepository tiver essa assinatura, senão remova.
  Future<int> getTotalAttendancesCountByClassId(int classId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT id) AS total_attendances
      FROM attendance
      WHERE classe_id = ? AND active = 1;
      ''',
      [classId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentsWithReportsData(
    int year,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT
        s.id,
        s.name,
        s.active,
        GROUP_CONCAT(DISTINCT c.name) AS class_name,
        c.school_year,
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
      GROUP BY s.id
      ORDER BY s.name COLLATE NOCASE;
    ''',
      [year],
    );
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentAttendanceReport(
    int studentId,
  ) async {
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
        WHEN sa.presence = 0 THEN 'Ausente'
        WHEN sa.presence = 2 THEN 'Justificado'
        ELSE 'N/A'
      END AS attendance_status
      FROM attendance a
      INNER JOIN student_attendance sa ON a.id = sa.attendance_id
      INNER JOIN classe c ON a.classe_id = c.id
      LEFT JOIN schedule s ON a.schedule_id = s.id
      LEFT JOIN discipline d ON s.discipline_id = d.id
      WHERE sa.student_id = ? AND a.active = 1
      ORDER BY a.date DESC;
    ''',
      [studentId],
    );
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentOccurrencesReport(
    int studentId,
  ) async {
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
      LEFT JOIN schedule s ON a.schedule_id = s.id
      LEFT JOIN discipline d ON s.discipline_id = d.id
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
      columns: ['id', 'name', 'created_at', 'active'],
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

  @override
  Future<List<Map<String, dynamic>>> getOccurrencesReportByClassId(
    int classId,
  ) async {
    final db = await _dbHelper.database;

    try {
      final attendances = await db.query(
        'attendance',
        columns: ['id'],
        where: 'classe_id = ? AND active = 1',
        whereArgs: [classId],
      );

      if (attendances.isEmpty) {
        return [];
      }

      final attendanceIds = attendances.map((a) => a['id'] as int).toList();
      final placeholders = List.filled(attendanceIds.length, '?').join(',');

      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT
          o.id,
          COALESCE(strftime('%Y-%m-%d', o.occurrence_date), strftime('%Y-%m-%d', 'now')) as occurrence_date,
          o.description,
          COALESCE(o.occurrence_type, 'N/A') as type,
          CASE WHEN o.student_id IS NULL THEN 1 ELSE 0 END as is_general,
          s.name AS student_name,
          a.date AS attendance_date,
          c.name AS class_name
        FROM occurrence o
        LEFT JOIN student s ON o.student_id = s.id
        INNER JOIN attendance a ON o.attendance_id = a.id
        INNER JOIN classe c ON a.classe_id = c.id
        WHERE o.attendance_id IN ($placeholders) AND o.active = 1
        ORDER BY o.occurrence_date DESC
        ''',
        [...attendanceIds],
      );

      return result.map((record) {
        return {
          'id': record['id'],
          'date': record['occurrence_date'],
          'description': record['description'] ?? 'Sem descrição',
          'type': record['type'] ?? 'GERAL',
          'is_general': record['is_general'] ?? 0,
          'student_name': record['student_name'] ?? 'Turma Toda',
          'attendance_date': record['attendance_date'],
          'class_name': record['class_name'] ?? 'N/A',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // --- NOVO MÉTODO PARA TAREFAS DE CASA ---
  @override
  Future<List<Map<String, dynamic>>> getHomeworkByClassId(int classId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT
        h.id,
        h.title,
        h.description,
        h.due_date,
        h.assigned_date,
        h.status,
        d.name AS discipline_name,
        c.name AS class_name
      FROM homework h
      INNER JOIN classe c ON h.classe_id = c.id
      LEFT JOIN discipline d ON h.discipline_id = d.id
      WHERE h.classe_id = ? AND h.active = 1
      ORDER BY h.due_date ASC, h.assigned_date DESC;
      ''',
      [classId],
    );
    return result;
  }

  @override
  Future<double> getAttendancePercentageByClassId(int classId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
    SELECT
      CASE
        WHEN COUNT(*) = 0 THEN 0.0
        ELSE CAST(SUM(CASE WHEN sa.presence = 1 THEN 1 ELSE 0 END) AS REAL) * 100 / COUNT(*)
      END as percentage
    FROM student_attendance sa
    INNER JOIN attendance a ON sa.attendance_id = a.id
    WHERE a.classe_id = ? AND a.active = 1
  ''',
      [classId],
    );

    if (result.isNotEmpty && result.first['percentage'] != null) {
      return result.first['percentage'] as double;
    }
    return 0.0;
  }

  @override
  Future<double> getAverageOccurrencesPerClass(int classId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
    SELECT
      CASE
        WHEN COUNT(DISTINCT a.id) = 0 THEN 0.0
        ELSE CAST(COUNT(o.id) AS REAL) / COUNT(DISTINCT a.id)
      END as average
    FROM occurrence o
    INNER JOIN attendance a ON o.attendance_id = a.id
    WHERE a.classe_id = ? AND a.active = 1
  ''',
      [classId],
    );

    if (result.isNotEmpty && result.first['average'] != null) {
      return result.first['average'] as double;
    }
    return 0.0;
  }

  @override
  Future<Map<String, int>> getOccurrenceCountByType(int classId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT
        occurrence_type, 
        COUNT(*) as count
      FROM occurrence o
      INNER JOIN attendance a ON o.attendance_id = a.id
      WHERE a.classe_id = ? AND a.active = 1
      GROUP BY occurrence_type
    ''',
      [classId],
    );

    final Map<String, int> counts = {};
    for (final row in result) {
      counts[row['occurrence_type'] as String] = row['count'] as int;
    }
    return counts;
  }

  @override
  Future<Map<String, dynamic>> getAttendanceGridDataByClassId(
    int classId,
  ) async {
    final db = await _dbHelper.database;

    // Get all unique attendance sessions for the class
    final List<Map<String, dynamic>> attendanceSessionsRaw = await db.rawQuery(
      '''
      SELECT
        a.id AS attendance_id,
        a.date,
        a.content,
        sch.start_time,
        d.name AS discipline_name
      FROM attendance a
      LEFT JOIN schedule sch ON a.schedule_id = sch.id
      LEFT JOIN discipline d ON sch.discipline_id = d.id
      WHERE a.classe_id = ? AND a.active = 1
      ORDER BY a.date ASC, sch.start_time ASC;
      ''',
      [classId],
    );

    // Create a list of session identifiers for columns
    final List<Map<String, dynamic>> sessions = attendanceSessionsRaw.map((
      session,
    ) {
      return {
        'attendance_id': session['attendance_id'] as int,
        'date': session['date'] as String,
        'content': session['content'] as String?,
        'start_time': session['start_time'] as String?,
        'discipline_name': session['discipline_name'] as String?,
      };
    }).toList();

    // Get all students in the class
    final List<Map<String, dynamic>> studentsRaw = await db.rawQuery(
      '''
      SELECT s.id, s.name FROM student s INNER JOIN classe_student cs ON s.id = cs.student_id WHERE cs.classe_id = ? AND cs.active = 1 ORDER BY s.name COLLATE NOCASE;
      ''',
      [classId],
    );

    // Get all student attendance records for the class
    final List<Map<String, dynamic>> studentAttendanceRaw = await db.rawQuery(
      '''
      SELECT
        sa.student_id,
        a.id AS attendance_id,
        CASE
          WHEN sa.presence = 1 THEN 'P' -- Presente
          WHEN sa.presence = 0 THEN 'F' -- Ausente
          WHEN sa.presence = 2 THEN 'J' -- Justificado
          ELSE 'N/A'
        END AS status
      FROM student_attendance sa
      INNER JOIN attendance a ON sa.attendance_id = a.id
      WHERE a.classe_id = ? AND a.active = 1;
      ''',
      [classId],
    );

    // Map attendance records for easy lookup: studentId -> attendanceId -> status
    final Map<int, Map<int, String>> studentAttendanceMap = {};
    for (final record in studentAttendanceRaw) {
      final studentId = record['student_id'] as int;
      final attendanceId = record['attendance_id'] as int;
      final status = record['status'] as String;

      studentAttendanceMap.putIfAbsent(studentId, () => {});
      studentAttendanceMap[studentId]![attendanceId] = status;
    }

    // Build the final list of students with their attendance for each session
    final List<Map<String, dynamic>> studentsData = [];
    for (final student in studentsRaw) {
      final studentId = student['id'] as int;
      final studentName = student['name'] as String;
      final Map<String, dynamic> studentRow = {
        'id': studentId,
        'name': studentName,
      };

      for (final session in sessions) {
        final attendanceId = session['attendance_id'] as int;
        // Use attendance_id as the column key for the grid
        studentRow[attendanceId.toString()] =
            studentAttendanceMap[studentId]?[attendanceId] ??
            '-'; // '-' for no record
      }
      studentsData.add(studentRow);
    }

    return {
      'sessions':
          sessions, // List of maps with attendance_id, date, start_time, discipline_name
      'students':
          studentsData, // List of maps with student_id, name, and attendance_id_string -> status
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentClassesWithDetails(
    int studentId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT
        c.id AS class_id,
        c.name AS class_name,
        c.school_year,
        (
          SELECT COUNT(DISTINCT a.id)
          FROM attendance a
          INNER JOIN student_attendance sa ON a.id = sa.attendance_id
          WHERE sa.student_id = ? AND a.classe_id = c.id AND a.active = 1
        ) AS total_classes_in_class,
        (
          SELECT COUNT(*)
          FROM attendance a
          INNER JOIN student_attendance sa ON a.id = sa.attendance_id
          WHERE sa.student_id = ? AND sa.presence = 1 AND a.classe_id = c.id AND a.active = 1
        ) AS total_presences_in_class
      FROM classe_student cs
      INNER JOIN classe c ON cs.classe_id = c.id
      WHERE cs.student_id = ? AND cs.active = 1
      ORDER BY c.school_year DESC, c.name COLLATE NOCASE;
      ''',
      [studentId, studentId, studentId],
    );

    return result.map((row) {
      final totalClasses = row['total_classes_in_class'] as int? ?? 0;
      final totalPresences = row['total_presences_in_class'] as int? ?? 0;
      final attendancePercentage = totalClasses > 0
          ? (totalPresences / totalClasses * 100).toStringAsFixed(1)
          : '0.0';

      return {
        'class_id': row['class_id'],
        'class_name': row['class_name'],
        'school_year': row['school_year'],
        'total_classes_in_class': totalClasses,
        'total_presences_in_class': totalPresences,
        'attendance_percentage': attendancePercentage,
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentOccurrencesByClass(
    int studentId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT
        o.id,
        o.occurrence_type,
        o.description,
        o.occurrence_date,
        c.name AS class_name,
        c.id AS class_id
      FROM occurrence o
      INNER JOIN attendance a ON o.attendance_id = a.id
      INNER JOIN classe c ON a.classe_id = c.id
      WHERE o.student_id = ? AND o.active = 1
      ORDER BY o.occurrence_date DESC;
      ''',
      [studentId],
    );
    return result;
  }
  @override
  Future<Map<String, List<Map<String, dynamic>>>>
      getOccurrencesByClassIdGroupedByType(int classId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT
        o.id,
        o.occurrence_type,
        o.description,
        o.occurrence_date,
        s.name as student_name
      FROM occurrence o
      INNER JOIN attendance a ON o.attendance_id = a.id
      LEFT JOIN student s ON o.student_id = s.id
      WHERE a.classe_id = ? AND o.active = 1
      ORDER BY o.occurrence_date ASC
    ''',
      [classId],
    );

    final Map<String, List<Map<String, dynamic>>> groupedOccurrences = {};
    for (final row in result) {
      final type = row['occurrence_type'] as String;
      if (!groupedOccurrences.containsKey(type)) {
        groupedOccurrences[type] = [];
      }
      groupedOccurrences[type]!.add(row);
    }
    return groupedOccurrences;
  }
}
