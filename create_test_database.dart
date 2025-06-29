import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() async {
  print('🚀 Criando banco de dados Vocatus para testes...\n');
  
  try {
    // Inicializar sqflite
    print('📦 Inicializando SQLite FFI...');
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print('✅ SQLite FFI inicializado');

    // Criar diretório se não existir
    final dbDir = Directory(join(Platform.environment['HOME']!, '.local', 'share', 'vocatus', 'databases'));
    if (!await dbDir.exists()) {
      print('📁 Criando diretório: ${dbDir.path}');
      await dbDir.create(recursive: true);
    }
    
    final dbPath = join(dbDir.path, 'vocatus.db');
    print('🔗 Criando banco em: $dbPath');
    
    // Criar e abrir o banco
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        print('🏗️  Criando estrutura do banco...');
        
        // Habilitar foreign keys
        await db.execute('PRAGMA foreign_keys = ON;');

        // Tabela discipline
        await db.execute('''
          CREATE TABLE discipline (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            active INTEGER NOT NULL DEFAULT 1
          );
        ''');
        print('✅ Tabela discipline criada');

        // Tabela classe
        await db.execute('''
          CREATE TABLE classe (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            school_year INTEGER NOT NULL,
            discipline_id INTEGER NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            active INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY (discipline_id) REFERENCES discipline(id)
          );
        ''');
        print('✅ Tabela classe criada');

        // Tabela student
        await db.execute('''
          CREATE TABLE student (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            cpf TEXT UNIQUE,
            email TEXT,
            phone TEXT,
            address TEXT,
            birth_date TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            active INTEGER NOT NULL DEFAULT 1
          );
        ''');
        print('✅ Tabela student criada');

        // Tabela enrollment
        await db.execute('''
          CREATE TABLE enrollment (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            classe_id INTEGER NOT NULL,
            enrollment_date TEXT DEFAULT CURRENT_TIMESTAMP,
            status TEXT NOT NULL DEFAULT 'active',
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            active INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY (student_id) REFERENCES student(id),
            FOREIGN KEY (classe_id) REFERENCES classe(id)
          );
        ''');
        print('✅ Tabela enrollment criada');

        // Tabela attendance
        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            classe_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            active INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY (classe_id) REFERENCES classe(id)
          );
        ''');
        print('✅ Tabela attendance criada');

        // Tabela occurrence
        await db.execute('''
          CREATE TABLE occurrence (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            attendance_id INTEGER NOT NULL,
            status TEXT NOT NULL DEFAULT 'present',
            observations TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            active INTEGER NOT NULL DEFAULT 1,
            FOREIGN KEY (student_id) REFERENCES student(id),
            FOREIGN KEY (attendance_id) REFERENCES attendance(id)
          );
        ''');
        print('✅ Tabela occurrence criada');

        print('🎉 Estrutura do banco criada com sucesso!');
      },
    );
    
    print('✅ Banco de dados criado e aberto');
    
    // Inserir dados de teste
    print('\n📝 Inserindo dados de teste...');
    
    // Inserir disciplina
    await db.insert('discipline', {
      'name': 'Matemática',
      'active': 1,
    });
    
    // Inserir turma
    await db.insert('classe', {
      'name': '1 ano A fundamental',
      'description': 'Turma do primeiro ano do ensino fundamental',
      'school_year': 2024,
      'discipline_id': 1,
      'active': 1,
    });
    
    // Inserir alguns estudantes
    final students = [
      {'name': 'João Silva', 'active': 1},
      {'name': 'Maria Santos', 'active': 1},
      {'name': 'Pedro Oliveira', 'active': 1},
      {'name': 'Ana Costa', 'active': 1},
    ];
    
    for (final student in students) {
      await db.insert('student', student);
    }
    
    // Inserir matrículas
    for (int i = 1; i <= 4; i++) {
      await db.insert('enrollment', {
        'student_id': i,
        'classe_id': 1,
        'status': 'active',
        'active': 1,
      });
    }
    
    // Inserir algumas chamadas
    final attendances = [
      {'classe_id': 1, 'date': '2024-06-01', 'active': 1},
      {'classe_id': 1, 'date': '2024-06-02', 'active': 1},
      {'classe_id': 1, 'date': '2024-06-03', 'active': 1},
      {'classe_id': 1, 'date': '2024-06-04', 'active': 1},
      {'classe_id': 1, 'date': '2024-06-05', 'active': 1},
    ];
    
    for (final attendance in attendances) {
      await db.insert('attendance', attendance);
    }
    
    // Inserir ocorrências (presenças)
    for (int attendanceId = 1; attendanceId <= 5; attendanceId++) {
      for (int studentId = 1; studentId <= 4; studentId++) {
        await db.insert('occurrence', {
          'student_id': studentId,
          'attendance_id': attendanceId,
          'status': studentId % 2 == 0 ? 'present' : 'absent', // Alternar presente/ausente
          'active': 1,
        });
      }
    }
    
    print('✅ Dados de teste inseridos');
    
    // Verificar dados
    print('\n📊 Verificando dados inseridos...');
    
    final classesCount = await db.rawQuery('SELECT COUNT(*) as count FROM classe');
    print('🏫 Turmas: ${classesCount.first['count']}');
    
    final studentsCount = await db.rawQuery('SELECT COUNT(*) as count FROM student');
    print('👨‍🎓 Estudantes: ${studentsCount.first['count']}');
    
    final attendancesCount = await db.rawQuery('SELECT COUNT(*) as count FROM attendance');
    print('📋 Chamadas: ${attendancesCount.first['count']}');
    
    final occurrencesCount = await db.rawQuery('SELECT COUNT(*) as count FROM occurrence');
    print('📝 Ocorrências: ${occurrencesCount.first['count']}');
    
    await db.close();
    print('\n🎉 Banco de dados criado com sucesso!');
    print('📂 Localização: $dbPath');
    print('💡 Agora você pode executar o script de debug: dart debug_attendance_occurrences.dart');
    
  } catch (e, stackTrace) {
    print('❌ ERRO: $e');
    print('📋 Stack trace: $stackTrace');
    exit(1);
  }
}

void sqfliteFfiInit() {
  // Required for sqflite_common_ffi
}
