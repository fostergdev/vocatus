// app/repositories/classes/classes_repository.dart

import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/repositories/classes/i_classes_repository.dart';

class ClasseRepository implements IClasseRepository {
  final DatabaseHelper _databaseHelper;

  ClasseRepository(this._databaseHelper);

  @override
  Future<Classe> createClasse(Classe classe) async {
    log('ClasseRepository.createClasse - Iniciando criação de turma: ${classe.name} (${classe.schoolYear})', name: 'ClasseRepository');
    log('ClasseRepository.createClasse - Dados da turma: name=${classe.name}, description=${classe.description}, schoolYear=${classe.schoolYear}, active=${classe.active}', name: 'ClasseRepository');

    try {
      log('ClasseRepository.createClasse - Tentando obter o banco de dados...', name: 'ClasseRepository');
      final db = await _databaseHelper.database;
      log('ClasseRepository.createClasse - Banco de dados obtido com sucesso.', name: 'ClasseRepository');

      log('ClasseRepository.createClasse - Verificando se já existe turma ativa com esse nome...', name: 'ClasseRepository');
      final existing = await db.query(
        'classe',
        where: 'LOWER(name) = ? AND school_year = ? AND active = 1',
        whereArgs: [classe.name.toLowerCase(), classe.schoolYear],
      );

      log('ClasseRepository.createClasse - Turmas existentes encontradas: ${existing.length}', name: 'ClasseRepository');
      if (existing.isNotEmpty) {
        log('ClasseRepository.createClasse - Turma já existe: ${existing.first}', name: 'ClasseRepository');
        throw ('Já existe uma turma ATIVA com esse nome para o ano ${classe.schoolYear}!');
      }

      log('ClasseRepository.createClasse - Inserindo nova turma no DB...', name: 'ClasseRepository');
      final dataToInsert = {
        'name': classe.name.toLowerCase(),
        'description': classe.description,
        'school_year': classe.schoolYear,
        'created_at': classe.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'active': (classe.active ?? true) ? 1 : 0,
      };
      log('ClasseRepository.createClasse - Dados para inserção: $dataToInsert', name: 'ClasseRepository');

      final id = await db.insert('classe', dataToInsert, conflictAlgorithm: ConflictAlgorithm.abort);
      log('ClasseRepository.createClasse - Turma criada com sucesso. ID: $id', name: 'ClasseRepository');
      
      final result = Classe(
        id: id,
        name: classe.name,
        description: classe.description,
        schoolYear: classe.schoolYear,
        createdAt: classe.createdAt ?? DateTime.now(),
        active: classe.active,
      );
      log('ClasseRepository.createClasse - Método createClasse concluído com sucesso. Resultado: ${result.toMap()}', name: 'ClasseRepository');
      return result;
    } on DatabaseException catch (e) {
      log('ClasseRepository.createClasse - Erro de DatabaseException: $e', name: 'ClasseRepository', error: e);
      if (e.toString().contains('UNIQUE constraint failed')) {
        log('ClasseRepository.createClasse - Erro de constraint UNIQUE detectado. Turma com nome/ano duplicado.', name: 'ClasseRepository');
        throw ('Já existe uma turma com esse nome para o ano ${classe.schoolYear}!');
      } else {
        log('ClasseRepository.createClasse - Erro geral de banco de dados.', name: 'ClasseRepository');
        throw ('Erro de banco de dados ao criar turma: ${e.toString()}');
      }
    } catch (e) {
      log('ClasseRepository.createClasse - Erro desconhecido: $e', name: 'ClasseRepository', error: e);
      throw ('Erro desconhecido ao criar turma: $e');
    }
  }

