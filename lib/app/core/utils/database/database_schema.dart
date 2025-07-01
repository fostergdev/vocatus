import 'package:sqflite/sqflite.dart';
import 'dart:developer';

class DatabaseSchema {
  static const List<String> createTableQueries = [
    '''
    CREATE TABLE discipline (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      active INTEGER NOT NULL DEFAULT 1
    );
    ''',
    '''
    CREATE TABLE classe (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      school_year INTEGER NOT NULL,
      active INTEGER NOT NULL DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
    ''',
    '''
    CREATE TABLE student (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );
    ''',
    '''
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
    ''',
    '''
    CREATE TABLE grade (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      classe_id INTEGER NOT NULL,
      discipline_id INTEGER,
      day_of_week INTEGER NOT NULL,
      start_time TEXT NOT NULL,
      end_time TEXT NOT NULL,
      grade_year INTEGER NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      active INTEGER NOT NULL DEFAULT 1,
      FOREIGN KEY (classe_id) REFERENCES classe(id) ON DELETE CASCADE,
      FOREIGN KEY (discipline_id) REFERENCES discipline(id) ON DELETE SET NULL,
      UNIQUE (classe_id, day_of_week, start_time)
    );
    ''',
    '''
    CREATE TABLE attendance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      classe_id INTEGER NOT NULL,
      grade_id INTEGER,
      date TEXT NOT NULL,
      content TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      active INTEGER NOT NULL DEFAULT 1,
      FOREIGN KEY (classe_id) REFERENCES classe(id) ON DELETE CASCADE,
      FOREIGN KEY (grade_id) REFERENCES grade(id) ON DELETE SET NULL,
      UNIQUE (classe_id, grade_id, date)
    );
    ''',
    '''
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
    ''',
    '''
    CREATE TABLE occurrence (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      attendance_id INTEGER NOT NULL,
      student_id INTEGER,
      occurrence_type TEXT,
      description TEXT NOT NULL,
      occurrence_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      active INTEGER NOT NULL DEFAULT 1,
      FOREIGN KEY (attendance_id) REFERENCES attendance(id) ON DELETE CASCADE,
      FOREIGN KEY (student_id) REFERENCES student(id) ON DELETE CASCADE
    );
    ''',
  ];

  static const List<String> tableNamesInReverseOrder = [
    'occurrence',
    'student_attendance',
    'attendance',
    'grade',
    'classe_student',
    'student',
    'classe',
    'discipline',
  ];

  static Future<void> createTables(Database db) async {
    log('DatabaseSchema.createTables - Iniciando criação de todas as tabelas.', name: 'DatabaseSchema');
    for (String query in createTableQueries) {
      await db.execute(query);
    }
    log('DatabaseSchema.createTables - Todas as tabelas criadas com sucesso.', name: 'DatabaseSchema');
  }

  static Future<void> dropTables(Database db) async {
    log('DatabaseSchema.dropTables - Iniciando exclusão de todas as tabelas.', name: 'DatabaseSchema');
    for (String tableName in tableNamesInReverseOrder) {
      await db.execute('DROP TABLE IF EXISTS $tableName;');
    }
    log('DatabaseSchema.dropTables - Todas as tabelas excluídas com sucesso.', name: 'DatabaseSchema');
  }
}