import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/homework.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/repositories/homework/i_homework_repository.dart';
import 'dart:developer';

class HomeworkRepository implements IHomeworkRepository {
  final DatabaseHelper _dbHelper;

  HomeworkRepository(this._dbHelper);

  @override
  Future<List<Homework>> getHomeworksByClasseId(int classeId) async {
    log('HomeworkRepository.getHomeworksByClasseId - Iniciando busca de tarefas para turma ID: $classeId', name: 'HomeworkRepository');
    
    try {
      log('HomeworkRepository.getHomeworksByClasseId - Obtendo instância do banco de dados.', name: 'HomeworkRepository');
      final db = await _dbHelper.database;
      log('HomeworkRepository.getHomeworksByClasseId - Banco de dados obtido com sucesso.', name: 'HomeworkRepository');

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

      log('HomeworkRepository.getHomeworksByClasseId - Query executada. ${result.length} tarefas encontradas.', name: 'HomeworkRepository');

      final homeworks = result.map((map) {
        final homework = Homework.fromMap(map);
        if (map['discipline_name'] != null) {
          return homework.copyWith(
            discipline: Discipline(
              id: map['discipline_id'] as int?,
              name: map['discipline_name'] as String,
              active: map['discipline_active'] == 1,
            ),
          );
        }
        return homework;
      }).toList();

      log('HomeworkRepository.getHomeworksByClasseId - Método concluído com sucesso. Total de tarefas processadas: ${homeworks.length}.', name: 'HomeworkRepository');
      return homeworks;
    } on DatabaseException catch (e) {
      log('HomeworkRepository.getHomeworksByClasseId - Erro de DatabaseException: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro de banco de dados ao buscar tarefas da turma: ${e.toString()}');
    } catch (e) {
      log('HomeworkRepository.getHomeworksByClasseId - Erro desconhecido: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro desconhecido ao buscar tarefas da turma: $e');
    }
  }

  @override
  Future<List<Homework>> getHomeworksByStatus(HomeworkStatus status, {int? classeId}) async {
    log('HomeworkRepository.getHomeworksByStatus - Iniciando busca de tarefas por status: ${status.name}', name: 'HomeworkRepository');
    if (classeId != null) {
      log('HomeworkRepository.getHomeworksByStatus - Filtro de turma aplicado: $classeId', name: 'HomeworkRepository');
    }

    try {
      log('HomeworkRepository.getHomeworksByStatus - Obtendo instância do banco de dados.', name: 'HomeworkRepository');
      final db = await _dbHelper.database;
      log('HomeworkRepository.getHomeworksByStatus - Banco de dados obtido com sucesso.', name: 'HomeworkRepository');

      String whereClause = 'h.status = ? AND h.active = 1';
      List<dynamic> whereArgs = [status.name];

      if (classeId != null) {
        whereClause += ' AND h.classe_id = ?';
        whereArgs.add(classeId);
      }

      final result = await db.rawQuery(
        '''
        SELECT h.*,
               d.name AS discipline_name,
               d.active AS discipline_active,
               d.created_at AS discipline_created_at
        FROM homework h
        LEFT JOIN discipline d ON h.discipline_id = d.id
        WHERE $whereClause
        ORDER BY h.due_date ASC, h.created_at DESC
        ''',
        whereArgs,
      );

      log('HomeworkRepository.getHomeworksByStatus - Query executada. ${result.length} tarefas encontradas.', name: 'HomeworkRepository');

      final homeworks = result.map((map) {
        final homework = Homework.fromMap(map);
        if (map['discipline_name'] != null) {
          return homework.copyWith(
            discipline: Discipline(
              id: map['discipline_id'] as int?,
              name: map['discipline_name'] as String,
              active: map['discipline_active'] == 1,
            ),
          );
        }
        return homework;
      }).toList();

      log('HomeworkRepository.getHomeworksByStatus - Método concluído com sucesso. Total de tarefas processadas: ${homeworks.length}.', name: 'HomeworkRepository');
      return homeworks;
    } on DatabaseException catch (e) {
      log('HomeworkRepository.getHomeworksByStatus - Erro de DatabaseException: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro de banco de dados ao buscar tarefas por status: ${e.toString()}');
    } catch (e) {
      log('HomeworkRepository.getHomeworksByStatus - Erro desconhecido: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro desconhecido ao buscar tarefas por status: $e');
    }
  }

