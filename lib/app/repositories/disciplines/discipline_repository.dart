import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/repositories/disciplines/i_discipline_repository.dart';

class DisciplineRepository implements IDisciplineRepository {
  final DatabaseHelper _databaseHelper;

  DisciplineRepository(this._databaseHelper);

  @override
  Future<Discipline> createDiscipline(Discipline discipline) async {
    try {
      final db = await _databaseHelper.database;
      final id = await db.insert(
        'discipline',
        {'name': discipline.name.toLowerCase().trim()},
      );
      return Discipline(
        id: id,
        name: discipline.name,
        createdAt: DateTime.now(),
      );
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE')) {
        throw ('Já existe uma disciplina com esse nome!|$e');
      } else if (e.toString().contains('NOT NULL')) {
        throw ('O nome da disciplina não pode ser vazio!|$e');
      } else if (e.isNoSuchTableError('discipline')) {
        throw ('Tabela de disciplinas não encontrada!|$e');
      } else if (e.isSyntaxError()) {
        throw ('Erro de sintaxe na tabela de disciplinas!|$e');
      } else {
        throw ('Erro ao criar disciplina: $e');
      }
    } catch (e) {
      throw ('Erro desconhecido ao criar disciplina: $e');
    }
  }

  @override
  Future<List<Discipline>> readDisciplines() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'discipline',
        distinct: true,
      );
      return result.map((map) => Discipline.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      if (e.isNoSuchTableError('discipline')) {
        throw ('Tabela de disciplinas não encontrada!|$e');
      } else if (e.isSyntaxError()) {
        throw ('Erro de sintaxe ao buscar disciplinas!|$e');
      } else {
        throw ('Erro ao buscar as disciplinas: $e');
      }
    } catch (e) {
      throw ('Erro desconhecido ao buscar disciplinas: $e');
    }
  }

  @override
  Future<void> updateDiscipline(Discipline discipline) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'discipline',
        {'name': discipline.name.toLowerCase()},
        where: 'id = ?',
        whereArgs: [discipline.id],
      );
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE')) {
        throw ('Já existe uma disciplina com esse nome!|$e');
      } else if (e.toString().contains('NOT NULL')) {
        throw ('O nome da disciplina não pode ser vazio!|$e');
      } else if (e.isNoSuchTableError('discipline')) {
        throw ('Tabela de disciplinas não encontrada!|$e');
      } else if (e.isSyntaxError()) {
        throw ('Erro de sintaxe na tabela de disciplinas!|$e');
      } else {
        throw ('Erro ao atualizar disciplina: $e');
      }
    } catch (e) {
      throw ('Erro desconhecido ao atualizar disciplina: $e');
    }
  }

  @override
  Future<void> deleteDiscipline(int id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'discipline',
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (e) {
      if (e.isNoSuchTableError('discipline')) {
        throw ('Tabela de disciplinas não encontrada!|$e');
      } else if (e.isSyntaxError()) {
        throw ('Erro de sintaxe ao deletar disciplina!|$e');
      } else {
        throw ('Erro ao deletar disciplina: $e');
      }
    } catch (e) {
      throw ('Erro desconhecido ao deletar disciplina: $e');
    }
  }
}
