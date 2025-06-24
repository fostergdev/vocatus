import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/repositories/report_files/i_report_files_repository.dart';

class ReportFilesRepository implements IReportFilesRepository {
  final DatabaseHelper _dbHelper;

  ReportFilesRepository(this._dbHelper);

  // For Classes in History (only inactive/archived classes)
  @override
  Future<List<Classe>> getArchivedClasses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classe',
      where: 'active = ?', // Filters by globally inactive classes
      whereArgs: [0],
      orderBy: 'school_year DESC, name COLLATE NOCASE',
    );
    return List.generate(maps.length, (i) {
      return Classe.fromMap(maps[i]);
    });
  }

  @override
  Future<List<int>> getYearsOfArchivedClasses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT school_year FROM classe WHERE active = 0 ORDER BY school_year DESC',
    );
    return maps.map((map) => map['school_year'] as int).toList();
  }

  @override
  Future<List<Classe>> getStudentInactiveEnrollments(int studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT c.*, cs.active as link_active, cs.start_date as enrollment_start_date, cs.end_date as enrollment_end_date
      FROM classe c
      INNER JOIN classe_student cs ON c.id = cs.classe_id
      WHERE cs.student_id = ? AND cs.active = 0 -- Filter by inactive class_student link
      ORDER BY cs.start_date DESC;
    ''',
      [studentId],
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      return Classe.fromMap(map);
    });
  }

  @override
  Future<List<Student>> getStudentsWithInactiveEnrollments() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT s.*
      FROM student s
      INNER JOIN classe_student cs ON s.id = cs.student_id
      WHERE cs.active = 0 -- Key change: Filter students who have at least one INACTIVE class_student link
      ORDER BY s.name COLLATE NOCASE;
      ''');
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  @override
  Future<List<int>> getYearsOfStudentsWithInactiveEnrollments() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT c.school_year
      FROM classe_student cs
      INNER JOIN classe c ON cs.classe_id = c.id
      WHERE cs.active = 0 -- Key change: Filter by INACTIVE class_student links
      ORDER BY c.school_year DESC;
      ''');
    return maps.map((map) => map['school_year'] as int).toList();
  }

  // Detail and general history methods (no active filter unless specified)

  @override
  Future<Classe?> getClasseById(int classeId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classe',
      where: 'id = ?',
      whereArgs: [classeId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Classe.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<Student?> getStudentById(int studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'student',
      where: 'id = ?',
      whereArgs: [studentId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<Student>> getStudentsAssociatedWithClasseHistory(
    int classeId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT DISTINCT s.*
      FROM student s
      INNER JOIN classe_student cs ON s.id = cs.student_id
      WHERE cs.classe_id = ?
      ORDER BY s.name COLLATE NOCASE;
    ''',
      [classeId],
    );
    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }

  @override
  Future<List<Grade>> getClasseSchedulesHistory(int classeId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'grade',
      where: 'classe_id = ?',
      whereArgs: [classeId],
    );
    return List.generate(maps.length, (i) {
      return Grade.fromMap(maps[i]);
    });
  }

  @override
  Future<List<Attendance>> getClasseAttendances(int classeId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'classe_id = ?',
      whereArgs: [classeId],
    );
    return List.generate(maps.length, (i) {
      return Attendance.fromMap(maps[i]);
    });
  }

  @override
  Future<List<Classe>> getClassesAssociatedWithStudentHistory(
    int studentId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT DISTINCT c.*
      FROM classe c
      INNER JOIN classe_student cs ON c.id = cs.classe_id
      WHERE cs.student_id = ?
      ORDER BY c.school_year DESC, c.name COLLATE NOCASE;
    ''',
      [studentId],
    );
    return List.generate(maps.length, (i) {
      return Classe.fromMap(maps[i]);
    });
  }

  // CRUCIAL: This method now also brings the 'active' status of the link (classe_student)
  // and enrollment dates.
  @override
  Future<List<Classe>> getStudentEnrollments(int studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT c.*, cs.active as link_active, cs.start_date as enrollment_start_date, cs.end_date as enrollment_end_date
      FROM classe c
      INNER JOIN classe_student cs ON c.id = cs.classe_id
      WHERE cs.student_id = ?
      ORDER BY cs.start_date DESC;
    ''',
      [studentId],
    );

    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      return Classe.fromMap(map);
    });
  }

  @override
  Future<List<StudentAttendance>> getStudentAttendanceHistory(
    int studentId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT
        sa.*,
        a.id AS attendance_id_alias,
        a.classe_id AS attendance_classe_id,
        a.grade_id AS attendance_grade_id,
        a.date AS attendance_date,
        a.content AS attendance_content,
        a.created_at AS attendance_created_at,
        a.active AS attendance_active,
        c.name AS classe_name,
        c.school_year AS classe_school_year,
        c.active AS classe_active,
        g.day_of_week AS grade_day_of_week,
        g.start_time AS grade_start_time,
        g.end_time AS grade_end_time,
        g.active AS grade_active,
        d.name AS discipline_name, -- Certifique-se de que 'discipline_name' está sendo selecionado
        d.id AS discipline_id_alias -- E que o ID da disciplina também está sendo selecionado
      FROM student_attendance sa
      INNER JOIN attendance a ON sa.attendance_id = a.id
      INNER JOIN classe c ON a.classe_id = c.id
      LEFT JOIN grade g ON a.grade_id = g.id
      LEFT JOIN discipline d ON g.discipline_id = d.id -- LEFT JOIN para pegar a disciplina
      WHERE sa.student_id = ?
      ORDER BY a.date DESC, g.start_time DESC;
    ''',
      [studentId],
    );

    return List.generate(maps.length, (i) {
      final map = maps[i];

      final attendanceMap = {
        'id': map['attendance_id_alias'],
        'classe_id': map['attendance_classe_id'],
        'grade_id': map['attendance_grade_id'],
        'date': map['attendance_date'],
        'content': map['attendance_content'],
        'created_at': map['attendance_created_at'],
        'active': map['attendance_active'],
      };
      final Attendance attendance = Attendance.fromMap(attendanceMap);

      final Classe classe = Classe.fromMap({
        'id': map['attendance_classe_id'],
        'name': map['classe_name'],
        'school_year': map['classe_school_year'],
        'active': map['classe_active'],
      });

      Grade? grade;
      if (map['grade_day_of_week'] != null) {
        final gradeMap = {
          'id': map['attendance_grade_id'],
          'classe_id': map['attendance_classe_id'],
          'discipline_id':
              map['discipline_id_alias'], // Use o alias do ID da disciplina
          'day_of_week': map['grade_day_of_week'],
          'start_time': map['grade_start_time'],
          'end_time': map['grade_end_time'],
          'grade_year': map['grade_year'],
          'active': map['grade_active'],
        };
        // Cria o objeto Grade a partir do mapa
        grade = Grade.fromMap(gradeMap);

        // **AQUI ESTÁ A PARTE CRUCIAL:**
        // Adiciona explicitamente o objeto Discipline ao Grade se o nome da disciplina estiver disponível
        final String? disciplineNameFromMap = map['discipline_name'] as String?;
        if (disciplineNameFromMap != null && disciplineNameFromMap.isNotEmpty) {
          grade = grade.copyWith(
            discipline: Discipline(
              id:
                  map['discipline_id_alias']
                      as int?, // Popula o ID da disciplina
              name: disciplineNameFromMap,
            ),
          );
        }
      }

      return StudentAttendance(
        attendanceId: map['attendance_id'] as int,
        studentId: map['student_id'] as int,
        presence: map['presence'] != null
            ? PresenceStatus.values[map['presence'] as int]
            : PresenceStatus.unknown,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'])
            : null,
        active: map['active'] == 1,
        attendance: attendance.copyWith(classe: classe, grade: grade),
      );
    });
  }

  @override
  Future<List<StudentAttendance>> getStudentAttendanceDetailsForAttendance(
    int attendanceId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'student_attendance',
      where: 'attendance_id = ?',
      whereArgs: [attendanceId],
    );
    return List.generate(maps.length, (i) {
      return StudentAttendance.fromMap(maps[i]);
    });
  }
}