  @override
  Future<List<Homework>> getHomeworksByDateRange(DateTime startDate, DateTime endDate, {int? classeId}) async {
    log('HomeworkRepository.getHomeworksByDateRange - Iniciando busca de tarefas por período: ${startDate.toIso8601String()} até ${endDate.toIso8601String()}', name: 'HomeworkRepository');
    if (classeId != null) {
      log('HomeworkRepository.getHomeworksByDateRange - Filtro de turma aplicado: $classeId', name: 'HomeworkRepository');
    }

    try {
      log('HomeworkRepository.getHomeworksByDateRange - Obtendo instância do banco de dados.', name: 'HomeworkRepository');
      final db = await _dbHelper.database;
      log('HomeworkRepository.getHomeworksByDateRange - Banco de dados obtido com sucesso.', name: 'HomeworkRepository');

      String whereClause = 'h.due_date >= ? AND h.due_date <= ? AND h.active = 1';
      List<dynamic> whereArgs = [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ];

      if (classeId != null) {
        whereClause += ' AND h.classe_id = ?';
        whereArgs.add(classeId);
      }

      final result = await db.rawQuery(
        '''
        SELECT h.*,
               d.name AS discipline_name,
               d.active AS discipline_active,
               d.created_at AS discipline_created_at
        FROM homework h
        LEFT JOIN discipline d ON h.discipline_id = d.id
        WHERE $whereClause
        ORDER BY h.due_date ASC, h.created_at DESC
        ''',
        whereArgs,
      );

      log('HomeworkRepository.getHomeworksByDateRange - Query executada. ${result.length} tarefas encontradas.', name: 'HomeworkRepository');

      final homeworks = result.map((map) {
        final homework = Homework.fromMap(map);
        if (map['discipline_name'] != null) {
          return homework.copyWith(
            discipline: Discipline(
              id: map['discipline_id'] as int?,
              name: map['discipline_name'] as String,
              active: map['discipline_active'] == 1,
            ),
          );
        }
        return homework;
      }).toList();

      log('HomeworkRepository.getHomeworksByDateRange - Método concluído com sucesso. Total de tarefas processadas: ${homeworks.length}.', name: 'HomeworkRepository');
      return homeworks;
    } on DatabaseException catch (e) {
      log('HomeworkRepository.getHomeworksByDateRange - Erro de DatabaseException: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro de banco de dados ao buscar tarefas por período: ${e.toString()}');
    } catch (e) {
      log('HomeworkRepository.getHomeworksByDateRange - Erro desconhecido: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro desconhecido ao buscar tarefas por período: $e');
    }
  }

  @override
  Future<void> createHomework(Homework homework) async {
    log('HomeworkRepository.createHomework - Iniciando criação de tarefa: ${homework.title}', name: 'HomeworkRepository');
    log('HomeworkRepository.createHomework - Dados da tarefa: Turma=${homework.classeId}, Disciplina=${homework.disciplineId}, Data de entrega=${homework.dueDate.toIso8601String()}', name: 'HomeworkRepository');

    try {
      log('HomeworkRepository.createHomework - Obtendo instância do banco de dados.', name: 'HomeworkRepository');
      final db = await _dbHelper.database;
      log('HomeworkRepository.createHomework - Banco de dados obtido com sucesso.', name: 'HomeworkRepository');

      final Map<String, dynamic> homeworkData = homework.toMap();
      homeworkData.remove('id');

      final int homeworkId = await db.insert('homework', homeworkData);
      log('HomeworkRepository.createHomework - Tarefa criada com sucesso. ID: $homeworkId', name: 'HomeworkRepository');
    } on DatabaseException catch (e) {
      log('HomeworkRepository.createHomework - Erro de DatabaseException: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro de banco de dados ao criar tarefa: ${e.toString()}');
    } catch (e) {
      log('HomeworkRepository.createHomework - Erro desconhecido: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro desconhecido ao criar tarefa: $e');
    }
  }

