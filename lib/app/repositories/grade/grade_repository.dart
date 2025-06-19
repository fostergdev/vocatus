import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/repositories/grade/i_grade_repository.dart';

class GradeRepository implements IGradeRepository {
  final DatabaseHelper _dbHelper;

  GradeRepository(this._dbHelper);

  @override
  Future<Grade> createGrade(Grade grade) async {
    try {
      final db = await _dbHelper.database;
      final id = await db.insert(
        'grade',
        grade.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return grade.copyWith(id: id);
    } on DatabaseException catch (e, stackTrace) {
      log(stackTrace.toString(), error: e);
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception(
          'Já existe um horário agendado idêntico para esta turma, dia e hora. (DB UNIQUE)',
        );
      }
      throw Exception(
        'Erro de banco de dados ao criar horário: ${e.toString()}',
      );
    } catch (e, stackTrace) {
      log(stackTrace.toString(), error: e);
      throw Exception('Erro desconhecido ao criar horário: $e');
    }
  }

  @override
  Future<List<Grade>> getGradesByClasseId(int classeId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT 
          g.*, 
          d.name AS discipline_name, 
          d.created_at AS discipline_created_at,
          d.active AS discipline_active,
          c.name AS classe_name,
          c.description AS classe_description,
          c.school_year AS classe_school_year,
          c.active AS classe_active,
          c.created_at AS classe_created_at
        FROM grade g
        LEFT JOIN discipline d ON g.discipline_id = d.id
        INNER JOIN classe c ON g.classe_id = c.id
        WHERE g.classe_id = ? AND g.active = 1
        ORDER BY g.day_of_week, g.start_time
      ''',
        [classeId],
      );

      return result.map((map) {
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

        return Grade.fromMap(map).copyWith(
          discipline: map['discipline_id'] != null
              ? Discipline.fromMap(disciplineMap)
              : null,
          classe: Classe.fromMap(classeMap),
        );
      }).toList();
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar horários da turma: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar horários da turma: $e');
    }
  }

  @override
  Future<List<Grade>> getAllGrades({
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
        query += ' AND c.school_year = ?';
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
          'id': map['classe_id'],
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
        'Erro de banco de dados ao buscar todos os horários: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar todos os horários: $e');
    }
  }

  @override
  Future<void> updateGrade(Grade grade) async {
    try {
      final db = await _dbHelper.database;
      // Simplesmente atualiza os campos da grade existente pelo ID
      final rowsAffected = await db.update(
        'grade',
        grade
            .toMap(), // grade.toMap() agora inclui startTimeTotalMinutes e endTimeTotalMinutes
        where: 'id = ?',
        whereArgs: [grade.id],
        conflictAlgorithm: ConflictAlgorithm
            .abort, // Para evitar conflitos de unicidade (dia, hora, turma)
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
  Future<void> toggleGradeActiveStatus(Grade grade) async {
    try {
      final db = await _dbHelper.database;
      final newStatus = (grade.active ?? true) ? 0 : 1; // Inverte o status
      final rowsAffected = await db.update(
        'grade',
        {'active': newStatus},
        where: 'id = ?',
        whereArgs: [grade.id],
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
      return result.map((map) => Discipline.fromMap(map)).toList();
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

      return result.map((map) => Classe.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar classes ativas: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar classes ativas: $e');
    }
  }

  @override
  Future<void> deleteGrade(int gradeId) {
    // TODO: implement deleteGrade
    throw UnimplementedError();
  }
}
