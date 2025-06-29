import 'dart:developer'; // Adicione este import
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
    log('AttendanceSelectRepository.getAllGradesForSelection - Iniciando busca de horários para seleção.', name: 'AttendanceSelectRepository');
    log('AttendanceSelectRepository.getAllGradesForSelection - Filtros: classeId=$classeId, disciplineId=$disciplineId, dayOfWeek=$dayOfWeek, activeStatus=$activeStatus, year=$year', name: 'AttendanceSelectRepository');

    try {
      log('AttendanceSelectRepository.getAllGradesForSelection - Obtendo instância do banco de dados.', name: 'AttendanceSelectRepository');
      final db = await _dbHelper.database;
      log('AttendanceSelectRepository.getAllGradesForSelection - Banco de dados obtido.', name: 'AttendanceSelectRepository');

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
        log('AttendanceSelectRepository.getAllGradesForSelection - Adicionado filtro por classeId: $classeId', name: 'AttendanceSelectRepository');
      }
      if (disciplineId != null) {
        query += ' AND g.discipline_id = ?';
        whereArgs.add(disciplineId);
        log('AttendanceSelectRepository.getAllGradesForSelection - Adicionado filtro por disciplineId: $disciplineId', name: 'AttendanceSelectRepository');
      }
      if (dayOfWeek != null) {
        query += ' AND g.day_of_week = ?';
        whereArgs.add(dayOfWeek);
        log('AttendanceSelectRepository.getAllGradesForSelection - Adicionado filtro por dayOfWeek: $dayOfWeek', name: 'AttendanceSelectRepository');
      }
      if (activeStatus != null) {
        query += ' AND g.active = ?';
        whereArgs.add(activeStatus ? 1 : 0);
        log('AttendanceSelectRepository.getAllGradesForSelection - Adicionado filtro por activeStatus: $activeStatus', name: 'AttendanceSelectRepository');
      }
      if (year != null) {
        query += ' AND g.grade_year = ?';
        whereArgs.add(year);
        log('AttendanceSelectRepository.getAllGradesForSelection - Adicionado filtro por year: $year', name: 'AttendanceSelectRepository');
      }

      query += ' AND c.active = 1 '; // Sempre filtra por classes ativas para seleção
      query += ' ORDER BY g.day_of_week, g.start_time, c.name COLLATE NOCASE';

      log('AttendanceSelectRepository.getAllGradesForSelection - Query SQL final: $query', name: 'AttendanceSelectRepository');
      log('AttendanceSelectRepository.getAllGradesForSelection - Argumentos da query: $whereArgs', name: 'AttendanceSelectRepository');
      
      final result = await db.rawQuery(query, whereArgs);
      log('AttendanceSelectRepository.getAllGradesForSelection - Consulta concluída. ${result.length} horários encontrados.', name: 'AttendanceSelectRepository');

      final grades = result.map((map) {
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

      log('AttendanceSelectRepository.getAllGradesForSelection - ${grades.length} horários processados e retornados com sucesso.', name: 'AttendanceSelectRepository');
      return grades;
    } on DatabaseException catch (e, s) { // Captura a exceção e o stack trace
      log('AttendanceSelectRepository.getAllGradesForSelection - Erro de banco de dados: $e', name: 'AttendanceSelectRepository', error: e, stackTrace: s); // Loga com stack trace
      throw Exception(
        'Erro de banco de dados ao buscar horários para seleção: ${e.toString()}',
      );
    } catch (e, s) { // Captura a exceção e o stack trace
      log('AttendanceSelectRepository.getAllGradesForSelection - Erro desconhecido: $e', name: 'AttendanceSelectRepository', error: e, stackTrace: s); // Loga com stack trace
      throw Exception('Erro desconhecido ao buscar horários para seleção: $e');
    }
  }

  @override // Métodos do IAttendanceSelectRepository devem ser marcados com @override
  Future<bool> hasAttendanceForGradeAndDate(int gradeId, DateTime date) async {
    log('AttendanceSelectRepository.hasAttendanceForGradeAndDate - Verificando existência de chamada para gradeId: $gradeId na data: ${DateFormat('yyyy-MM-dd').format(date)}', name: 'AttendanceSelectRepository');
    try {
      log('AttendanceSelectRepository.hasAttendanceForGradeAndDate - Obtendo instância do banco de dados.', name: 'AttendanceSelectRepository');
      final db = await _dbHelper.database;
      log('AttendanceSelectRepository.hasAttendanceForGradeAndDate - Banco de dados obtido.', name: 'AttendanceSelectRepository');

      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      
      log('AttendanceSelectRepository.hasAttendanceForGradeAndDate - Executando consulta para verificar chamada existente.', name: 'AttendanceSelectRepository');
      final result = await db.query(
        'attendance',
        columns: ['id'],
        where: 'grade_id = ? AND date = ?',
        whereArgs: [gradeId, formattedDate],
        limit: 1,
      );
      
      final exists = result.isNotEmpty;
      log('AttendanceSelectRepository.hasAttendanceForGradeAndDate - Chamada existente: $exists. Consulta concluída.', name: 'AttendanceSelectRepository');
      return exists;
    } on DatabaseException catch (e, s) { // Captura a exceção e o stack trace
      log('AttendanceSelectRepository.hasAttendanceForGradeAndDate - Erro de banco de dados: $e', name: 'AttendanceSelectRepository', error: e, stackTrace: s); // Loga com stack trace
      throw Exception(
        'Erro de banco de dados ao verificar chamada existente: ${e.toString()}',
      );
    } catch (e, s) { // Captura a exceção e o stack trace
      log('AttendanceSelectRepository.hasAttendanceForGradeAndDate - Erro desconhecido: $e', name: 'AttendanceSelectRepository', error: e, stackTrace: s); // Loga com stack trace
      throw Exception('Erro desconhecido ao verificar chamada existente: $e');
    }
  }

  @override
  Future<List<Discipline>> getAllActiveDisciplines() async {
    log('AttendanceSelectRepository.getAllActiveDisciplines - Iniciando busca de todas as disciplinas ativas.', name: 'AttendanceSelectRepository');
    try {
      log('AttendanceSelectRepository.getAllActiveDisciplines - Obtendo instância do banco de dados.', name: 'AttendanceSelectRepository');
      final db = await _dbHelper.database;
      log('AttendanceSelectRepository.getAllActiveDisciplines - Banco de dados obtido.', name: 'AttendanceSelectRepository');

      log('AttendanceSelectRepository.getAllActiveDisciplines - Executando consulta por disciplinas ativas.', name: 'AttendanceSelectRepository');
      final result = await db.query(
        'discipline',
        where: 'active = ?',
        whereArgs: [1],
        orderBy: 'name COLLATE NOCASE',
      );
      log('AttendanceSelectRepository.getAllActiveDisciplines - Consulta concluída. ${result.length} disciplinas ativas encontradas.', name: 'AttendanceSelectRepository');
      
      final disciplines = result.map((map) => Discipline.fromMap(map)).toList();
      log('AttendanceSelectRepository.getAllActiveDisciplines - ${disciplines.length} disciplinas ativas processadas e retornadas com sucesso.', name: 'AttendanceSelectRepository');
      return disciplines;
    } on DatabaseException catch (e, s) { // Captura a exceção e o stack trace
      log('AttendanceSelectRepository.getAllActiveDisciplines - Erro de banco de dados: $e', name: 'AttendanceSelectRepository', error: e, stackTrace: s); // Loga com stack trace
      throw Exception(
        'Erro de banco de dados ao buscar disciplinas ativas: ${e.toString()}',
      );
    } catch (e, s) { // Captura a exceção e o stack trace
      log('AttendanceSelectRepository.getAllActiveDisciplines - Erro desconhecido: $e', name: 'AttendanceSelectRepository', error: e, stackTrace: s); // Loga com stack trace
      throw Exception('Erro desconhecido ao buscar disciplinas ativas: $e');
    }
  }

  @override
  Future<List<Classe>> getAllActiveClasses() async {
    log('AttendanceSelectRepository.getAllActiveClasses - Iniciando busca de todas as classes ativas.', name: 'AttendanceSelectRepository');
    try {
      log('AttendanceSelectRepository.getAllActiveClasses - Obtendo instância do banco de dados.', name: 'AttendanceSelectRepository');
      final db = await _dbHelper.database;
      log('AttendanceSelectRepository.getAllActiveClasses - Banco de dados obtido.', name: 'AttendanceSelectRepository');

      log('AttendanceSelectRepository.getAllActiveClasses - Executando consulta por classes ativas.', name: 'AttendanceSelectRepository');
      final result = await db.query(
        'classe',
        where: 'active = ?',
        whereArgs: [1],
        orderBy: 'name COLLATE NOCASE',
      );
      log('AttendanceSelectRepository.getAllActiveClasses - Consulta concluída. ${result.length} classes ativas encontradas.', name: 'AttendanceSelectRepository');
      
      final classes = result.map((map) => Classe.fromMap(map)).toList();
      log('AttendanceSelectRepository.getAllActiveClasses - ${classes.length} classes ativas processadas e retornadas com sucesso.', name: 'AttendanceSelectRepository');
      return classes;
    } on DatabaseException catch (e, s) { // Captura a exceção e o stack trace
      log('AttendanceSelectRepository.getAllActiveClasses - Erro de banco de dados: $e', name: 'AttendanceSelectRepository', error: e, stackTrace: s); // Loga com stack trace
      throw Exception(
        'Erro de banco de dados ao buscar classes ativas: ${e.toString()}',
      );
    } catch (e, s) { // Captura a exceção e o stack trace
      log('AttendanceSelectRepository.getAllActiveClasses - Erro desconhecido: $e', name: 'AttendanceSelectRepository', error: e, stackTrace: s); // Loga com stack trace
      throw Exception('Erro desconhecido ao buscar classes ativas: $e');
    }
  }
}