  @override
  Future<void> updateHomework(Homework homework) async {
    log('HomeworkRepository.updateHomework - Iniciando atualização de tarefa ID: ${homework.id}', name: 'HomeworkRepository');
    log('HomeworkRepository.updateHomework - Novos dados: Título=${homework.title}, Status=${homework.status.name}', name: 'HomeworkRepository');

    try {
      log('HomeworkRepository.updateHomework - Obtendo instância do banco de dados.', name: 'HomeworkRepository');
      final db = await _dbHelper.database;
      log('HomeworkRepository.updateHomework - Banco de dados obtido com sucesso.', name: 'HomeworkRepository');

      final Map<String, dynamic> homeworkData = homework.toMap();
      homeworkData.remove('id');

      final int updatedRows = await db.update(
        'homework',
        homeworkData,
        where: 'id = ?',
        whereArgs: [homework.id],
      );

      if (updatedRows == 0) {
        log('HomeworkRepository.updateHomework - Nenhuma tarefa foi atualizada. ID não encontrado: ${homework.id}', name: 'HomeworkRepository');
        throw Exception('Tarefa não encontrada para atualização');
      }

      log('HomeworkRepository.updateHomework - Tarefa atualizada com sucesso. ID: ${homework.id}', name: 'HomeworkRepository');
    } on DatabaseException catch (e) {
      log('HomeworkRepository.updateHomework - Erro de DatabaseException: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro de banco de dados ao atualizar tarefa: ${e.toString()}');
    } catch (e) {
      log('HomeworkRepository.updateHomework - Erro desconhecido: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro desconhecido ao atualizar tarefa: $e');
    }
  }

  @override
  Future<void> deleteHomework(int homeworkId) async {
    log('HomeworkRepository.deleteHomework - Iniciando exclusão (inativação) de tarefa ID: $homeworkId', name: 'HomeworkRepository');

    try {
      log('HomeworkRepository.deleteHomework - Obtendo instância do banco de dados.', name: 'HomeworkRepository');
      final db = await _dbHelper.database;
      log('HomeworkRepository.deleteHomework - Banco de dados obtido com sucesso.', name: 'HomeworkRepository');

      final int updatedRows = await db.update(
        'homework',
        {'active': 0},
        where: 'id = ?',
        whereArgs: [homeworkId],
      );

      if (updatedRows == 0) {
        log('HomeworkRepository.deleteHomework - Nenhuma tarefa foi inativada. ID não encontrado: $homeworkId', name: 'HomeworkRepository');
        throw Exception('Tarefa não encontrada para exclusão');
      }

      log('HomeworkRepository.deleteHomework - Tarefa inativada com sucesso. ID: $homeworkId', name: 'HomeworkRepository');
    } on DatabaseException catch (e) {
      log('HomeworkRepository.deleteHomework - Erro de DatabaseException: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro de banco de dados ao excluir tarefa: ${e.toString()}');
    } catch (e) {
      log('HomeworkRepository.deleteHomework - Erro desconhecido: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro desconhecido ao excluir tarefa: $e');
    }
  }

