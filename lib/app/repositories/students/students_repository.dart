import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/repositories/students/i_students_repository.dart';

class StudentsRepository implements IStudentsRepository {
  final DatabaseHelper _dbHelper;

  StudentsRepository(this._dbHelper);

  @override
  Future<List<Student>> getStudentsByClasseId(int classeId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT s.*
        FROM student s
        INNER JOIN classe_student cs ON cs.student_id = s.id
        WHERE cs.classe_id = ? AND cs.active = 1
        ORDER BY s.name COLLATE NOCASE
        ''',
        [classeId],
      );
      return result.map((e) => Student.fromMap(e)).toList();
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar alunos da turma: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar alunos da turma: $e');
    }
  }

  @override
  Future<void> createAndAddStudentsToClasse(List<Student> students, int classeId) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        for (final student in students) {
          int studentId;

          if (student.id != null) {
            final existingById = await txn.query(
              'student',
              where: 'id = ?',
              whereArgs: [student.id],
            );
            if (existingById.isNotEmpty) {
              studentId = existingById.first['id'] as int;
            } else {
              studentId = await txn.insert('student', {
                "name": student.name.trim(),
                "created_at": DateTime.now().toIso8601String(),
                "active": 1,
              });
            }
          } else {
            studentId = await txn.insert('student', {
              "name": student.name.trim(),
              "created_at": DateTime.now().toIso8601String(),
              "active": 1,
            });
          }

          await txn.update(
            'student',
            {'active': 1},
            where: 'id = ?',
            whereArgs: [studentId],
          );

          int updated = await txn.update(
            'classe_student',
            {
              'active': 1,
              'start_date': DateTime.now().toIso8601String(),
              'end_date': null,
            },
            where: 'student_id = ? AND classe_id = ?',
            whereArgs: [studentId, classeId],
          );
          if (updated == 0) {
            await txn.insert('classe_student', {
              'student_id': studentId,
              'classe_id': classeId,
              'start_date': DateTime.now().toIso8601String(),
              'active': 1,
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
      });
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao adicionar alunos à turma: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao adicionar alunos à turma: $e');
    }
  }

  @override
  Future<void> removeStudentFromClasse(Student student, int classeId) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        await txn.update(
          'classe_student',
          {'active': 0, 'end_date': DateTime.now().toIso8601String()},
          where: 'student_id = ? AND classe_id = ?',
          whereArgs: [student.id, classeId],
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
      });
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao remover aluno da turma: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao remover aluno da turma: $e');
    }
  }

  @override
  Future<void> updateStudent(Student student) async {
    try {
      final db = await _dbHelper.database;
      final Map<String, dynamic> studentData = student.toMap();
      studentData.remove('id');
      await db.update(
        'student',
        studentData,
        where: 'id = ?',
        whereArgs: [student.id],
      );
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao atualizar aluno: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao atualizar aluno: $e');
    }
  }

  @override
  Future<List<Classe>> getAllClassesExcept(int excludeId, {int? year}) async {
    try {
      final db = await _dbHelper.database;
      int yearToUse = year ?? DateTime.now().year;
      final result = await db.query(
        'classe c',
        where: 'c.id != ? AND c.active = 1 AND c.school_year = ?',
        whereArgs: [excludeId, yearToUse],
        orderBy: 'c.name COLLATE NOCASE',
      );
      return result.map((e) => Classe.fromMap(e)).toList();
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar turmas para exclusão: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar turmas para exclusão: $e');
    }
  }

  @override
  Future<void> moveStudentToClasse(
    Student student,
    int fromClasseId,
    int toClasseId,
  ) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        await txn.update(
          'classe_student',
          {'active': 0, 'end_date': DateTime.now().toIso8601String()},
          where: 'student_id = ? AND classe_id = ?',
          whereArgs: [student.id, fromClasseId],
        );

        int updated = await txn.update(
          'classe_student',
          {
            'active': 1,
            'start_date': DateTime.now().toIso8601String(),
            'end_date': null,
          },
          where: 'student_id = ? AND classe_id = ?',
          whereArgs: [student.id, toClasseId],
        );

        if (updated == 0) {
          await txn.insert('classe_student', {
            'student_id': student.id,
            'classe_id': toClasseId,
            'start_date': DateTime.now().toIso8601String(),
            'active': 1,
          });
        }

        await txn.update(
          'student',
          {'active': 1},
          where: 'id = ?',
          whereArgs: [student.id],
        );
      });
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao mover aluno de turma: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao mover aluno de turma: $e');
    }
  }

  @override
  Future<List<int>> getAvailableYears({bool? activeStatus}) async {
    try {
      final db = await _dbHelper.database;
      String query =
          'SELECT DISTINCT c.school_year FROM classe c '
          'INNER JOIN classe_student cs ON c.id = cs.classe_id '
          'INNER JOIN student s ON cs.student_id = s.id ';
      List<dynamic> args = [];
      List<String> conditions = [];
      conditions.add('cs.active = 1');
      conditions.add('s.active = 1');
      if (activeStatus != null) {
        conditions.add('c.active = ?');
        args.add(activeStatus ? 1 : 0);
      }
      if (conditions.isNotEmpty) {
        query += ' WHERE ${conditions.join(' AND ')}';
      }
      query += ' ORDER BY c.school_year DESC';
      final result = await db.rawQuery(query, args);
      return result.map((map) => map['school_year'] as int).toList();
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar anos disponíveis: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar anos disponíveis: $e');
    }
  }

  @override
  Future<List<Classe>> getClassesByStatusAndYear({
    bool? activeStatus,
    int? year,
  }) async {
    try {
      final db = await _dbHelper.database;
      List<String> whereClauses = [];
      List<dynamic> whereArgs = [];
      whereClauses.add(
        'c.id IN (SELECT classe_id FROM classe_student cs INNER JOIN student s ON cs.student_id = s.id WHERE cs.active = 1 AND s.active = 1)',
      );
      if (activeStatus != null) {
        whereClauses.add('c.active = ?');
        whereArgs.add(activeStatus ? 1 : 0);
      }
      if (year != null) {
        whereClauses.add('c.school_year = ?');
        whereArgs.add(year);
      }
      final result = await db.query(
        'classe c',
        where: whereClauses.join(' AND '),
        whereArgs: whereArgs,
        orderBy: 'c.name COLLATE NOCASE',
      );
      return result.map((map) => Classe.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao buscar turmas por status e ano: ${e.toString()}',
      );
    } catch (e) {
      throw Exception(
        'Erro desconhecido ao buscar turmas por status e ano: $e',
      );
    }
  }

  @override
  Future<void> duplicateStudentToClasse(Student student, int toClasseId) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        await txn.update(
          'student',
          {'active': 1},
          where: 'id = ?',
          whereArgs: [student.id],
        );

        int updated = await txn.update(
          'classe_student',
          {
            'active': 1,
            'start_date': DateTime.now().toIso8601String(),
            'end_date': null,
          },
          where: 'student_id = ? AND classe_id = ?',
          whereArgs: [student.id, toClasseId],
        );

        if (updated == 0) {
          await txn.insert('classe_student', {
            'student_id': student.id,
            'classe_id': toClasseId,
            'start_date': DateTime.now().toIso8601String(),
            'active': 1,
          });
        }
      });
    } on DatabaseException catch (e) {
      throw Exception(
        'Erro de banco de dados ao duplicar aluno para turma: ${e.toString()}',
      );
    } catch (e) {
      throw Exception('Erro desconhecido ao duplicar aluno para turma: $e');
    }
  }
}