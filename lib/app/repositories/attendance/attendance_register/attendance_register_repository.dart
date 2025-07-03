import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/models/schedule.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import 'package:vocatus/app/models/student.dart';

import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/repositories/attendance/attendance_register/i_attendance_register_repository.dart';

class AttendanceRegisterRepository implements IAttendanceRegisterRepository {
  final DatabaseHelper _dbHelper;

  AttendanceRegisterRepository(this._dbHelper);

  @override
  Future<Attendance> createOrUpdateAttendance(
    Attendance attendance,
    List<StudentAttendance> studentAttendances,
  ) async {
    final db = await _dbHelper.database;

    return await db.transaction((txn) async {
      int attendanceId;
      Attendance? existingAttendance;

      final result = await txn.query(
        'attendance',
        where: 'schedule_id = ? AND date = ?',
        whereArgs: [
          attendance.scheduleId,
          attendance.date.toIso8601String().split('T')[0],
        ],
      );

      if (result.isNotEmpty) {
        existingAttendance = Attendance.fromMap(result.first);
        attendanceId = existingAttendance.id!;

        await txn.delete(
          'student_attendance',
          where: 'attendance_id = ?',
          whereArgs: [attendanceId],
        );
        await txn.update(
          'attendance',
          attendance.toMap()..['id'] = attendanceId,
          where: 'id = ?',
          whereArgs: [attendanceId],
        );
      } else {
        attendanceId = await txn.insert('attendance', attendance.toMap());
      }

      for (final sa in studentAttendances) {
        await txn.insert(
          'student_attendance',
          sa.copyWith(attendanceId: attendanceId).toMap(),
        );
      }

      return attendance.copyWith(id: attendanceId);
    });
  }

  @override
  Future<Attendance?> getAttendanceByScheduleAndDate(
    int scheduleId,
    DateTime date,
  ) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT 
          a.*,
          c.id AS classe_id_fk, c.name AS classe_name, c.school_year AS classe_school_year, c.active AS classe_active,
          s.id AS schedule_id_fk, s.day_of_week AS schedule_day_of_week, 
          s.start_time AS schedule_start_time, s.end_time AS schedule_end_time, 
          s.schedule_year AS schedule_year, s.active AS schedule_active
        FROM attendance a
        INNER JOIN classe c ON a.classe_id = c.id
        INNER JOIN schedule s ON a.schedule_id = s.id
        WHERE a.schedule_id = ? AND a.date = ? AND a.active = 1
      ''',
        [scheduleId, date.toIso8601String().split('T')[0]],
      );

      if (result.isNotEmpty) {
        final map = result.first;
        final classeMap = {
          'id': map['classe_id_fk'],
          'name': map['classe_name'],
          'school_year': map['classe_school_year'],
          'active': map['classe_active'],
        };
        final scheduleMap = {
          'id': map['schedule_id_fk'],
          'day_of_week': map['schedule_day_of_week'],
          'start_time': map['schedule_start_time'],
          'end_time': map['schedule_end_time'],
          'schedule_year': map['schedule_year'],
          'active': map['schedule_active'],
          'classe_id': map['classe_id_fk'],
        };

        return Attendance.fromMap(map).copyWith(
          classe: Classe.fromMap(classeMap),
          schedule: Schedule.fromMap(scheduleMap),
          content: map['content'] as String?,
        );
      }
      return null;
    } catch (e) {
      throw Exception(
        'Erro ao buscar chamada por schedule e data: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<StudentAttendance>> getStudentAttendancesByAttendanceId(
    int attendanceId,
  ) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT 
          sa.*, 
          s.name AS student_name, 
          s.active AS student_active,
          s.created_at AS student_created_at
        FROM student_attendance sa
        INNER JOIN student s ON sa.student_id = s.id
        WHERE sa.attendance_id = ? AND sa.active = 1
        ORDER BY s.name COLLATE NOCASE
      ''',
        [attendanceId],
      );

      final processedResult = result.map((map) {
        final studentMap = {
          'id': map['student_id'],
          'name': map['student_name'],
          'active': map['student_active'],
          'created_at': map['student_created_at'],
        };
        return StudentAttendance.fromMap(
          map,
        ).copyWith(student: Student.fromMap(studentMap));
      }).toList();
      return processedResult;
    } catch (e) {
      throw Exception(
        'Erro ao buscar presenças de alunos para chamada: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> toggleAttendanceActiveStatus(
    int attendanceId,
    bool newStatus,
  ) async {
    try {
      final db = await _dbHelper.database;
      final rowsAffected = await db.update(
        'attendance',
        {'active': newStatus ? 1 : 0},
        where: 'id = ?',
        whereArgs: [attendanceId],
      );
      if (rowsAffected == 0) {
        throw Exception('Chamada não encontrada para mudança de status.');
      }
      await db.update(
        'student_attendance',
        {'active': newStatus ? 1 : 0},
        where: 'attendance_id = ?',
        whereArgs: [attendanceId],
      );
    } catch (e) {
      throw Exception('Erro ao mudar status da chamada: ${e.toString()}');
    }
  }

  @override
  Future<List<Student>> getStudentsByClasseId(int classeId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT s.* FROM student s
        INNER JOIN classe_student cs ON cs.student_id = s.id
        WHERE cs.classe_id = ? AND cs.active = 1 AND s.active = 1
        ORDER BY s.name COLLATE NOCASE
      ''',
        [classeId],
      );
      return result.map((e) => Student.fromMap(e)).toList();
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar alunos da turma: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar alunos da turma: $e');
    }
  }
}
