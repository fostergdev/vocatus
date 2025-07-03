import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/occurrence.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/repositories/occurrence/i_occurrence_repository.dart';

class OccurrenceRepository implements IOccurrenceRepository {
  final DatabaseHelper _dbHelper;

  OccurrenceRepository(this._dbHelper);

  @override
  Future<List<Occurrence>> getOccurrencesByAttendanceId(int attendanceId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT 
          o.*, o.title,
          s.id AS student_id_fk, s.name AS student_name, s.active AS student_active, s.created_at AS student_created_at,
          a.id AS attendance_id_fk, a.classe_id, a.schedule_id, a.date AS attendance_date, a.content AS attendance_content
        FROM occurrence o
        LEFT JOIN student s ON o.student_id = s.id
        INNER JOIN attendance a ON o.attendance_id = a.id
        WHERE o.attendance_id = ? AND o.active = 1
        ORDER BY o.occurrence_date DESC, o.created_at DESC
        ''',
        [attendanceId],
      );

      return result.map((map) => _mapToOccurrenceWithRelations(map)).toList();
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao buscar ocorrências da chamada: ${e.toString()}');
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar ocorrências da chamada: $e');
    }
  }

  @override
  Future<List<Occurrence>> getOccurrencesByStudentId(int studentId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT 
          o.*, o.title,
          s.id AS student_id_fk, s.name AS student_name, s.active AS student_active, s.created_at AS student_created_at,
          a.id AS attendance_id_fk, a.classe_id, a.schedule_id, a.date AS attendance_date, a.content AS attendance_content
        FROM occurrence o
        INNER JOIN student s ON o.student_id = s.id
        INNER JOIN attendance a ON o.attendance_id = a.id
        WHERE o.student_id = ? AND o.active = 1
        ORDER BY o.occurrence_date DESC, o.created_at DESC
        ''',
        [studentId],
      );