  @override
  Future<List<Classe>> readClasses({bool? active, int? year}) async {
    log('ClasseRepository.readClasses - Iniciando busca de turmas', name: 'ClasseRepository');
    log('ClasseRepository.readClasses - Filtros: active=$active, year=$year', name: 'ClasseRepository');
    
    try {
      log('ClasseRepository.readClasses - Tentando obter o banco de dados...', name: 'ClasseRepository');
      final db = await _databaseHelper.database;
      log('ClasseRepository.readClasses - Banco de dados obtido com sucesso.', name: 'ClasseRepository');
      
      final currentYear = DateTime.now().year;
      final effectiveYear = year ?? currentYear;
      final effectiveActive = active;
      
      log('ClasseRepository.readClasses - Ano efetivo: $effectiveYear, Status ativo efetivo: $effectiveActive', name: 'ClasseRepository');
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      // Sempre filtra por ano
      whereClause += "school_year = ?";
      whereArgs.add(effectiveYear);
      
      if (effectiveActive != null) {
        whereClause += " AND active = ?";
        whereArgs.add(effectiveActive ? 1 : 0);
      }

      log('ClasseRepository.readClasses - Construindo WHERE: $whereClause, ARGS: $whereArgs', name: 'ClasseRepository');

      log('ClasseRepository.readClasses - Executando consulta SQL...', name: 'ClasseRepository');
      final result = await db.query(
        'classe',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'name ASC',
      );
      
      log('ClasseRepository.readClasses - Consulta concluída. ${result.length} turmas encontradas', name: 'ClasseRepository');
      if (result.isNotEmpty) {
        log('ClasseRepository.readClasses - Primeira turma retornada (exemplo): ${result.first}', name: 'ClasseRepository');
      }
      
      final classes = result.map((map) {
        // log('ClasseRepository.readClasses - Processando turma: ${map['name']} (ID: ${map['id']})', name: 'ClasseRepository'); // Comentar para logs menos verbosos em loop
        return Classe.fromMap(map);
      }).toList();
      
      log('ClasseRepository.readClasses - Método readClasses concluído com sucesso. Total de turmas processadas: ${classes.length}', name: 'ClasseRepository');
      return classes;
    } on DatabaseException catch (e) {
      log('ClasseRepository.readClasses - Erro de DatabaseException: $e', name: 'ClasseRepository', error: e);
      if (e.isNoSuchTableError('classe')) {
        log('ClasseRepository.readClasses - Tabela classe não encontrada.', name: 'ClasseRepository');
        throw ('Tabela de turmas não encontrada ao tentar ler!|$e');
      } else if (e.isSyntaxError()) {
        log('ClasseRepository.readClasses - Erro de sintaxe SQL na consulta de leitura.', name: 'ClasseRepository');
        throw ('Erro de sintaxe ao buscar turmas!|$e');
      }
      throw ('Erro ao buscar as turmas: $e');
    } catch (e) {
      log('ClasseRepository.readClasses - Erro desconhecido: $e', name: 'ClasseRepository', error: e);
      throw ('Erro desconhecido ao buscar classes: $e');
    }
  }

  @override
  Future<void> updateClasse(Classe classe) async {
    log('ClasseRepository.updateClasse - Iniciando atualização da turma ID: ${classe.id}', name: 'ClasseRepository');
    log('ClasseRepository.updateClasse - Novos dados: ${classe.toMap()}', name: 'ClasseRepository');
    
    try {
      log('ClasseRepository.updateClasse - Tentando obter o banco de dados...', name: 'ClasseRepository');
      final db = await _databaseHelper.database;
      log('ClasseRepository.updateClasse - Banco de dados obtido com sucesso.', name: 'ClasseRepository');
      
      final dataToUpdate = {
        'name': classe.name.toLowerCase(),
        'description': classe.description,
        'school_year': classe.schoolYear,
        // created_at geralmente não é atualizado, mas mantido se for o caso
        // 'created_at': classe.createdAt?.toIso8601String(), 
        'active': (classe.active ?? true) ? 1 : 0,
      };
      log('ClasseRepository.updateClasse - Dados para atualização: $dataToUpdate', name: 'ClasseRepository');
      
      log('ClasseRepository.updateClasse - Executando atualização no DB...', name: 'ClasseRepository');
      final rowsAffected = await db.update(
        'classe',
        dataToUpdate,
        where: 'id = ?',
        whereArgs: [classe.id],
      );
      
      log('ClasseRepository.updateClasse - Atualização concluída. Linhas afetadas: $rowsAffected', name: 'ClasseRepository');
      if (rowsAffected == 0) {
        log('ClasseRepository.updateClasse - Nenhuma linha foi afetada - turma com ID ${classe.id} não encontrada para atualização.', name: 'ClasseRepository');
      } else {
        log('ClasseRepository.updateClasse - Método updateClasse concluído com sucesso.', name: 'ClasseRepository');
      }
    } on DatabaseException catch (e) {
      log('ClasseRepository.updateClasse - Erro de DatabaseException: $e', name: 'ClasseRepository', error: e);
      if (e.toString().contains('UNIQUE constraint failed')) {
        log('ClasseRepository.updateClasse - Erro de constraint UNIQUE detectado. Turma com nome/ano duplicado.', name: 'ClasseRepository');
        throw ('Já existe uma turma com esse nome para o ano ${classe.schoolYear}!');
      }
      throw ('Erro de banco de dados ao atualizar turma: ${e.toString()}');
    } catch (e) {
      log('ClasseRepository.updateClasse - Erro desconhecido: $e', name: 'ClasseRepository', error: e);
      throw ('Erro desconhecido ao atualizar turma: $e');
    }
  }

