// lib/app/repositories/attendance_select/attendance_select_repository.dart

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/repositories/attendance/attendance_select/i_attendance_select_repository.dart';

class AttendanceSelectRepository implements IAttendanceSelectRepository {
  final DatabaseHelper _dbHelper;

  AttendanceSelectRepository(this._dbHelper);

  @override
  Future<List<Grade>> getAllGradesForSelection({
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
          g.*,
          d.name AS discipline_name,
          d.created_at AS discipline_created_at,
          d.active AS discipline_active,
          c.id AS classe_id_fk,
          c.name AS classe_name,
          c.description AS classe_description,
          c.school_year AS classe_school_year,
          c.active AS classe_active,
          c.created_at AS classe_created_at
        FROM grade g
        LEFT JOIN discipline d ON g.discipline_id = d.id
        INNER JOIN classe c ON g.classe_id = c.id
        WHERE 1=1
      ''';
      List<dynamic> whereArgs = [];

      if (classeId != null) {
        query += ' AND g.classe_id = ?';
        whereArgs.add(classeId);
      }
      if (disciplineId != null) {
        query += ' AND g.discipline_id = ?';
        whereArgs.add(disciplineId);
      }
      if (dayOfWeek != null) {
        query += ' AND g.day_of_week = ?';
        whereArgs.add(dayOfWeek);
      }
      if (activeStatus != null) {
        query += ' AND g.active = ?';
        whereArgs.add(activeStatus ? 1 : 0);
      }
      if (year != null) {
        query += ' AND g.grade_year = ?';
        whereArgs.add(year);
      }

      query += ' AND c.active = 1 ';
      query += ' ORDER BY g.day_of_week, g.start_time, c.name COLLATE NOCASE';

      final result = await db.rawQuery(query, whereArgs);

      return result.map((map) {
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

        return Grade.fromMap(map).copyWith(
          discipline: map['discipline_id'] != null
              ? Discipline.fromMap(disciplineMap)
              : null,
          classe: Classe.fromMap(classeMap),
        );
      }).toList();
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar horários para seleção: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar horários para seleção: $e');
    }
  }

  Future<bool> hasAttendanceForGradeAndDate(int gradeId, DateTime date) async {
    try {
      final db = await _dbHelper.database;
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final result = await db.query(
        'attendance',
        columns: ['id'],
        where: 'grade_id = ? AND date = ?',
        whereArgs: [gradeId, formattedDate],
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
      return result.map((map) => Discipline.fromMap(map)).toList();
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
      return result.map((map) => Classe.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar classes ativas: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar classes ativas: $e');
    }
  }
}
