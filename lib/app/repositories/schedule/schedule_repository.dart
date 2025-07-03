import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/schedule.dart';
import 'package:vocatus/app/repositories/schedule/i_schedule_repository.dart';

class ScheduleRepository implements IScheduleRepository {
  final DatabaseHelper _dbHelper;

  ScheduleRepository(this._dbHelper);

  @override
  Future<Schedule> createSchedule(Schedule schedule) async {
    try {
      final db = await _dbHelper.database;
      
      final scheduleMap = schedule.toMap();
      
      final id = await db.insert(
        'schedule',
        scheduleMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      
      final result = schedule.copyWith(id: id);
      return result;
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception(
          'Já existe um horário agendado idêntico para esta turma, dia e hora. (DB UNIQUE)',
        );
      }
      throw Exception(
        'Erro de banco de dados ao criar horário: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao criar horário: $e');
    }
  }

  @override
  Future<List<Schedule>> getSchedulesByClasseId(int classeId) async {
    try {
      final db = await _dbHelper.database;
      
      final query = '''
        SELECT 
          s.*, 
          d.name AS discipline_name, 
          d.created_at AS discipline_created_at,
          d.active AS discipline_active,
          c.name AS classe_name,
          c.description AS classe_description,
          c.school_year AS classe_school_year,
          c.active AS classe_active,
          c.created_at AS classe_created_at
        FROM schedule s
        LEFT JOIN discipline d ON s.discipline_id = d.id
        INNER JOIN classe c ON s.classe_id = c.id
        WHERE s.classe_id = ? AND s.active = 1
        ORDER BY s.day_of_week, s.start_time
      ''';
      
      final result = await db.rawQuery(query, [classeId]);

      final schedules = result.map((map) {
        
        final disciplineMap = {
          'id': map['discipline_id'],
          'name': map['discipline_name'],
          'created_at': map['discipline_created_at'],
          'active': map['discipline_active'],
        };
        final classeMap = {
          'id': map['classe_id'],
          'name': map['classe_name'],
          'description': map['classe_description'],
          'school_year': map['classe_school_year'],
          'active': map['classe_active'],
          'created_at': map['classe_created_at'],
        };

        final schedules = Schedule.fromMap(map).copyWith(
          discipline: map['discipline_id'] != null
              ? Discipline.fromMap(disciplineMap)
              : null,
          classe: Classe.fromMap(classeMap),
        );
        
        return schedules;
      }).toList();
      
      return schedules;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar horários da turma: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar horários da turma: $e');
    }
  }

  @override
  Future<List<Schedule>> getAllSchedules({
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
        query += ' AND c.school_year = ?';
        whereArgs.add(year);
      }

      query += ' AND c.active = 1 ';
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
          'id': map['classe_id'],
          'name': map['classe_name'],
          'description': map['classe_description'],
          'school_year': map['classe_school_year'],
          'active': map['classe_active'],
          'created_at': map['classe_created_at'],
        };

        final schedule = Schedule.fromMap(map).copyWith(
          discipline: map['discipline_id'] != null
              ? Discipline.fromMap(disciplineMap)
              : null,
          classe: Classe.fromMap(classeMap),
        );
        
        return schedule;
      }).toList();
      
      return schedules;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar todos os horários: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar todos os horários: $e');
    }
  }

  @override
  Future<void> updateSchedule(Schedule schedule) async {
    try {
      final db = await _dbHelper.database;
      
      final scheduleMap = schedule.toMap();
      
      final rowsAffected = await db.update(
        'schedule',
        scheduleMap,
        where: 'id = ?',
        whereArgs: [schedule.id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      
      if (rowsAffected == 0) {
        throw Exception('Horário não encontrado para atualização.');
      }
      
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception(
          'Já existe um horário agendado idêntico para esta turma, dia e hora.',
        );
      }
      throw Exception(
        'Erro de banco de dados ao atualizar horário: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao atualizar horário: $e');
    }
  }

  @override
  Future<void> toggleScheduleActiveStatus(Schedule schedule) async {
    try {
      final db = await _dbHelper.database;
      
      final newStatus = (schedule.active ?? true) ? 0 : 1;
      
      final rowsAffected = await db.update(
        'schedule',
        {'active': newStatus},
        where: 'id = ?',
        whereArgs: [schedule.id],
      );
      
      if (rowsAffected == 0) {
        throw Exception('Horário não encontrado para mudança de status.');
      }
      
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao mudar status do horário: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao mudar status do horário: $e');
    }
  }

  @override
  Future<List<Discipline>> getAllDisciplines() async {
    try {
      final db = await _dbHelper.database;
      
      final result = await db.query(
        'discipline',
        where: 'active = ?',
        whereArgs: [1],
        orderBy: 'name COLLATE NOCASE',
      );
      
      final disciplines = result.map((map) {
        return Discipline.fromMap(map);
      }).toList();
      
      return disciplines;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar disciplinas: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar disciplinas: $e');
    }
  }

  @override
  Future<List<Classe>> getAllActiveClasses([int? year]) async {
    try {
      final db = await _dbHelper.database;
      
      String where = 'active = ?';
      List<dynamic> whereArgs = [1];

      if (year != null) {
        where += ' AND school_year = ?';
        whereArgs.add(year);
      }

      final result = await db.query(
        'classe',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'name COLLATE NOCASE',
      );
      
      final classes = result.map((map) {
        return Classe.fromMap(map);
      }).toList();
      
      return classes;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar classes ativas: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar classes ativas: $e');
    }
  }

  @override
  Future<void> deleteSchedule(int scheduleId) {
    throw UnimplementedError();
  }
}