  @override
  Future<void> archiveClasseAndStudents(Classe classe) async {
    log('ClasseRepository.archiveClasseAndStudents - Iniciando arquivamento da turma ID: ${classe.id}', name: 'ClasseRepository');
    log('ClasseRepository.archiveClasseAndStudents - Dados da turma: ${classe.toMap()}', name: 'ClasseRepository');
    
    if (classe.id == null) {
      log('ClasseRepository.archiveClasseAndStudents - ID da classe é nulo. Lançando exceção.', name: 'ClasseRepository');
      throw Exception('ID da classe é nulo, não foi possível arquivar.');
    }
    if (!(classe.active ?? true)) {
      log('ClasseRepository.archiveClasseAndStudents - Turma já está inativa, nada a fazer.', name: 'ClasseRepository');
      return;
    }

    try {
      log('ClasseRepository.archiveClasseAndStudents - Tentando obter o banco de dados e iniciar transação...', name: 'ClasseRepository');
      final db = await _databaseHelper.database;
      log('ClasseRepository.archiveClasseAndStudents - Banco de dados obtido. Iniciando transação.', name: 'ClasseRepository');
      
      await db.transaction((txn) async {
        log('ClasseRepository.archiveClasseAndStudents - Transação iniciada. Arquivando turma no DB...', name: 'ClasseRepository');
        await txn.update(
          'classe',
          {'active': 0},
          where: 'id = ?',
          whereArgs: [classe.id],
        );
        log('ClasseRepository.archiveClasseAndStudents - Turma ${classe.id} arquivada com sucesso.', name: 'ClasseRepository');

        log('ClasseRepository.archiveClasseAndStudents - Buscando alunos ativos na turma para arquivar suas relações...', name: 'ClasseRepository');
        final List<Map<String, dynamic>> studentsInClasseMaps = await txn
            .rawQuery(
              '''
          SELECT s.*
          FROM student s
          INNER JOIN classe_student cs ON s.id = cs.student_id
          WHERE cs.classe_id = ? AND cs.active = 1
          ''',
              [classe.id],
            );
        final List<Student> studentsInClasse = studentsInClasseMaps
            .map((e) => Student.fromMap(e))
            .toList();

        log('ClasseRepository.archiveClasseAndStudents - ${studentsInClasse.length} alunos ativos encontrados na turma ${classe.id}.', name: 'ClasseRepository');

        for (final student in studentsInClasse) {
          log('ClasseRepository.archiveClasseAndStudents - Processando aluno para arquivamento de relação: ${student.name} (ID: ${student.id})', name: 'ClasseRepository');
          
          await txn.update(
            'classe_student',
            {'active': 0, 'end_date': DateTime.now().toIso8601String()},
            where: 'student_id = ? AND classe_id = ?',
            whereArgs: [student.id, classe.id],
          );
          log('ClasseRepository.archiveClasseAndStudents - Relação aluno ${student.id}-turma ${classe.id} arquivada.', name: 'ClasseRepository');

          log('ClasseRepository.archiveClasseAndStudents - Verificando outras relações ativas para o aluno ${student.id}...', name: 'ClasseRepository');
          final countActiveLinks = Sqflite.firstIntValue(
            await txn.rawQuery(
              'SELECT COUNT(*) FROM classe_student WHERE student_id = ? AND active = 1',
              [student.id],
            ),
          );
          log('ClasseRepository.archiveClasseAndStudents - Aluno ${student.id} tem $countActiveLinks relações ativas restantes.', name: 'ClasseRepository');

          if (countActiveLinks == 0) {
            log('ClasseRepository.archiveClasseAndStudents - Arquivando aluno ${student.id} (sem outras turmas ativas).', name: 'ClasseRepository');
            await txn.update(
              'student',
              {'active': 0},
              where: 'id = ?',
              whereArgs: [student.id],
            );
            log('ClasseRepository.archiveClasseAndStudents - Aluno ${student.id} arquivado.', name: 'ClasseRepository');
          } else {
            log('ClasseRepository.archiveClasseAndStudents - Aluno ${student.id} mantido ativo, pois possui outras relações ativas.', name: 'ClasseRepository');
          }
        }
      });
      
      log('ClasseRepository.archiveClasseAndStudents - Método archiveClasseAndStudents concluído com sucesso. Transação finalizada.', name: 'ClasseRepository');
    } on DatabaseException catch (e) {
      log('ClasseRepository.archiveClasseAndStudents - Erro de DatabaseException na transação: $e', name: 'ClasseRepository', error: e);
      throw Exception(
        'Erro de banco de dados ao arquivar turma e alunos: ${e.toString()}',
      );
    } catch (e) {
      log('ClasseRepository.archiveClasseAndStudents - Erro desconhecido na transação: $e', name: 'ClasseRepository', error: e);
      throw Exception('Erro desconhecido ao arquivar turma e alunos: $e');
    }
  }

