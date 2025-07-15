// app/repositories/classes/classes_repository.dart

import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/schedule.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/repositories/classes/i_classes_repository.dart';

class ClasseRepository implements IClasseRepository {
  final DatabaseHelper _databaseHelper;

  ClasseRepository(this._databaseHelper);

  @override
  Future<Classe> createClasse(Classe classe) async {
    try {
      final db = await _databaseHelper.database;

      final existing = await db.query(
        'classe',
        where: 'LOWER(name) = ? AND school_year = ? AND active = 1',
        whereArgs: [classe.name.toLowerCase(), classe.schoolYear],
      );

      if (existing.isNotEmpty) {
        throw ('Já existe uma turma ATIVA com esse nome para o ano ${classe.schoolYear}!');
      }

      final dataToInsert = {
        'name': classe.name.toLowerCase(),
        'description': classe.description,
        'school_year': classe.schoolYear,
        'created_at': classe.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'active': (classe.active ?? true) ? 1 : 0,
      };

      final id = await db.insert('classe', dataToInsert, conflictAlgorithm: ConflictAlgorithm.abort);
      
      final result = Classe(
        id: id,
        name: classe.name,
        description: classe.description,
        schoolYear: classe.schoolYear,
        createdAt: classe.createdAt ?? DateTime.now(),
        active: classe.active,
      );

      return result;
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw ('Já existe uma turma com esse nome para o ano ${classe.schoolYear}!');
      } else {
        throw ('Erro de banco de dados ao criar turma: ${e.toString()}');
      }
    } catch (e) {
      throw ('Erro desconhecido ao criar turma: $e');
    }
  }

  @override
  Future<List<Classe>> readClasses({bool? active, int? year}) async {
    try {
      final db = await _databaseHelper.database;
      
      final currentYear = DateTime.now().year;
      final effectiveYear = year ?? currentYear;
      final effectiveActive = active;
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      // Sempre filtra por ano
      whereClause += "school_year = ?";
      whereArgs.add(effectiveYear);
      
      if (effectiveActive != null) {
        whereClause += " AND active = ?";
        whereArgs.add(effectiveActive ? 1 : 0);
      }

      final result = await db.query(
        'classe',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'name ASC',
      );
      
      final classes = result.map((map) {
        return Classe.fromMap(map);
      }).toList();
      
      return classes;
    } on DatabaseException catch (e) {
      if (e.isNoSuchTableError('classe')) {
        throw ('Tabela de turmas não encontrada ao tentar ler!|$e');
      } else if (e.isSyntaxError()) {
        throw ('Erro de sintaxe ao buscar turmas!|$e');
      }
      throw ('Erro ao buscar as turmas: $e');
    } catch (e) {
      throw ('Erro desconhecido ao buscar classes: $e');
    }
  }

  @override
  Future<void> updateClasse(Classe classe) async {
    try {
      
      
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw ('Já existe uma turma com esse nome para o ano ${classe.schoolYear}!');
      }
      throw ('Erro de banco de dados ao atualizar turma: ${e.toString()}');
    } catch (e) {
      throw ('Erro desconhecido ao atualizar turma: $e');
    }
  }

  @override
  Future<void> archiveClasseAndStudents(Classe classe) async {
    if (classe.id == null) {
      throw Exception('ID da classe é nulo, não foi possível arquivar.');
    }
    if (!(classe.active ?? true)) {
      return;
    }

    try {
      final db = await _databaseHelper.database;
      
      await db.transaction((txn) async {
        await txn.update(
          'classe',
          {'active': 0},
          where: 'id = ?',
          whereArgs: [classe.id],
        );

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

        for (final student in studentsInClasse) {
          await txn.update(
            'classe_student',
            {'active': 0, 'end_date': DateTime.now().toIso8601String()},
            where: 'student_id = ? AND classe_id = ?',
            whereArgs: [student.id, classe.id],
          );

          final countActiveLinks = Sqflite.firstIntValue(
            await txn.rawQuery(
              'SELECT COUNT(*) FROM classe_student WHERE student_id = ? AND active = 1',
              [student.id],
            ),
          );

          if (countActiveLinks == 0) {
            await txn.update(
              'student',
              {'active': 0},
              where: 'id = ?',
              whereArgs: [student.id],
            );
          }
        }
      });
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao arquivar turma e alunos: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao arquivar turma e alunos: $e');
    }
  }

  @override
  Future<Classe?> getClasseDetailsById(int classeId) async {
    try {
      final db = await _databaseHelper.database;
      
      final result = await db.query(
        'classe',
        where: 'id = ?',
        whereArgs: [classeId],
      );
      
      if (result.isNotEmpty) {
        final classe = Classe.fromMap(result.first);
        return classe;
      }
      
      return null;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar detalhes da classe: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar detalhes da classe: $e');
    }
  }

  @override
  Future<List<Student>> getStudentsInClasse(
    int classeId, {
    bool activeOnly = true,
  }) async {
    try {
      final db = await _databaseHelper.database;
      
      List<String> whereClauses = [];
      List<dynamic> whereArgs = [classeId];

      whereClauses.add('cs.classe_id = ?');
      if (activeOnly) {
        whereClauses.add('cs.active = 1'); // A relação entre aluno e turma está ativa
        whereClauses.add('s.active = 1');   // O aluno em si está ativo
      }

      final whereClause = whereClauses.join(' AND ');

      final query = '''
        SELECT s.*
        FROM student s
        INNER JOIN classe_student cs ON s.id = cs.student_id
        WHERE $whereClause
        ORDER BY s.name COLLATE NOCASE;
        ''';

      final result = await db.rawQuery(query, whereArgs);

      final students = result.map((map) {
        return Student.fromMap(map);
      }).toList();
      
      return students;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar alunos na classe: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar alunos na classe: $e');
    }
  }

  @override
  Future<List<Schedule>> getClasseSchedules(
    int classeId, {
    bool activeOnly = true,
  }) async {
    try {
      final db = await _databaseHelper.database;
      
      List<String> whereClauses = [];
      List<dynamic> whereArgs = [classeId];

      whereClauses.add('s.classe_id = ?');
      if (activeOnly) {
        whereClauses.add('s.active = 1');
      }

      final whereClause = whereClauses.join(' AND ');

      final query = '''
        SELECT s.*, d.name AS discipline_name
        FROM schedule s
        LEFT JOIN discipline d ON s.discipline_id = d.id
        WHERE $whereClause
        ORDER BY s.day_of_week ASC, s.start_time ASC;
        ''';

      final result = await db.rawQuery(query, whereArgs);

      final schedules = result.map((map) {
        final schedule = Schedule.fromMap(map);
        final disciplineName = map['discipline_name'] as String?;
        final result = schedule.copyWith(
          discipline: disciplineName != null
              ? Discipline(id: schedule.disciplineId, name: disciplineName)
              : null,
        );
        return result;
      }).toList();
      
      return schedules;
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar horários da classe: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar horários da classe: $e');
    }
  }
}