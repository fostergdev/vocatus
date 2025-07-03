import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/homework.dart';
import 'package:vocatus/app/repositories/homework/i_homework_repository.dart';

class HomeworkRepository implements IHomeworkRepository {
  final DatabaseHelper _dbHelper;

  HomeworkRepository(this._dbHelper);

  @override
  Future<List<Homework>> getHomeworksByClasseId(int classeId) async {
    try {
      final db = await _dbHelper.database;

      final result = await db.rawQuery(
        '''
      SELECT h.*, 
             d.name AS discipline_name,
             d.active AS discipline_active,
             d.created_at AS discipline_created_at
      FROM homework h
      LEFT JOIN discipline d ON h.discipline_id = d.id
      WHERE h.classe_id = ? AND h.active = 1
      ORDER BY h.due_date ASC, h.created_at DESC
      ''',
        [classeId],
      );

      final homeworks = result.map((map) {
        try {
          final assignedDate = map['assigned_date'] != null
              ? DateTime.parse(map['assigned_date'] as String)
              : DateTime.parse(map['created_at'] as String);

          final homework = Homework(
            id: map['id'] as int,
            classeId: map['classe_id'] as int,
            disciplineId: map['discipline_id'] as int?,
            title: map['title'] as String,
            description: map['description'] as String?,
            dueDate: DateTime.parse(map['due_date'] as String),
            assignedDate: assignedDate,
            status: HomeworkStatus.values.firstWhere(
              (e) => e.name == (map['status'] as String),
              orElse: () => HomeworkStatus.pending,
            ),
            createdAt: map['created_at'] != null
                ? DateTime.parse(map['created_at'] as String)
                : null,
            active: (map['active'] as int) == 1,
          );

          if (map['discipline_id'] != null) {
            final discipline = Discipline(
              id: map['discipline_id'] as int,
              name: map['discipline_name']?.toString() ?? '',
              active: (map['discipline_active'] as int) == 1,
              createdAt: map['discipline_created_at'] != null
                  ? DateTime.parse(map['discipline_created_at'] as String)
                  : null,
            );
            return homework.copyWith(discipline: discipline);
          }

          return homework;
        } catch (e, stack) {
          throw FormatException('Falha ao converter dados da tarefa: $e');
        }
      }).toList();

      return homeworks;
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao buscar tarefas: ${e}');
    } catch (e) {
      throw Exception('Erro ao buscar tarefas: $e');
    }
  }

  @override
  Future<List<Homework>> getHomeworksByStatus(
    HomeworkStatus status, {
    int? classeId,
  }) async {
    try {
      final db = await _dbHelper.database;

      String whereClause = 'h.status = ? AND h.active = 1';
      List<dynamic> whereArgs = [status.name];

      if (classeId != null) {
        whereClause += ' AND h.classe_id = ?';
        whereArgs.add(classeId);
      }

      final result = await db.rawQuery('''
        SELECT h.*,
               d.name AS discipline_name,
               d.active AS discipline_active,
               d.created_at AS discipline_created_at
        FROM homework h
        LEFT JOIN discipline d ON h.discipline_id = d.id
        WHERE $whereClause
        ORDER BY h.due_date ASC, h.created_at DESC
        ''', whereArgs);

      final homeworks = result.map((map) {
        final homework = Homework.fromMap(map);
        if (map['discipline_id'] != null) {
          return homework.copyWith(
            discipline: Discipline(
              id: map['discipline_id'] as int?,
              name: map['discipline_name']?.toString() ?? '',
              active: map['discipline_active'] == 1,
            ),
          );
        }
        return homework;
      }).toList();

      return homeworks;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar tarefas por status: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar tarefas por status: $e');
    }
  }