  @override
  Future<Classe?> getClasseDetailsById(int classeId) async {
    log('ClasseRepository.getClasseDetailsById - Iniciando busca de detalhes da turma ID: $classeId', name: 'ClasseRepository');
    
    try {
      log('ClasseRepository.getClasseDetailsById - Tentando obter o banco de dados...', name: 'ClasseRepository');
      final db = await _databaseHelper.database;
      log('ClasseRepository.getClasseDetailsById - Banco de dados obtido com sucesso.', name: 'ClasseRepository');
      
      log('ClasseRepository.getClasseDetailsById - Executando consulta para turma ID: $classeId...', name: 'ClasseRepository');
      final result = await db.query(
        'classe',
        where: 'id = ?',
        whereArgs: [classeId],
      );
      
      log('ClasseRepository.getClasseDetailsById - Consulta concluída. ${result.length} registro(s) encontrado(s).', name: 'ClasseRepository');
      
      if (result.isNotEmpty) {
        log('ClasseRepository.getClasseDetailsById - Turma encontrada: ${result.first}', name: 'ClasseRepository');
        final classe = Classe.fromMap(result.first);
        log('ClasseRepository.getClasseDetailsById - Método getClasseDetailsById concluído com sucesso. Turma processada: ${classe.toMap()}', name: 'ClasseRepository');
        return classe;
      }
      
      log('ClasseRepository.getClasseDetailsById - Nenhuma turma encontrada com o ID: $classeId. Retornando null.', name: 'ClasseRepository');
      return null;
    } on DatabaseException catch (e) {
      log('ClasseRepository.getClasseDetailsById - Erro de DatabaseException: $e', name: 'ClasseRepository', error: e);
      throw Exception(
        'Erro de banco de dados ao buscar detalhes da classe: ${e.toString()}',
      );
    } catch (e) {
      log('ClasseRepository.getClasseDetailsById - Erro desconhecido: $e', name: 'ClasseRepository', error: e);
      throw Exception('Erro desconhecido ao buscar detalhes da classe: $e');
    }
  }