      return result.map((map) => _mapToOccurrenceWithRelations(map)).toList();
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao buscar ocorrências do aluno: ${e.toString()}');
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar ocorrências do aluno: $e');
    }
  }

  @override
  Future<List<Occurrence>> getOccurrencesByClasseId(int classeId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final db = await _dbHelper.database;
      String query = '''
        SELECT 
          o.*, o.title,
          s.id AS student_id_fk, s.name AS student_name, s.active AS student_active, s.created_at AS student_created_at,
          a.id AS attendance_id_fk, a.classe_id, a.schedule_id, a.date AS attendance_date, a.content AS attendance_content
        FROM occurrence o
        LEFT JOIN student s ON o.student_id = s.id
        INNER JOIN attendance a ON o.attendance_id = a.id
        WHERE a.classe_id = ? AND o.active = 1
      ''';
      
      List<dynamic> args = [classeId];
      
      if (startDate != null) {
        query += ' AND o.occurrence_date >= ?';
        args.add(startDate.toIso8601String().split('T')[0]);
      }
      
      if (endDate != null) {
        query += ' AND o.occurrence_date <= ?';
        args.add(endDate.toIso8601String().split('T')[0]);
      }
      
      query += ' ORDER BY o.occurrence_date DESC, o.created_at DESC';

      final result = await db.rawQuery(query, args);
      return result.map((map) => _mapToOccurrenceWithRelations(map)).toList();
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao buscar ocorrências da turma: ${e.toString()}');
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar ocorrências da turma: $e');
    }
  }

  @override
  Future<List<Occurrence>> getOccurrencesByType(OccurrenceType type, {int? classeId}) async {
    try {
      final db = await _dbHelper.database;
      String query = '''
        SELECT 
          o.*, o.title,
          s.id AS student_id_fk, s.name AS student_name, s.active AS student_active, s.created_at AS student_created_at,
          a.id AS attendance_id_fk, a.classe_id, a.schedule_id, a.date AS attendance_date, a.content AS attendance_content
        FROM occurrence o
        LEFT JOIN student s ON o.student_id = s.id
        INNER JOIN attendance a ON o.attendance_id = a.id
        WHERE o.occurrence_type = ? AND o.active = 1
      ''';
      
      List<dynamic> args = [type.name];
      
      if (classeId != null) {
        query += ' AND a.classe_id = ?';
        args.add(classeId);
      }
      
      query += ' ORDER BY o.occurrence_date DESC, o.created_at DESC';

      final result = await db.rawQuery(query, args);
      return result.map((map) => _mapToOccurrenceWithRelations(map)).toList();
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao buscar ocorrências por tipo: ${e.toString()}');
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar ocorrências por tipo: $e');
    }
  }

  @override
  Future<List<Occurrence>> getGeneralOccurrences({int? classeId, DateTime? startDate, DateTime? endDate}) async {
    try {
      final db = await _dbHelper.database;
      String query = '''
        SELECT 
          o.*,
          a.id AS attendance_id_fk, a.classe_id, a.schedule_id, a.date AS attendance_date, a.content AS attendance_content
        FROM occurrence o
        INNER JOIN attendance a ON o.attendance_id = a.id
        WHERE o.student_id IS NULL AND o.active = 1
      ''';
      
      List<dynamic> args = [];
      
      if (classeId != null) {
        query += ' AND a.classe_id = ?';
        args.add(classeId);
      }
      
      if (startDate != null) {
        query += ' AND o.occurrence_date >= ?';
        args.add(startDate.toIso8601String().split('T')[0]);
      }
      
      if (endDate != null) {
        query += ' AND o.occurrence_date <= ?';
        args.add(endDate.toIso8601String().split('T')[0]);
      }
      
      query += ' ORDER BY o.occurrence_date DESC, o.created_at DESC';

      final result = await db.rawQuery(query, args);
      return result.map((map) => _mapToOccurrenceWithRelations(map)).toList();
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao buscar ocorrências gerais: ${e.toString()}');
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar ocorrências gerais: $e');
    }
  }

  @override
  Future<List<Occurrence>> getStudentOccurrences({int? classeId, int? studentId, DateTime? startDate, DateTime? endDate}) async {
    try {
      final db = await _dbHelper.database;
      String query = '''
        SELECT 
          o.*, o.title,
          s.id AS student_id_fk, s.name AS student_name, s.active AS student_active, s.created_at AS student_created_at,
          a.id AS attendance_id_fk, a.classe_id, a.schedule_id, a.date AS attendance_date, a.content AS attendance_content
        FROM occurrence o
        INNER JOIN student s ON o.student_id = s.id
        INNER JOIN attendance a ON o.attendance_id = a.id
        WHERE o.student_id IS NOT NULL AND o.active = 1
      ''';
      
      List<dynamic> args = [];
      
      if (classeId != null) {
        query += ' AND a.classe_id = ?';
        args.add(classeId);
      }
      
      if (studentId != null) {
        query += ' AND o.student_id = ?';
        args.add(studentId);
      }
      
      if (startDate != null) {
        query += ' AND o.occurrence_date >= ?';
        args.add(startDate.toIso8601String().split('T')[0]);
      }
      
      if (endDate != null) {
        query += ' AND o.occurrence_date <= ?';
        args.add(endDate.toIso8601String().split('T')[0]);
      }
      
      query += ' ORDER BY o.occurrence_date DESC, o.created_at DESC';

      final result = await db.rawQuery(query, args);
      return result.map((map) => _mapToOccurrenceWithRelations(map)).toList();
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao buscar ocorrências de alunos: ${e.toString()}');
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar ocorrências de alunos: $e');
    }
  }

  @override
  Future<void> createOccurrence(Occurrence occurrence) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('occurrence', occurrence.toMap());
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao criar ocorrência: ${e.toString()}');
    } catch (e) {
      throw Exception('Erro desconhecido ao criar ocorrência: $e');
    }
  }

  @override
  Future<void> updateOccurrence(Occurrence occurrence) async {
    try {
      final db = await _dbHelper.database;
      final Map<String, dynamic> occurrenceData = occurrence.toMap();
      occurrenceData.remove('id');
      
      await db.update(
        'occurrence',
        occurrenceData,
        where: 'id = ?',
        whereArgs: [occurrence.id],
      );
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao atualizar ocorrência: ${e.toString()}');
    } catch (e) {
      throw Exception('Erro desconhecido ao atualizar ocorrência: $e');
    }
  }

  @override
  Future<void> deleteOccurrence(int occurrenceId) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'occurrence',
        {'active': 0},
        where: 'id = ?',
        whereArgs: [occurrenceId],
      );
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao excluir ocorrência: ${e.toString()}');
    } catch (e) {
      throw Exception('Erro desconhecido ao excluir ocorrência: $e');
    }
  }

  @override
  Future<Occurrence?> getOccurrenceById(int occurrenceId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT 
          o.*, o.title,
          s.id AS student_id_fk, s.name AS student_name, s.active AS student_active, s.created_at AS student_created_at,
          a.id AS attendance_id_fk, a.classe_id, a.schedule_id, a.date AS attendance_date, a.content AS attendance_content
        FROM occurrence o
        LEFT JOIN student s ON o.student_id = s.id
        INNER JOIN attendance a ON o.attendance_id = a.id
        WHERE o.id = ? AND o.active = 1
        ''',
        [occurrenceId],
      );

      if (result.isNotEmpty) {
        return _mapToOccurrenceWithRelations(result.first);
      }
      return null;
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao buscar ocorrência: ${e.toString()}');
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar ocorrência: $e');
    }
  }

  @override
  Future<List<Student>> getStudentsFromAttendance(int attendanceId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT DISTINCT s.*
        FROM student s
        INNER JOIN student_attendance sa ON s.id = sa.student_id
        WHERE sa.attendance_id = ? AND sa.active = 1 AND s.active = 1
        ORDER BY s.name COLLATE NOCASE
        ''',
        [attendanceId],
      );

      return result.map((map) => Student.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao buscar alunos da chamada: ${e.toString()}');
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar alunos da chamada: $e');
    }
  }

  Occurrence _mapToOccurrenceWithRelations(Map<String, dynamic> map) {
    Student? student;
    if (map['student_id_fk'] != null) {
      student = Student.fromMap({
        'id': map['student_id_fk'],
        'name': map['student_name'],
        'active': map['student_active'],
        'created_at': map['student_created_at'],
      });
    }

    Attendance? attendance;
    if (map['attendance_id_fk'] != null) {
      attendance = Attendance.fromMap({
        'id': map['attendance_id_fk'],
        'classe_id': map['classe_id'],
        'schedule_id': map['schedule_id'],
        'date': map['attendance_date'],
        'content': map['attendance_content'],
      });
    }

    return Occurrence.fromMap(map).copyWith(
      student: student,
      attendance: attendance,
    );
  }
}
