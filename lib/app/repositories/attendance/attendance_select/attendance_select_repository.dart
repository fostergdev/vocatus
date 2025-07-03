import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/schedule.dart';
import 'package:vocatus/app/repositories/attendance/attendance_select/i_attendance_select_repository.dart';

class AttendanceSelectRepository implements IAttendanceSelectRepository {
  final DatabaseHelper _dbHelper;

  AttendanceSelectRepository(this._dbHelper);

  @override
  Future<List<Schedule>> getAllSchedulesForSelection({
    int? classeId,
    int? disciplineId,
    int? dayOfWeek,
    bool? activeStatus = true,
    int? year,
  }) async {
    try {
      final db = await _dbHelper.database;

      String query = '''
        SELECT
          s.*,
          d.name AS discipline_name,
          d.created_at AS discipline_created_at,
          d.active AS discipline_active,
          c.id AS classe_id_fk,
          c.name AS classe_name,
          c.description AS classe_description,
          c.school_year AS classe_school_year,
          c.active AS classe_active,
          c.created_at AS classe_created_at
        FROM schedule s
        LEFT JOIN discipline d ON s.discipline_id = d.id
        INNER JOIN classe c ON s.classe_id = c.id
        WHERE 1=1
      ''';
      List<dynamic> whereArgs = [];

      if (classeId != null) {
        query += ' AND s.classe_id = ?';
        whereArgs.add(classeId);
      }
      if (disciplineId != null) {
        query += ' AND s.discipline_id = ?';
        whereArgs.add(disciplineId);
      }
      if (dayOfWeek != null) {
        query += ' AND s.day_of_week = ?';
        whereArgs.add(dayOfWeek);
      }
      if (activeStatus != null) {
        query += ' AND s.active = ?';
        whereArgs.add(activeStatus ? 1 : 0);
      }
      if (year != null) {
        query += ' AND s.schedule_year = ?';
        whereArgs.add(year);
      }

      query += ' AND c.active = 1 '; // Sempre filtra por classes ativas para seleção
      query += ' ORDER BY s.day_of_week, s.start_time, c.name COLLATE NOCASE';
      
      final result = await db.rawQuery(query, whereArgs);

      final schedules = result.map((map) {
        final disciplineMap = {
          'id': map['discipline_id'],
          'name': map['discipline_name'],
          'created_at': map['discipline_created_at'],
          'active': map['discipline_active'],
        };
        final classeMap = {
          'id': map['classe_id_fk'],
          'name': map['classe_name'],
          'description': map['classe_description'],
          'school_year': map['classe_school_year'],
          'active': map['classe_active'],
          'created_at': map['classe_created_at'],
        };

        return Schedule.fromMap(map).copyWith(
          discipline: map['discipline_id'] != null
              ? Discipline.fromMap(disciplineMap)
              : null,
          classe: Classe.fromMap(classeMap),
        );
      }).toList();

      return schedules;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar horários para seleção: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar horários para seleção: $e');
    }
  }

  Future<bool> hasAttendanceForScheduleAndDate(int scheduleId, DateTime date) async {
    try {
      final db = await _dbHelper.database;
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      
      final result = await db.query(
        'attendance',
        columns: ['id'],
        where: 'schedule_id = ? AND date = ?',
        whereArgs: [scheduleId, formattedDate],
        limit: 1,
      );
      
      return result.isNotEmpty;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao verificar chamada existente: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao verificar chamada existente: $e');
    }
  }

  @override
  Future<List<Discipline>> getAllActiveDisciplines() async {
    try {
      final db = await _dbHelper.database;

      final result = await db.query(
        'discipline',
        where: 'active = ?',
        whereArgs: [1],
        orderBy: 'name COLLATE NOCASE',
      );
      
      final disciplines = result.map((map) => Discipline.fromMap(map)).toList();
      return disciplines;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar disciplinas ativas: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar disciplinas ativas: $e');
    }
  }

  @override
  Future<List<Classe>> getAllActiveClasses() async {
    try {
      final db = await _dbHelper.database;

      final result = await db.query(
        'classe',
        where: 'active = ?',
        whereArgs: [1],
        orderBy: 'name COLLATE NOCASE',
      );
      
      final classes = result.map((map) => Classe.fromMap(map)).toList();
      return classes;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar classes ativas: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar classes ativas: $e');
    }
  }
}