  @override
  Future<List<Student>> getStudentsInClasse(
    int classeId, {
    bool activeOnly = true,
  }) async {
    log('ClasseRepository.getStudentsInClasse - Iniciando busca de alunos na turma ID: $classeId', name: 'ClasseRepository');
    log('ClasseRepository.getStudentsInClasse - Filtro: apenas alunos ativos = $activeOnly', name: 'ClasseRepository');
    
    try {
      log('ClasseRepository.getStudentsInClasse - Tentando obter o banco de dados...', name: 'ClasseRepository');
      final db = await _databaseHelper.database;
      log('ClasseRepository.getStudentsInClasse - Banco de dados obtido com sucesso.', name: 'ClasseRepository');
      
      List<String> whereClauses = [];
      List<dynamic> whereArgs = [classeId];

      whereClauses.add('cs.classe_id = ?');
      if (activeOnly) {
        whereClauses.add('cs.active = 1'); // A relação entre aluno e turma está ativa
        whereClauses.add('s.active = 1');   // O aluno em si está ativo
      }

      final whereClause = whereClauses.join(' AND ');
      log('ClasseRepository.getStudentsInClasse - Construindo WHERE: $whereClause, ARGS: $whereArgs', name: 'ClasseRepository');

      final query = '''
        SELECT s.*, cs.start_date, cs.end_date, cs.active AS classe_student_active
        FROM student s
        INNER JOIN classe_student cs ON s.id = cs.student_id
        WHERE $whereClause
        ORDER BY s.name COLLATE NOCASE;
        ''';
      
      log('ClasseRepository.getStudentsInClasse - Executando query: $query', name: 'ClasseRepository');

      final result = await db.rawQuery(query, whereArgs);
      log('ClasseRepository.getStudentsInClasse - Consulta concluída. ${result.length} aluno(s) encontrado(s).', name: 'ClasseRepository');

      final students = result.map((map) {
        // log('ClasseRepository.getStudentsInClasse - Processando aluno: ${map['name']} (ID: ${map['id']})', name: 'ClasseRepository'); // Comentar para logs menos verbosos em loop
        return Student.fromMap(map);
      }).toList();
      
      log('ClasseRepository.getStudentsInClasse - Método getStudentsInClasse concluído com sucesso. Total de alunos processados: ${students.length}.', name: 'ClasseRepository');
      return students;
    } on DatabaseException catch (e) {
      log('ClasseRepository.getStudentsInClasse - Erro de DatabaseException: $e', name: 'ClasseRepository', error: e);
      throw Exception(
        'Erro de banco de dados ao buscar alunos na classe: ${e.toString()}',
      );
    } catch (e) {
      log('ClasseRepository.getStudentsInClasse - Erro desconhecido: $e', name: 'ClasseRepository', error: e);
      throw Exception('Erro desconhecido ao buscar alunos na classe: $e');
    }
  }

  @override
  Future<List<Grade>> getClasseGrades(
    int classeId, {
    bool activeOnly = true,
  }) async {
    log('ClasseRepository.getClasseGrades - Iniciando busca de horários da turma ID: $classeId', name: 'ClasseRepository');
    log('ClasseRepository.getClasseGrades - Filtro: apenas horários ativos = $activeOnly', name: 'ClasseRepository');
    
    try {
      log('ClasseRepository.getClasseGrades - Tentando obter o banco de dados...', name: 'ClasseRepository');
      final db = await _databaseHelper.database;
      log('ClasseRepository.getClasseGrades - Banco de dados obtido com sucesso.', name: 'ClasseRepository');
      
      List<String> whereClauses = [];
      List<dynamic> whereArgs = [classeId];

      whereClauses.add('g.classe_id = ?');
      if (activeOnly) {
        whereClauses.add('g.active = 1');
      }

      final whereClause = whereClauses.join(' AND ');
      log('ClasseRepository.getClasseGrades - Construindo WHERE: $whereClause, ARGS: $whereArgs', name: 'ClasseRepository');

      final query = '''
        SELECT g.*, d.name AS discipline_name
        FROM grade g
        LEFT JOIN discipline d ON g.discipline_id = d.id
        WHERE $whereClause
        ORDER BY g.day_of_week ASC, g.start_time ASC;
        ''';
      
      log('ClasseRepository.getClasseGrades - Executando query: $query', name: 'ClasseRepository');

      final result = await db.rawQuery(query, whereArgs);
      log('ClasseRepository.getClasseGrades - Consulta concluída. ${result.length} horário(s) encontrado(s).', name: 'ClasseRepository');

      final grades = result.map((map) {
        // log('ClasseRepository.getClasseGrades - Processando horário: Dia ${map['day_of_week']}, Disciplina ${map['discipline_name']} (ID: ${map['id']})', name: 'ClasseRepository'); // Comentar para logs menos verbosos em loop
        
        final grade = Grade.fromMap(map);
        final disciplineName = map['discipline_name'] as String?;
        final result = grade.copyWith(
          discipline: disciplineName != null
              ? Discipline(id: grade.disciplineId, name: disciplineName)
              : null,
        );
        return result;
      }).toList();
      
      log('ClasseRepository.getClasseGrades - Método getClasseGrades concluído com sucesso. Total de horários processados: ${grades.length}.', name: 'ClasseRepository');
      return grades;
    } on DatabaseException catch (e) {
      log('ClasseRepository.getClasseGrades - Erro de DatabaseException: $e', name: 'ClasseRepository', error: e);
      throw Exception(
        'Erro de banco de dados ao buscar horários da classe: ${e.toString()}',
      );
    } catch (e) {
      log('ClasseRepository.getClasseGrades - Erro desconhecido: $e', name: 'ClasseRepository', error: e);
      throw Exception('Erro desconhecido ao buscar horários da classe: $e');
    }
  }
}