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
        // Se não for um erro de UNIQUE, relance a exceção original
        // ou uma mensagem genérica de erro de banco de dados.
        throw ('Erro de banco de dados ao criar turma: ${e.toString()}');
        // Ou simplesmente: throw e; // relança a exceção original
      }
    } catch (e) {
      // Já está bom aqui, pois você já tem um throw
      throw ('Erro desconhecido ao criar turma: $e');
    }
  }

  @override
  Future<List<Classe>> readClasses({bool? active, int? year}) async {
    try {
      final db = await _databaseHelper.database;
      final currentYear = DateTime.now().year; // Ano atual
      final effectiveYear =
          year ?? currentYear; // Se 'year' for nulo, usa o ano atual
      final effectiveActive = active; // Permite que seja nulo para buscar todos

      String whereClause = '';
      List<dynamic> whereArgs = [];

      // Filtro por ano letivo
      whereClause += "school_year = ?";
      whereArgs.add(effectiveYear);

      // Filtro por status ativo/inativo
      if (effectiveActive != null) {
        whereClause += " AND active = ?";
        whereArgs.add(effectiveActive ? 1 : 0);
      }

      final result = await db.query(
        'classe',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'name ASC', // Ordenar por nome por padrão
      );
      return result.map((map) => Classe.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      // --- Adicionei as condições de erro específicas e um throw final ---
      if (e.isNoSuchTableError('classe')) {
        throw ('Tabela de turmas não encontrada ao tentar ler!|$e');
      } else if (e.isSyntaxError()) {
        throw ('Erro de sintaxe ao buscar turmas!|$e');
      }
      // Se não for nenhum dos erros específicos, relança o erro original
      throw ('Erro ao buscar as turmas: $e'); // <--- Garante que uma exceção é SEMPRE lançada aqui
    } catch (e) {
      // Para qualquer outra exceção não esperada
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
          'school_year': classe.schoolYear, // Incluído school_year
          'created_at': classe.createdAt?.toIso8601String(),
          'active': (classe.active ?? true) ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [classe.id],
      );
    } on DatabaseException catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        // Ajustado para a mensagem de erro comum do SQLite
        throw ('Já existe uma turma com esse nome para o ano ${classe.schoolYear}!');
      }
      // ... outros catchs
    } catch (e) {
      throw ('Erro desconhecido ao atualizar turma: $e');
    }
  }


}
