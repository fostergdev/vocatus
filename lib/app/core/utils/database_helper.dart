import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:vocatus/app/core/constants/constants.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return instance;
  }

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
      version: 1,
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON;');

        await db.execute('''
CREATE TABLE discipline (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  active INTEGER NOT NULL DEFAULT 1
);
''');

        await db.execute('''
CREATE TABLE classe (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  school_year INTEGER NOT NULL,
  active INTEGER NOT NULL DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
''');

        await db.execute('''
CREATE TABLE student (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
''');

        await db.execute('''
CREATE TABLE classe_student (
  student_id INTEGER NOT NULL,
  classe_id INTEGER NOT NULL,
  start_date TEXT NOT NULL DEFAULT CURRENT_DATE,
  end_date TEXT,
  active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (student_id, classe_id),
  FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE,
  FOREIGN KEY (classe_id) REFERENCES classe(id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE grade (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  classe_id INTEGER NOT NULL,
  discipline_id INTEGER,
  day_of_week INTEGER NOT NULL,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  grade_year INTEGER NOT NULL, -- ou INTEGER se permitir nulo
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  active INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (classe_id) REFERENCES classe(id) ON DELETE CASCADE,
  FOREIGN KEY (discipline_id) REFERENCES discipline(id) ON DELETE SET NULL,
  UNIQUE (classe_id, day_of_week, start_time) -- Adicione esta linha
);
''');

        await db.execute('''
CREATE TABLE attendance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  classe_id INTEGER NOT NULL,
  grade_id INTEGER,
  date TEXT NOT NULL,
  content TEXT, -- Adicione esta linha
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  active INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (classe_id) REFERENCES classe(id) ON DELETE CASCADE,
  FOREIGN KEY (grade_id) REFERENCES grade(id) ON DELETE SET NULL,
  UNIQUE (classe_id, grade_id, date)
);
''');

        await db.execute('''
CREATE TABLE student_attendance (
  attendance_id INTEGER NOT NULL,
  student_id INTEGER NOT NULL,
  presence INTEGER NOT NULL DEFAULT 1,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  active INTEGER NOT NULL DEFAULT 1,
  PRIMARY KEY (attendance_id, student_id),
  FOREIGN KEY (attendance_id) REFERENCES attendance(id) ON DELETE CASCADE,
  FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE
);
''');

        await Constants.insertDefaultDisciplines(db);
      },
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