  @override
  Future<List<Homework>> getHomeworksByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? classeId,
  }) async {
    try {
      final db = await _dbHelper.database;

      String whereClause =
          'h.due_date >= ? AND h.due_date <= ? AND h.active = 1';
      List<dynamic> whereArgs = [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ];

      if (classeId != null) {
        whereClause += ' AND h.classe_id = ?';
        whereArgs.add(classeId);
      }

      final result = await db.rawQuery('''
        SELECT h.*,
               d.name AS discipline_name,
               d.active AS discipline_active,
               d.created_at AS discipline_created_at
        FROM homework h
        LEFT JOIN discipline d ON h.discipline_id = d.id
        WHERE $whereClause
        ORDER BY h.due_date ASC, h.created_at DESC
        ''', whereArgs);

      final homeworks = result.map((map) {
        final homework = Homework.fromMap(map);
        if (map['discipline_id'] != null) {
          return homework.copyWith(
            discipline: Discipline(
              id: map['discipline_id'] as int?,
              name: map['discipline_name']?.toString() ?? '',
              active: map['discipline_active'] == 1,
            ),
          );
        }
        return homework;
      }).toList();

      return homeworks;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar tarefas por período: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar tarefas por período: $e');
    }
  }

  @override
  Future<void> createHomework(Homework homework) async {
    try {
      final db = await _dbHelper.database;

      final Map<String, dynamic> homeworkData = homework.toMap();
      homeworkData.remove('id');

      await db.insert('homework', homeworkData);
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao criar tarefa: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao criar tarefa: $e');
    }
  }

  @override
  Future<void> updateHomework(Homework homework) async {
    try {
      final db = await _dbHelper.database;

      final Map<String, dynamic> homeworkData = homework.toMap();
      homeworkData.remove('id');

      final int updatedRows = await db.update(
        'homework',
        homeworkData,
        where: 'id = ?',
        whereArgs: [homework.id],
      );

      if (updatedRows == 0) {
        throw Exception('Tarefa não encontrada para atualização');
      }
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao atualizar tarefa: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao atualizar tarefa: $e');
    }
  }

  @override
  Future<void> deleteHomework(int homeworkId) async {
    try {
      final db = await _dbHelper.database;

      final int updatedRows = await db.update(
        'homework',
        {'active': 0},
        where: 'id = ?',
        whereArgs: [homeworkId],
      );

      if (updatedRows == 0) {
        throw Exception('Tarefa não encontrada para exclusão');
      }
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao excluir tarefa: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao excluir tarefa: $e');
    }
  }

  @override
  Future<Homework?> getHomeworkById(int homeworkId) async {
    try {
      final db = await _dbHelper.database;

      final result = await db.rawQuery(
        '''
        SELECT h.*,
               d.name AS discipline_name,
               d.active AS discipline_active,
               d.created_at AS discipline_created_at
        FROM homework h
        LEFT JOIN discipline d ON h.discipline_id = d.id
        WHERE h.id = ? AND h.active = 1
        ''',
        [homeworkId],
      );

      if (result.isEmpty) {
        return null;
      }

      final map = result.first;
      final homework = Homework.fromMap(map);

      if (map['discipline_id'] != null) {
        final homeworkWithDiscipline = homework.copyWith(
          discipline: Discipline(
            id: map['discipline_id'] as int?,
            name: map['discipline_name']?.toString() ?? '',
            active: map['discipline_active'] == 1,
          ),
        );
        return homeworkWithDiscipline;
      }

      return homework;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar tarefa por ID: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar tarefa por ID: $e');
    }
  }

  @override
  Future<List<Discipline>> getAvailableDisciplines({int? classeId}) async {
    try {
      final db = await _dbHelper.database;

      String query = 'SELECT DISTINCT d.* FROM discipline d';
      List<dynamic> args = [];

      if (classeId != null) {
        query += '''
          INNER JOIN schedule s ON d.id = s.discipline_id
          WHERE s.classe_id = ? AND d.active = 1 AND s.active = 1
        ''';
        args.add(classeId);
      } else {
        query += ' WHERE d.active = 1';
      }

      query += ' ORDER BY d.name COLLATE NOCASE';

      final result = await db.rawQuery(query, args);

      final disciplines = result.map((map) => Discipline.fromMap(map)).toList();
      return disciplines;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar disciplinas disponíveis: ${e.toString()}',
      );
    } catch (e) {
      throw Exception(
        'Erro desconhecido ao buscar disciplinas disponíveis: $e',
      );
    }
  }

  @override
  Future<List<Homework>> getOverdueHomeworks({int? classeId}) async {
    try {
      final db = await _dbHelper.database;

      final today = DateTime.now().toIso8601String().split('T')[0];

      String whereClause = 'h.due_date < ? AND h.status = ? AND h.active = 1';
      List<dynamic> whereArgs = [today, HomeworkStatus.pending.name];

      if (classeId != null) {
        whereClause += ' AND h.classe_id = ?';
        whereArgs.add(classeId);
      }

      final result = await db.rawQuery('''
        SELECT h.*,
               d.name AS discipline_name,
               d.active AS discipline_active,
               d.created_at AS discipline_created_at
        FROM homework h
        LEFT JOIN discipline d ON h.discipline_id = d.id
        WHERE $whereClause
        ORDER BY h.due_date ASC
        ''', whereArgs);

      final homeworks = result.map((map) {
        final homework = Homework.fromMap(map);
        if (map['discipline_id'] != null) {
          return homework.copyWith(
            discipline: Discipline(
              id: map['discipline_id'] as int?,
              name: map['discipline_name']?.toString() ?? '',
              active: map['discipline_active'] == 1,
            ),
          );
        }
        return homework;
      }).toList();

      return homeworks;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar tarefas em atraso: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar tarefas em atraso: $e');
    }
  }

  @override
  Future<List<Homework>> getTodayHomeworks({int? classeId}) async {
    try {
      final today = DateTime.now();
      return await getHomeworksByDateRange(today, today, classeId: classeId);
    } catch (e) {
      throw Exception('Erro ao buscar tarefas de hoje: $e');
    }
  }

  @override
  Future<List<Homework>> getUpcomingHomeworks({
    int? classeId,
    int? days = 7,
  }) async {
    try {
      final today = DateTime.now();
      final futureDate = today.add(Duration(days: days ?? 7));
      return await getHomeworksByDateRange(
        today,
        futureDate,
        classeId: classeId,
      );
    } catch (e) {
      throw Exception('Erro ao buscar tarefas próximas: $e');
    }
  }
}