  @override
  Future<Homework?> getHomeworkById(int homeworkId) async {
    log('HomeworkRepository.getHomeworkById - Iniciando busca de tarefa por ID: $homeworkId', name: 'HomeworkRepository');

    try {
      log('HomeworkRepository.getHomeworkById - Obtendo instância do banco de dados.', name: 'HomeworkRepository');
      final db = await _dbHelper.database;
      log('HomeworkRepository.getHomeworkById - Banco de dados obtido com sucesso.', name: 'HomeworkRepository');

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

      log('HomeworkRepository.getHomeworkById - Query executada. ${result.length} resultado(s) encontrado(s).', name: 'HomeworkRepository');

      if (result.isEmpty) {
        log('HomeworkRepository.getHomeworkById - Tarefa não encontrada. ID: $homeworkId', name: 'HomeworkRepository');
        return null;
      }

      final map = result.first;
      final homework = Homework.fromMap(map);
      
      if (map['discipline_name'] != null) {
        final homeworkWithDiscipline = homework.copyWith(
          discipline: Discipline(
            id: map['discipline_id'] as int?,
            name: map['discipline_name'] as String,
            active: map['discipline_active'] == 1,
          ),
        );
        log('HomeworkRepository.getHomeworkById - Tarefa encontrada com disciplina. ID: $homeworkId', name: 'HomeworkRepository');
        return homeworkWithDiscipline;
      }

      log('HomeworkRepository.getHomeworkById - Tarefa encontrada sem disciplina. ID: $homeworkId', name: 'HomeworkRepository');
      return homework;
    } on DatabaseException catch (e) {
      log('HomeworkRepository.getHomeworkById - Erro de DatabaseException: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro de banco de dados ao buscar tarefa por ID: ${e.toString()}');
    } catch (e) {
      log('HomeworkRepository.getHomeworkById - Erro desconhecido: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro desconhecido ao buscar tarefa por ID: $e');
    }
  }

  @override
  Future<List<Discipline>> getAvailableDisciplines({int? classeId}) async {
    log('HomeworkRepository.getAvailableDisciplines - Iniciando busca de disciplinas disponíveis', name: 'HomeworkRepository');
    if (classeId != null) {
      log('HomeworkRepository.getAvailableDisciplines - Filtro de turma aplicado: $classeId', name: 'HomeworkRepository');
    }

    try {
      log('HomeworkRepository.getAvailableDisciplines - Obtendo instância do banco de dados.', name: 'HomeworkRepository');
      final db = await _dbHelper.database;
      log('HomeworkRepository.getAvailableDisciplines - Banco de dados obtido com sucesso.', name: 'HomeworkRepository');

      String query = 'SELECT DISTINCT d.* FROM discipline d';
      List<dynamic> args = [];

      if (classeId != null) {
        query += '''
          INNER JOIN grade g ON d.id = g.discipline_id
          WHERE g.classe_id = ? AND d.active = 1 AND g.active = 1
        ''';
        args.add(classeId);
      } else {
        query += ' WHERE d.active = 1';
      }

      query += ' ORDER BY d.name COLLATE NOCASE';

      final result = await db.rawQuery(query, args);
      log('HomeworkRepository.getAvailableDisciplines - Query executada. ${result.length} disciplinas encontradas.', name: 'HomeworkRepository');

      final disciplines = result.map((map) => Discipline.fromMap(map)).toList();
      log('HomeworkRepository.getAvailableDisciplines - Método concluído com sucesso. Total de disciplinas processadas: ${disciplines.length}.', name: 'HomeworkRepository');
      return disciplines;
    } on DatabaseException catch (e) {
      log('HomeworkRepository.getAvailableDisciplines - Erro de DatabaseException: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro de banco de dados ao buscar disciplinas disponíveis: ${e.toString()}');
    } catch (e) {
      log('HomeworkRepository.getAvailableDisciplines - Erro desconhecido: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro desconhecido ao buscar disciplinas disponíveis: $e');
    }
  }

