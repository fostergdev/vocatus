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
    log('GradeRepository.createGrade - Iniciando criação de horário: ${grade.toMap()}');
    try {
      final db = await _dbHelper.database;
      log('GradeRepository.createGrade - Banco de dados obtido com sucesso');
      
      final gradeMap = grade.toMap();
      log('GradeRepository.createGrade - Dados para inserção: $gradeMap');
      
      final id = await db.insert(
        'grade',
        gradeMap,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      log('GradeRepository.createGrade - Horário criado com sucesso. ID: $id');
      
      final result = grade.copyWith(id: id);
      log('GradeRepository.createGrade - Resultado final: ${result.toMap()}');
      return result;
    } on DatabaseException catch (e, stackTrace) {
      log('GradeRepository.createGrade - Erro de banco de dados: $e');
      log('GradeRepository.createGrade - StackTrace: $stackTrace');
      if (e.toString().contains('UNIQUE constraint failed')) {
        log('GradeRepository.createGrade - Erro de constraint UNIQUE detectado');
        throw Exception(
          'Já existe um horário agendado idêntico para esta turma, dia e hora. (DB UNIQUE)',
        );
      }
      throw Exception(
        'Erro de banco de dados ao criar horário: ${e.toString()}',
      );
    } catch (e, stackTrace) {
      log('GradeRepository.createGrade - Erro desconhecido: $e');
      log('GradeRepository.createGrade - StackTrace: $stackTrace');
      throw Exception('Erro desconhecido ao criar horário: $e');
    }
  }

  @override
  Future<List<Grade>> getGradesByClasseId(int classeId) async {
    log('GradeRepository.getGradesByClasseId - Iniciando busca por classeId: $classeId');
    try {
      final db = await _dbHelper.database;
      log('GradeRepository.getGradesByClasseId - Banco de dados obtido');
      
      final query = '''
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
      ''';
      
      log('GradeRepository.getGradesByClasseId - Executando query: $query com args: [$classeId]');
      
      final result = await db.rawQuery(query, [classeId]);
      log('GradeRepository.getGradesByClasseId - Resultado da query: ${result.length} registros encontrados');
      
      if (result.isNotEmpty) {
        log('GradeRepository.getGradesByClasseId - Primeiro registro: ${result.first}');
      }

      final grades = result.map((map) {
        log('GradeRepository.getGradesByClasseId - Processando registro: $map');
        
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

        final grade = Grade.fromMap(map).copyWith(
          discipline: map['discipline_id'] != null
              ? Discipline.fromMap(disciplineMap)
              : null,
          classe: Classe.fromMap(classeMap),
        );
        
        log('GradeRepository.getGradesByClasseId - Grade processado: ${grade.toMap()}');
        return grade;
      }).toList();
      
      log('GradeRepository.getGradesByClasseId - Total de grades processados: ${grades.length}');
      return grades;
    } on DatabaseException catch (e) {
      log('GradeRepository.getGradesByClasseId - Erro de banco: $e');
      throw Exception(
        'Erro de banco de dados ao buscar horários da turma: ${e.toString()}',
      );
    } catch (e) {
      log('GradeRepository.getGradesByClasseId - Erro desconhecido: $e');
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
    log('GradeRepository.getAllGrades - Iniciando busca com filtros:');
    log('  classeId: $classeId');
    log('  disciplineId: $disciplineId'); 
    log('  dayOfWeek: $dayOfWeek');
    log('  activeStatus: $activeStatus');
    log('  year: $year');
    
    try {
      final db = await _dbHelper.database;
      log('GradeRepository.getAllGrades - Banco de dados obtido');
      
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
        log('GradeRepository.getAllGrades - Adicionado filtro classeId: $classeId');
      }
      if (disciplineId != null) {
        query += ' AND g.discipline_id = ?';
        whereArgs.add(disciplineId);
        log('GradeRepository.getAllGrades - Adicionado filtro disciplineId: $disciplineId');
      }
      if (dayOfWeek != null) {
        query += ' AND g.day_of_week = ?';
        whereArgs.add(dayOfWeek);
        log('GradeRepository.getAllGrades - Adicionado filtro dayOfWeek: $dayOfWeek');
      }
      if (activeStatus != null) {
        query += ' AND g.active = ?';
        whereArgs.add(activeStatus ? 1 : 0);
        log('GradeRepository.getAllGrades - Adicionado filtro activeStatus: ${activeStatus ? 1 : 0}');
      }
      if (year != null) {
        query += ' AND c.school_year = ?';
        whereArgs.add(year);
        log('GradeRepository.getAllGrades - Adicionado filtro year: $year');
      }

      query += ' AND c.active = 1 ';
      query += ' ORDER BY g.day_of_week, g.start_time, c.name COLLATE NOCASE';

      log('GradeRepository.getAllGrades - Query final: $query');
      log('GradeRepository.getAllGrades - Argumentos: $whereArgs');

      final result = await db.rawQuery(query, whereArgs);
      log('GradeRepository.getAllGrades - Resultado: ${result.length} registros encontrados');
      
      if (result.isNotEmpty) {
        log('GradeRepository.getAllGrades - Primeiro registro: ${result.first}');
      }

      final grades = result.map((map) {
        log('GradeRepository.getAllGrades - Processando registro ID: ${map['id']}');
        
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

        final grade = Grade.fromMap(map).copyWith(
          discipline: map['discipline_id'] != null
              ? Discipline.fromMap(disciplineMap)
              : null,
          classe: Classe.fromMap(classeMap),
        );
        
        log('GradeRepository.getAllGrades - Grade processado: Turma ${grade.classe?.name}, Dia ${grade.dayOfWeek}, ${grade.startTimeOfDay} - ${grade.endTimeOfDay}');
        return grade;
      }).toList();
      
      log('GradeRepository.getAllGrades - Total de grades processados: ${grades.length}');
      return grades;
    } on DatabaseException catch (e) {
      log('GradeRepository.getAllGrades - Erro de banco: $e');
      throw Exception(
        'Erro de banco de dados ao buscar todos os horários: ${e.toString()}',
      );
    } catch (e) {
      log('GradeRepository.getAllGrades - Erro desconhecido: $e');
      throw Exception('Erro desconhecido ao buscar todos os horários: $e');
    }
  }

  @override
  Future<void> updateGrade(Grade grade) async {
    log('GradeRepository.updateGrade - Iniciando atualização do horário ID: ${grade.id}');
    log('GradeRepository.updateGrade - Dados para atualização: ${grade.toMap()}');
    
    try {
      final db = await _dbHelper.database;
      log('GradeRepository.updateGrade - Banco de dados obtido');
      
      final gradeMap = grade.toMap();
      log('GradeRepository.updateGrade - Map para atualização: $gradeMap');
      
      final rowsAffected = await db.update(
        'grade',
        gradeMap,
        where: 'id = ?',
        whereArgs: [grade.id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      
      log('GradeRepository.updateGrade - Linhas afetadas: $rowsAffected');
      
      if (rowsAffected == 0) {
        log('GradeRepository.updateGrade - Nenhuma linha foi afetada - horário não encontrado');
        throw Exception('Horário não encontrado para atualização.');
      }
      
      log('GradeRepository.updateGrade - Atualização concluída com sucesso');
    } on DatabaseException catch (e) {
      log('GradeRepository.updateGrade - Erro de banco: $e');
      if (e.toString().contains('UNIQUE constraint failed')) {
        log('GradeRepository.updateGrade - Erro de constraint UNIQUE detectado');
        throw Exception(
          'Já existe um horário agendado idêntico para esta turma, dia e hora.',
        );
      }
      throw Exception(
        'Erro de banco de dados ao atualizar horário: ${e.toString()}',
      );
    } catch (e) {
      log('GradeRepository.updateGrade - Erro desconhecido: $e');
      throw Exception('Erro desconhecido ao atualizar horário: $e');
    }
  }

  @override
  Future<void> toggleGradeActiveStatus(Grade grade) async {
    log('GradeRepository.toggleGradeActiveStatus - Iniciando mudança de status do horário ID: ${grade.id}');
    log('GradeRepository.toggleGradeActiveStatus - Status atual: ${grade.active}');
    
    try {
      final db = await _dbHelper.database;
      log('GradeRepository.toggleGradeActiveStatus - Banco de dados obtido');
      
      final newStatus = (grade.active ?? true) ? 0 : 1;
      log('GradeRepository.toggleGradeActiveStatus - Novo status: $newStatus');
      
      final rowsAffected = await db.update(
        'grade',
        {'active': newStatus},
        where: 'id = ?',
        whereArgs: [grade.id],
      );
      
      log('GradeRepository.toggleGradeActiveStatus - Linhas afetadas: $rowsAffected');
      
      if (rowsAffected == 0) {
        log('GradeRepository.toggleGradeActiveStatus - Nenhuma linha foi afetada - horário não encontrado');
        throw Exception('Horário não encontrado para mudança de status.');
      }
      
      log('GradeRepository.toggleGradeActiveStatus - Status alterado com sucesso');
    } on DatabaseException catch (e) {
      log('GradeRepository.toggleGradeActiveStatus - Erro de banco: $e');
      throw Exception(
        'Erro de banco de dados ao mudar status do horário: ${e.toString()}',
      );
    } catch (e) {
      log('GradeRepository.toggleGradeActiveStatus - Erro desconhecido: $e');
      throw Exception('Erro desconhecido ao mudar status do horário: $e');
    }
  }

  @override
  Future<List<Discipline>> getAllDisciplines() async {
    log('GradeRepository.getAllDisciplines - Iniciando busca por disciplinas');
    
    try {
      final db = await _dbHelper.database;
      log('GradeRepository.getAllDisciplines - Banco de dados obtido');
      
      final result = await db.query(
        'discipline',
        where: 'active = ?',
        whereArgs: [1],
        orderBy: 'name COLLATE NOCASE',
      );
      
      log('GradeRepository.getAllDisciplines - ${result.length} disciplinas encontradas');
      
      final disciplines = result.map((map) {
        log('GradeRepository.getAllDisciplines - Processando disciplina: ${map['name']}');
        return Discipline.fromMap(map);
      }).toList();
      
      log('GradeRepository.getAllDisciplines - Total de disciplinas processadas: ${disciplines.length}');
      return disciplines;
    } on DatabaseException catch (e) {
      log('GradeRepository.getAllDisciplines - Erro de banco: $e');
      throw Exception(
        'Erro de banco de dados ao buscar disciplinas: ${e.toString()}',
      );
    } catch (e) {
      log('GradeRepository.getAllDisciplines - Erro desconhecido: $e');
      throw Exception('Erro desconhecido ao buscar disciplinas: $e');
    }
  }

  @override
  Future<List<Classe>> getAllActiveClasses([int? year]) async {
    log('GradeRepository.getAllActiveClasses - Iniciando busca por turmas ativas');
    log('GradeRepository.getAllActiveClasses - Filtro por ano: $year');
    
    try {
      final db = await _dbHelper.database;
      log('GradeRepository.getAllActiveClasses - Banco de dados obtido');
      
      String where = 'active = ?';
      List<dynamic> whereArgs = [1];

      if (year != null) {
        where += ' AND school_year = ?';
        whereArgs.add(year);
        log('GradeRepository.getAllActiveClasses - Adicionado filtro de ano: $year');
      }

      log('GradeRepository.getAllActiveClasses - WHERE: $where, ARGS: $whereArgs');

      final result = await db.query(
        'classe',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'name COLLATE NOCASE',
      );

      log('GradeRepository.getAllActiveClasses - ${result.length} turmas encontradas');
      
      final classes = result.map((map) {
        log('GradeRepository.getAllActiveClasses - Processando turma: ${map['name']} (${map['school_year']})');
        return Classe.fromMap(map);
      }).toList();
      
      log('GradeRepository.getAllActiveClasses - Total de turmas processadas: ${classes.length}');
      return classes;
    } on DatabaseException catch (e) {
      log('GradeRepository.getAllActiveClasses - Erro de banco: $e');
      throw Exception(
        'Erro de banco de dados ao buscar classes ativas: ${e.toString()}',
      );
    } catch (e) {
      log('GradeRepository.getAllActiveClasses - Erro desconhecido: $e');
      throw Exception('Erro desconhecido ao buscar classes ativas: $e');
    }
  }

  @override
  Future<void> deleteGrade(int gradeId) {
    log('GradeRepository.deleteGrade - Método não implementado. ID solicitado: $gradeId');
    throw UnimplementedError();
  }
}
