import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
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
        SELECT s.* FROM student s
        INNER JOIN classe_student cs ON cs.student_id = s.id
        WHERE cs.classe_id = ?
        ORDER BY s.name COLLATE NOCASE
      ''',
        [classeId],
      );
      return result.map((e) => Student.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar alunos da turma: $e');
    }
  }

  @override
  Future<void> addStudentsToClasse(List<Student> students, int classeId) async {
    try {
      final db = await _dbHelper.database;
      await db.transaction((txn) async {
        for (final student in students) {
          final existingStudentRows = await txn.query(
            'student',
            where: 'name = ?',
            whereArgs: [student.name.toLowerCase().trim()],
          );

          int studentId;
          if (existingStudentRows.isNotEmpty) {
            studentId = existingStudentRows.first['id'] as int;
          } else {
            studentId = await txn.insert('student', {
              "name": student.name.toLowerCase().trim(),
              "created_at": DateTime.now().toIso8601String(),
              "active": 1,
            });
          }

          await txn.insert('classe_student', {
            'student_id': studentId,
            'classe_id': classeId,
            'start_date': DateTime.now().toIso8601String(),
            'active': 1,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      });
    } on DatabaseException catch (e) {
      throw Exception('Erro de banco de dados ao adicionar alunos à turma: $e');
    } catch (e) {
      throw Exception('Erro desconhecido ao adicionar alunos à turma: $e');
    }
  }

  @override
  Future<void> deleteStudentFromClasse(Student student, int classeId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'classe_student',
        where: 'student_id = ? AND classe_id = ?',
        whereArgs: [student.id, classeId],
      );

      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM classe_student WHERE student_id = ?',
          [student.id],
        ),
      );
      if (count == 0) {
        await db.delete(
          'student',
          where: 'id = ?',
          whereArgs: [student.id],
        );
      }
    } catch (e) {
      throw Exception('Erro ao remover aluno da turma: $e');
    }
  }

  @override
  Future<void> updateStudent(Student student) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'student',
        student.toMap(),
        where: 'id = ?',
        whereArgs: [student.id],
      );
    } catch (e) {
      throw Exception('Erro ao atualizar aluno: $e');
    }
  }

  @override
  Future<List<Classe>> getAllClassesExcept(int excludeId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'classe',
        where: 'id != ? AND active = ?',
        whereArgs: [excludeId, 1],
        orderBy: 'name COLLATE NOCASE',
      );
      return result.map((e) => Classe.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar turmas para exclusão: $e');
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
        await txn.delete(
          'classe_student',
          where: 'student_id = ? AND classe_id = ?',
          whereArgs: [student.id, fromClasseId],
        );

        await txn.insert('classe_student', {
          'student_id': student.id,
          'classe_id': toClasseId,
          'start_date': DateTime.now().toIso8601String(),
          'active': 1,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      });
    } catch (e) {
      throw Exception('Erro ao mover aluno de turma: $e');
    }
  }

  // --- MÉTODOS DE FILTRO PARA IMPORTAÇÃO ---

  @override
  Future<List<int>> getAvailableYears({bool? activeStatus}) async {
    try {
      final db = await _dbHelper.database;
      String query = 'SELECT DISTINCT c.school_year FROM classe c '
                     'INNER JOIN classe_student cs ON c.id = cs.classe_id ' // Garante que a turma tem alunos
                     'WHERE cs.active = 1 '; // Vínculo ativo

      List<dynamic> args = [];

      if (activeStatus != null) {
        query += ' AND c.active = ?';
        args.add(activeStatus ? 1 : 0);
      }
      query += ' ORDER BY c.school_year DESC';

      final result = await db.rawQuery(query, args);
      return result.map((map) => map['school_year'] as int).toList();
    } catch (e) {
      throw Exception('Erro ao buscar anos disponíveis: $e');
    }
  }

  @override
  Future<List<Classe>> getClassesByStatusAndYear({
    bool? activeStatus,
    int? year,
  }) async {
    try {
      final db = await _dbHelper.database;
      String whereClause = 'c.id IN (SELECT classe_id FROM classe_student WHERE active = 1)'; // Apenas turmas com alunos ativos
      List<dynamic> whereArgs = [];

      if (activeStatus != null) {
        whereClause += ' AND c.active = ?';
        whereArgs.add(activeStatus ? 1 : 0);
      }

      if (year != null) {
        whereClause += ' AND c.school_year = ?';
        whereArgs.add(year);
      }
      
      // Use um alias 'c' para a tabela classe
      final result = await db.query(
        'classe c',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'c.name COLLATE NOCASE',
      );
      return result.map((map) => Classe.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar turmas por status e ano: $e');
    }
  }
}