import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:vocatus/app/core/constants/constants.dart';
import 'package:vocatus/app/core/utils/database/database_schema.dart';
import 'package:vocatus/app/core/utils/database/database_seed.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    log(
      'DatabaseHelper.database - Tentando obter instância do banco de dados.',
      name: 'DatabaseHelper',
    );
    if (_database != null) {
      log(
        'DatabaseHelper.database - Instância do banco de dados já existente, retornando.',
        name: 'DatabaseHelper',
      );
      return _database!;
    } else {
      log(
        'DatabaseHelper.database - Instância do banco de dados nula, inicializando...',
        name: 'DatabaseHelper',
      );
      _database = await _initDatabase();
      log(
        'DatabaseHelper.database - Banco de dados inicializado e retornado.',
        name: 'DatabaseHelper',
      );
      return _database!;
    }
  }

  Future<Database> _initDatabase() async {
    log(
      'DatabaseHelper._initDatabase - Iniciando inicialização do banco de dados.',
      name: 'DatabaseHelper',
    );
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'vocatus.db');
    log(
      'DatabaseHelper._initDatabase - Caminho do banco de dados: $path',
      name: 'DatabaseHelper',
    );

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        log(
          'DatabaseHelper.onCreate - Callback onCreate chamado. Versão: $version.',
          name: 'DatabaseHelper',
        );
        try {
          await db.execute('PRAGMA foreign_keys = ON;');
          await DatabaseSchema.createTables(db);

          if (Constants.isDevelopmentMode) {
            log(
              'DatabaseHelper.onCreate - Modo de desenvolvimento detectado. Inserindo dados iniciais (seeding).',
              name: 'DatabaseHelper',
            );
            await DatabaseSeed.insertInitialData(db);
          } else {
            log(
              'DatabaseHelper.onCreate - Modo de produção/teste detectado. Skipping seeding.',
              name: 'DatabaseHelper',
            );
          }

          log(
            'DatabaseHelper.onCreate - Criação de tabelas concluída com sucesso (e populamento condicional).',
            name: 'DatabaseHelper',
          );
        } catch (e, s) {
          log(
            'DatabaseHelper.onCreate - Erro durante a criação/populamento do DB: $e',
            name: 'DatabaseHelper',
            error: e,
            stackTrace: s,
          );
          rethrow;
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        log(
          'DatabaseHelper.onUpgrade - Callback onUpgrade chamado. De $oldVersion para $newVersion.',
          name: 'DatabaseHelper',
        );
        try {
          log(
            'DatabaseHelper.onUpgrade - Deletando todas as tabelas para recriação.',
            name: 'DatabaseHelper',
          );
          await DatabaseSchema.dropTables(db);
          await db.execute('PRAGMA foreign_keys = ON;');
          await DatabaseSchema.createTables(db);

          if (Constants.isDevelopmentMode) {
            log(
              'DatabaseHelper.onUpgrade - Modo de desenvolvimento detectado. Repopulando dados (seeding).',
              name: 'DatabaseHelper',
            );
            await DatabaseSeed.insertInitialData(db);
          } else {
            log(
              'DatabaseHelper.onUpgrade - Modo de produção/teste detectado. Skipping repopulation.',
              name: 'DatabaseHelper',
            );
          }

          log(
            'DatabaseHelper.onUpgrade - Upgrade concluído: tabelas deletadas, recriadas e dados repopulados condicionalmente.',
            name: 'DatabaseHelper',
          );
        } catch (e, s) {
          log(
            'DatabaseHelper.onUpgrade - Erro durante o upgrade do DB: $e',
            name: 'DatabaseHelper',
            error: e,
            stackTrace: s,
          );
          rethrow;
        }
      },
      onOpen: (db) async {
        log(
          'DatabaseHelper.onOpen - Callback onOpen chamado.',
          name: 'DatabaseHelper',
        );
        try {
          await db.execute('PRAGMA foreign_keys = ON;');
          log(
            'DatabaseHelper.onOpen - PRAGMA foreign_keys = ON executado com sucesso.',
            name: 'DatabaseHelper',
          );
        } catch (e, s) {
          log(
            'DatabaseHelper.onOpen - Erro ao executar PRAGMA foreign_keys: $e',
            name: 'DatabaseHelper',
            error: e,
            stackTrace: s,
          );
          rethrow;
        }
      },
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
    log(
      'DatabaseHelper.close - Banco de dados fechado e instância limpa.',
      name: 'DatabaseHelper',
    );
  }
}