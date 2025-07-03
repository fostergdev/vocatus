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
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'vocatus.db');

    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        try {
          await db.execute('PRAGMA foreign_keys = ON;');
          await DatabaseSchema.createTables(db);

          if (Constants.isDevelopmentMode) {
            await DatabaseSeed.insertInitialData(db);
          }
        } catch (e) {
          rethrow;
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        try {
          await DatabaseSchema.dropTables(db);
          await db.execute('PRAGMA foreign_keys = ON;');
          await DatabaseSchema.createTables(db);

          if (Constants.isDevelopmentMode) {
            await DatabaseSeed.insertInitialData(db);
          }
        } catch (e) {
          rethrow;
        }
      },
      onOpen: (db) async {
        try {
          await db.execute('PRAGMA foreign_keys = ON;');
        } catch (e) {
          rethrow;
        }
      },
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}