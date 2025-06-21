import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/repositories/classes/i_classes_repository.dart';

class ClasseRepository implements IClasseRepository {
  final DatabaseHelper _databaseHelper;

  ClasseRepository(this._databaseHelper);

  @override
  Future<Classe> createClasse(Classe classe) async {
    try {
      final db = await _databaseHelper.database;
      final id = await db.insert('classe', {
        'name': classe.name.toLowerCase(),
        'description': classe.description,
        'school_year': classe.schoolYear,
        'created_at':
            classe.createdAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'active': (classe.active ?? true) ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.abort);
      return Classe(
        id: id,
        name: classe.name,
        description: classe.description,
        schoolYear: classe.schoolYear,
        createdAt: classe.createdAt ?? DateTime.now(),
        active: classe.active,
      );
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
      return result.map((map) => Classe.fromMap(map)).toList();
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
      final db = await _databaseHelper.database;
      await db.update(
        'classe',
        {
          'name': classe.name.toLowerCase(),
          'description': classe.description,
          'school_year': classe.schoolYear,
          'created_at': classe.createdAt?.toIso8601String(),
          'active': (classe.active ?? true) ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [classe.id],
      );
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw ('Já existe uma turma com esse nome para o ano ${classe.schoolYear}!');
      }
      // ... outros catchs
    } catch (e) {
      throw ('Erro desconhecido ao atualizar turma: $e');
    }
  }
}