  @override
  Future<List<Homework>> getOverdueHomeworks({int? classeId}) async {
    log('HomeworkRepository.getOverdueHomeworks - Iniciando busca de tarefas em atraso', name: 'HomeworkRepository');
    if (classeId != null) {
      log('HomeworkRepository.getOverdueHomeworks - Filtro de turma aplicado: $classeId', name: 'HomeworkRepository');
    }

    try {
      log('HomeworkRepository.getOverdueHomeworks - Obtendo instância do banco de dados.', name: 'HomeworkRepository');
      final db = await _dbHelper.database;
      log('HomeworkRepository.getOverdueHomeworks - Banco de dados obtido com sucesso.', name: 'HomeworkRepository');

      final today = DateTime.now().toIso8601String().split('T')[0];
      
      String whereClause = 'h.due_date < ? AND h.status = ? AND h.active = 1';
      List<dynamic> whereArgs = [today, HomeworkStatus.pending.name];

      if (classeId != null) {
        whereClause += ' AND h.classe_id = ?';
        whereArgs.add(classeId);
      }

      final result = await db.rawQuery(
        '''
        SELECT h.*,
               d.name AS discipline_name,
               d.active AS discipline_active,
               d.created_at AS discipline_created_at
        FROM homework h
        LEFT JOIN discipline d ON h.discipline_id = d.id
        WHERE $whereClause
        ORDER BY h.due_date ASC
        ''',
        whereArgs,
      );

      log('HomeworkRepository.getOverdueHomeworks - Query executada. ${result.length} tarefas em atraso encontradas.', name: 'HomeworkRepository');

      final homeworks = result.map((map) {
        final homework = Homework.fromMap(map);
        if (map['discipline_name'] != null) {
          return homework.copyWith(
            discipline: Discipline(
              id: map['discipline_id'] as int?,
              name: map['discipline_name'] as String,
              active: map['discipline_active'] == 1,
            ),
          );
        }
        return homework;
      }).toList();

      log('HomeworkRepository.getOverdueHomeworks - Método concluído com sucesso. Total de tarefas em atraso processadas: ${homeworks.length}.', name: 'HomeworkRepository');
      return homeworks;
    } on DatabaseException catch (e) {
      log('HomeworkRepository.getOverdueHomeworks - Erro de DatabaseException: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro de banco de dados ao buscar tarefas em atraso: ${e.toString()}');
    } catch (e) {
      log('HomeworkRepository.getOverdueHomeworks - Erro desconhecido: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro desconhecido ao buscar tarefas em atraso: $e');
    }
  }

  @override
  Future<List<Homework>> getTodayHomeworks({int? classeId}) async {
    log('HomeworkRepository.getTodayHomeworks - Iniciando busca de tarefas para hoje', name: 'HomeworkRepository');
    if (classeId != null) {
      log('HomeworkRepository.getTodayHomeworks - Filtro de turma aplicado: $classeId', name: 'HomeworkRepository');
    }

    try {
      final today = DateTime.now();
      return await getHomeworksByDateRange(today, today, classeId: classeId);
    } catch (e) {
      log('HomeworkRepository.getTodayHomeworks - Erro: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro ao buscar tarefas de hoje: $e');
    }
  }

  @override
  Future<List<Homework>> getUpcomingHomeworks({int? classeId, int? days = 7}) async {
    log('HomeworkRepository.getUpcomingHomeworks - Iniciando busca de tarefas próximas (próximos $days dias)', name: 'HomeworkRepository');
    if (classeId != null) {
      log('HomeworkRepository.getUpcomingHomeworks - Filtro de turma aplicado: $classeId', name: 'HomeworkRepository');
    }

    try {
      final today = DateTime.now();
      final futureDate = today.add(Duration(days: days ?? 7));
      return await getHomeworksByDateRange(today, futureDate, classeId: classeId);
    } catch (e) {
      log('HomeworkRepository.getUpcomingHomeworks - Erro: $e', name: 'HomeworkRepository', error: e);
      throw Exception('Erro ao buscar tarefas próximas: $e');
    }
  }
}
