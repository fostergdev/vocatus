import 'package:sqflite/sqflite.dart'; // Importa o pacote sqflite para manipulação do banco de dados SQLite
import 'package:vocatus/app/core/utils/database/database_helper.dart'; // Importa o helper do banco de dados
import 'package:vocatus/app/models/discipline.dart'; // Importa o modelo de Disciplina
import 'package:vocatus/app/repositories/disciplines/i_discipline_repository.dart'; // Importa a interface do repositório de disciplinas

class DisciplineRepository implements IDisciplineRepository {
  final DatabaseHelper _databaseHelper; // Helper para acessar o banco de dados

  // Construtor recebe o helper do banco de dados
  DisciplineRepository(this._databaseHelper);

  /// Cria uma nova disciplina no banco de dados.
  /// Retorna a disciplina criada com o id gerado.
  @override
  Future<Discipline> createDiscipline(Discipline discipline) async {
    try {
      final db = await _databaseHelper.database; // Obtém a instância do banco
      final id = await db.insert(
        'discipline', // Insere na tabela 'discipline'
        {'name': discipline.name.toLowerCase().trim()}, // Nome da disciplina em minúsculo e sem espaços
      );
      return Discipline(
        id: id, // Id gerado pelo banco
        name: discipline.name, // Nome original informado
        createdAt: DateTime.now(), // Data de criação (agora)
      );
    } on DatabaseException catch (e) {
      // Trata erros específicos do banco de dados
      if (e.toString().contains('UNIQUE')) {
        throw ('Já existe uma disciplina com esse nome!|$e'); // Nome duplicado
      } else if (e.toString().contains('NOT NULL')) {
        throw ('O nome da disciplina não pode ser vazio!|$e'); // Nome obrigatório
      } else if (e.isNoSuchTableError('discipline')) {
        throw ('Tabela de disciplinas não encontrada!|$e'); // Tabela não existe
      } else if (e.isSyntaxError()) {
        throw ('Erro de sintaxe na tabela de disciplinas!|$e'); // Erro de sintaxe SQL
      } else {
        throw ('Erro ao criar disciplina: $e'); // Outro erro de banco
      }
    } catch (e) {
      throw ('Erro desconhecido ao criar disciplina: $e'); // Erro inesperado
    }
  }

  /// Busca todas as disciplinas do banco de dados.
  @override
  Future<List<Discipline>> readDisciplines() async {
    try {
      final db = await _databaseHelper.database; // Obtém a instância do banco
      final result = await db.query(
        'discipline', // Consulta a tabela 'discipline'
        distinct: true, // Retorna apenas distintos
      );
      return result.map((map) => Discipline.fromMap(map)).toList(); // Converte o resultado em uma lista de Discipline
    } on DatabaseException catch (e) {
      // Trata erros específicos do banco de dados
      if (e.isNoSuchTableError('discipline')) {
        throw ('Tabela de disciplinas não encontrada!|$e'); // Tabela não existe
      } else if (e.isSyntaxError()) {
        throw ('Erro de sintaxe ao buscar disciplinas!|$e'); // Erro de sintaxe SQL
      } else {
        throw ('Erro ao buscar as disciplinas: $e'); // Outro erro de banco
      }
    } catch (e) {
      throw ('Erro desconhecido ao buscar disciplinas: $e'); // Erro inesperado
    }
  }

  /// Atualiza os dados de uma disciplina existente no banco de dados.
  @override
  Future<void> updateDiscipline(Discipline discipline) async {
    try {
      final db = await _databaseHelper.database; // Obtém a instância do banco
      await db.update(
        'discipline', // Atualiza na tabela 'discipline'
        {'name': discipline.name.toLowerCase()}, // Nome atualizado em minúsculo
        where: 'id = ?', // Filtro pelo id da disciplina
        whereArgs: [discipline.id], // Argumento do filtro
      );
    } on DatabaseException catch (e) {
      // Trata erros específicos do banco de dados
      if (e.toString().contains('UNIQUE')) {
        throw ('Já existe uma disciplina com esse nome!|$e'); // Nome duplicado
      } else if (e.toString().contains('NOT NULL')) {
        throw ('O nome da disciplina não pode ser vazio!|$e'); // Nome obrigatório
      } else if (e.isNoSuchTableError('discipline')) {
        throw ('Tabela de disciplinas não encontrada!|$e'); // Tabela não existe
      } else if (e.isSyntaxError()) {
        throw ('Erro de sintaxe na tabela de disciplinas!|$e'); // Erro de sintaxe SQL
      } else {
        throw ('Erro ao atualizar disciplina: $e'); // Outro erro de banco
      }
    } catch (e) {
      throw ('Erro desconhecido ao atualizar disciplina: $e'); // Erro inesperado
    }
  }

  /// Deleta uma disciplina do banco de dados pelo id.
  @override
  Future<void> deleteDiscipline(int id) async {
    try {
      final db = await _databaseHelper.database; // Obtém a instância do banco
      await db.delete(
        'discipline', // Deleta da tabela 'discipline'
        where: 'id = ?', // Filtro pelo id da disciplina
        whereArgs: [id], // Argumento do filtro
      );
    } on DatabaseException catch (e) {
      // Trata erros específicos do banco de dados
      if (e.isNoSuchTableError('discipline')) {
        throw ('Tabela de disciplinas não encontrada!|$e'); // Tabela não existe
      } else if (e.isSyntaxError()) {
        throw ('Erro de sintaxe ao deletar disciplina!|$e'); // Erro de sintaxe SQL
      } else {
        throw ('Erro ao deletar disciplina: $e'); // Outro erro de banco
      }
    } catch (e) {
      throw ('Erro desconhecido ao deletar disciplina: $e'); // Erro inesperado
    }
  }
}
