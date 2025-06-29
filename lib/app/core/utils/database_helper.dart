/* import 'package:sqflite/sqflite.dart';
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
      version: 1, // Versão do banco de dados
      onCreate: (db, version) async {
        await db.execute('PRAGMA foreign_keys = ON;');

        // Criação da tabela discipline
        await db.execute('''
CREATE TABLE discipline (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  active INTEGER NOT NULL DEFAULT 1
);
''');

        // Criação da tabela classe
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

        // Criação da tabela student
        await db.execute('''
CREATE TABLE student (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
''');

        // Criação da tabela classe_student
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

        // Criação da tabela grade
        await db.execute('''
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
''');

        // Criação da tabela attendance
        await db.execute('''
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
''');

        // Criação da tabela student_attendance
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

        await db.execute('''
CREATE TABLE occurrence (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  attendance_id INTEGER NOT NULL,          -- Liga à sessão de chamada específica
  student_id INTEGER,                      -- NULL para ocorrência geral, NOT NULL para específica do aluno
  occurrence_type TEXT,                    -- Ex: 'Comportamento', 'Saúde', 'Atraso', 'Material'
  description TEXT NOT NULL,               -- Descrição detalhada da ocorrência
  occurrence_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Quando o evento realmente ocorreu
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,               -- Quando este registro foi criado no DB
  active INTEGER NOT NULL DEFAULT 1,
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
    await db.close(); // Usa await para fechar o banco de dados
    _database = null; // Limpa a instância estática
  }
}
 */
import 'dart:developer'; // Para usar log
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart'; // Import necessário para .firstWhereOrNull
import 'dart:math' as math; // <-- AQUI ESTÁ A MUDANÇA: Adicionado 'as math'

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
      version: 2, // Mantenha a versão 2 ou aumente se já tiver rodado antes
      onCreate: (db, version) async {
        log(
          'DatabaseHelper.onCreate - Callback onCreate chamado. Versão: $version.',
          name: 'DatabaseHelper',
        );
        try {
          await _createTablesAndPopulateData(db);
          log(
            'DatabaseHelper.onCreate - Criação e populamento de dados concluídos com sucesso.',
            name: 'DatabaseHelper',
          );
        } catch (e, s) {
          log(
            'DatabaseHelper.onCreate - Erro durante a criação/populamento do DB: $e',
            name: 'DatabaseHelper',
            error: e,
            stackTrace: s,
          );
          rethrow; // Re-lança o erro para que seja tratado por quem chamou openDatabase
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        log(
          'DatabaseHelper.onUpgrade - Callback onUpgrade chamado. De $oldVersion para $newVersion.',
          name: 'DatabaseHelper',
        );
        try {
          if (oldVersion < newVersion) {
            log(
              'DatabaseHelper.onUpgrade - Versão antiga ($oldVersion) menor que a nova ($newVersion). Deletando e recriando tabelas.',
              name: 'DatabaseHelper',
            );
            print(
              'Upgrading database from version $oldVersion to $newVersion. ALL DATA WILL BE LOST.',
            );
            await db.execute('DROP TABLE IF EXISTS occurrence;');
            await db.execute('DROP TABLE IF EXISTS student_attendance;');
            await db.execute('DROP TABLE IF EXISTS attendance;');
            await db.execute('DROP TABLE IF EXISTS grade;');
            await db.execute('DROP TABLE IF EXISTS classe_student;');
            await db.execute('DROP TABLE IF EXISTS student;');
            await db.execute('DROP TABLE IF EXISTS classe;');
            await db.execute('DROP TABLE IF EXISTS discipline;');
            log(
              'DatabaseHelper.onUpgrade - Tabelas existentes deletadas. Chamando _createTablesAndPopulateData.',
              name: 'DatabaseHelper',
            );
            await _createTablesAndPopulateData(db); // Recria e popula tudo
            log(
              'DatabaseHelper.onUpgrade - Recriação e populamento de dados concluídos com sucesso após upgrade.',
              name: 'DatabaseHelper',
            );
          } else {
            log(
              'DatabaseHelper.onUpgrade - Nenhuma ação de upgrade necessária para esta versão. Versão antiga: $oldVersion, Nova: $newVersion.',
              name: 'DatabaseHelper',
            );
          }
        } catch (e, s) {
          log(
            'DatabaseHelper.onUpgrade - Erro durante o upgrade do DB: $e',
            name: 'DatabaseHelper',
            error: e,
            stackTrace: s,
          );
          rethrow; // Re-lança o erro para que seja tratado
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

  Future<void> _createTablesAndPopulateData(Database db) async {
    log(
      'DatabaseHelper._createTablesAndPopulateData - Iniciando criação de tabelas e populamento de dados.',
      name: 'DatabaseHelper',
    );
    try {
      await db.execute('PRAGMA foreign_keys = ON;');
      log(
        'DatabaseHelper._createTablesAndPopulateData - PRAGMA foreign_keys = ON executado para populamento.',
        name: 'DatabaseHelper',
      );

      // Disciplines
      log(
        'DatabaseHelper._createTablesAndPopulateData - Criando tabela discipline.',
        name: 'DatabaseHelper',
      );
      await db.execute('''
        CREATE TABLE discipline (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          active INTEGER NOT NULL DEFAULT 1
        );
      ''');
      log(
        'DatabaseHelper._createTablesAndPopulateData - Tabela discipline criada. Inserindo disciplinas padrão.',
        name: 'DatabaseHelper',
      );

      final List<String> defaultDisciplines = [
        'Português',
        'Matemática',
        'História',
        'Ciências',
        'Geografia',
        'Inglês',
        'Artes',
        'Educação Física',
      ];
      for (String name in defaultDisciplines) {
        await db.insert('discipline', {'name': name, 'active': 1});
      }
      log(
        'DatabaseHelper._createTablesAndPopulateData - Disciplinas padrão inseridas.',
        name: 'DatabaseHelper',
      );

      // Classes
      log(
        'DatabaseHelper._createTablesAndPopulateData - Criando tabela classe.',
        name: 'DatabaseHelper',
      );
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
      log(
        'DatabaseHelper._createTablesAndPopulateData - Tabela classe criada. Inserindo classes de exemplo.',
        name: 'DatabaseHelper',
      );

      final List<int> classeIds = [];
      final currentYear = DateTime.now().year;

      // Turmas ativas
      for (int i = 0; i < 9; i++) {
        // 9 turmas (1º ao 9º ano)
        final String className =
            '${(i + 1)}º Ano ${String.fromCharCode(65 + i)} - Fundamental'; // A, B, C, ...
        final String description =
            'Turma do ensino fundamental ${className.split(' ')[0]} ${className.split(' ')[2]}';
        final int classeId = await db.insert('classe', {
          'name': className,
          'description': description,
          'school_year': currentYear,
          'active': 1,
          'created_at': DateTime.now().toIso8601String(),
        });
        classeIds.add(classeId);
      }
      // Turmas de ensino médio
      for (int i = 0; i < 3; i++) {
        // 3 turmas (1º ao 3º ano médio)
        final String className =
            '${(i + 1)}º Ano ${String.fromCharCode(74 + i)} - Médio'; // J, K, L
        final String description =
            'Turma do ensino médio ${className.split(' ')[0]} ${className.split(' ')[2]}';
        final int classeId = await db.insert('classe', {
          'name': className,
          'description': description,
          'school_year': currentYear + 1,
          'active': 1,
          'created_at': DateTime.now().toIso8601String(),
        });
        classeIds.add(classeId);
      }

      // Turma arquivada
      final int archivedClasseId = await db.insert('classe', {
        'name': 'Turma Antiga - 2023',
        'description': 'Turma de exemplo arquivada de 2023',
        'school_year': 2023,
        'active': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
      classeIds.add(archivedClasseId); // Adiciona ao final da lista de IDs

      log(
        'DatabaseHelper._createTablesAndPopulateData - Classes de exemplo inseridas. Total: ${classeIds.length} turmas.',
        name: 'DatabaseHelper',
      );

      // Students
      log(
        'DatabaseHelper._createTablesAndPopulateData - Criando tabela student.',
        name: 'DatabaseHelper',
      );
      await db.execute('''
        CREATE TABLE student (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        );
      ''');
      log(
        'DatabaseHelper._createTablesAndPopulateData - Tabela student criada. Inserindo alunos de exemplo.',
        name: 'DatabaseHelper',
      );

      final List<String> allStudentNames = [
        'Ana Carolina Silva',
        'João Pedro Santos',
        'Maria Eduarda Oliveira',
        'Pedro Henrique Souza',
        'Laura Beatriz Almeida',
        'Miguel Ângelo Pereira',
        'Sophia Liz Lima',
        'Davi Lucca Costa',
        'Alice Vitória Rocha',
        'Arthur Gabriel Martins',
        'Manuela Fernanda Barbosa',
        'Enzo Gabriel Gomes',
        'Valentina Rosa Fernandes',
        'Guilherme Lucas Ribeiro',
        'Isabela Cristina Carvalho',
        'Lucas Daniel Freitas',
        'Helena Sofia Dias',
        'Bruno Rafael Mendes',
        'Lívia Mariana Pinto',
        'Nicolas Felipe Conceição',
        'Giovanna Laura Teixeira',
        'Rafael Augusto Ferreira',
        'Lorena Vitória Cardoso',
        'Leonardo Miguel Barros',
        'Clara Manuela Fonseca',
        'Mateus Henrique Vasconcelos',
        'Beatriz Gabriela Pires',
        'Daniel Eduardo Sales',
        'Mariana Luiza Queiroz',
        'Murilo César Nascimento',
        'Gabriela Rafaela Miranda',
        'Felipe Leonardo Cunha',
        'Luísa Betina Farias',
        'Vitor Hugo Melo',
        'Cecília Alice Cruz',
        'João Guilherme Figueiredo',
        'Emanuelly Sofia Campos',
        'Caio Ricardo Moraes',
        'Catarina Elisa Guimarães',
        'Erick Samuel Cabral',
        'Esther Letícia Duarte',
        'Fábio Junior Figueira',
        'Julia Letícia Guerra',
        'Luan Gabriel Lopes',
        'Melissa Nicole Macedo',
        'Nina Beatriz Noronha',
        'Benício Davi Pacheco',
        'Carolina Vitória Reis',
        'Cauã Roberto Leal',
        'Lorena Sophia Castro',
        'Lucca Enzo Azevedo',
        'Maitê Isadora Teixeira',
        'Maria Clara Rocha',
        'Gustavo Henrique Ferreira',
        'Yasmin Luiza Sales',
        'Thiago Rafael Santos',
        'Olivia Maria Pereira',
        'Henrique José Silva',
        'Sofia Gabriela Lima',
        'Antônio Lucas Costa',
        'Vitória Beatriz Mendes',
        'Carlos Eduardo Oliveira',
        'Ana Clara Gomes',
        'Ricardo Bruno Barbosa',
        'Eduarda Luan Almeida',
        'Diego César Souza',
        'Laura Isabela Fernandes',
        'João Victor Ribeiro',
        'Marina Eduarda Carvalhais',
        'Paulo Vitor Freitas',
        'Letícia Sophia Dias',
        'Gustavo Filipe Martins',
        'Elisa Gabriela Pinto',
        'André Lucas Conceição',
        'Julia Rafaela Teixeira',
        'Luiz Fernando Ferreira',
        'Helena Carolina Cardoso',
        'Fábio Ricardo Barros',
        'Mariana Betina Fonseca',
        'Bruno Guilherme Vasconcelos',
        'Rafaela Vitória Pires',
        'Victor Daniel Sales',
        'Fernanda Maria Queiroz',
        'Pedro Arthur Nascimento',
        'Isadora Luiza Miranda',
        'Vinícius João Cunha',
        'Maitê Carolina Farias',
        'Miguel Luan Melo',
        'Sofia Emanuelly Cruz',
        'Davi João Figueiredo',
        'Alice Emanuelly Campos',
        'Arthur Ricardo Moraes',
        'Manuela Elisa Guimarães',
        'Enzo Fábio Cabral',
        'Valentina Julia Duarte',
        'Guilherme Luan Figueira',
        'Isabela Melissa Guerra',
        'Lucas Nina Lopes',
        'Helena Benício Macedo',
        'Bruno Catarina Noronha',
        'Lívia Caio Pacheco',
        'Nicolas Erick Reis',
        'Giovanna Esther Leal',
        'Rafael Fábio Castro',
        'Lorena Julia Azevedo',
        'Leonardo Luan Teixeira',
        'Clara Melissa Ferreira',
        'Mateus Nina Cardoso',
        'Beatriz Benício Barros',
        'Daniel Catarina Fonseca',
        'Mariana Caio Vasconcelos',
        'Murilo Erick Pires',
        'Gabriela Esther Sales',
        'Felipe Fábio Queiroz',
        'Luísa Julia Nascimento',
        'Vitor Luan Miranda',
        'Cecília Melissa Cunha',
        'João Nina Farias',
        'Emanuelly Benício Melo',
        'Caio Catarina Cruz',
        'Catarina Caio Figueiredo',
        'Erick Esther Campos',
        'Esther Fábio Moraes',
        'Fábio Julia Guimarães',
        'Laura Luan Cabral',
        'Letícia Melissa Duarte',
        'Luan Nina Figueira',
        'Melissa Benício Guerra',
        'Nina Catarina Lopes',
        'Alice Fernandes Lima',
        'Bruno Alves Costa',
        'Carla Rodrigues Souza',
        'Daniel Silva Almeida',
        'Eduarda Lima Pereira',
        'Fernanda Costa Santos',
        'Gabriel Oliveira Rocha',
        'Heloísa Sousa Martins',
        'Igor Ribeiro Barbosa',
        'Júlia Conceição Gomes',
        'Kleber Andrade Fernandes',
        'Marcos Dias Carvalhais',
        'Natália Teixeira Mendes',
        'Otávio Rocha Pinto',
        'Paula Nunes Conceição',
        'Quirino Leal Moreira',
        'Renata Castro Nunes',
        'Samuel Barros Vieira',
        'Tainá Freitas Ramos',
        'Ubiratã Sales Machado',
        'Viviane Pires Reis',
        'Wagner Azevedo Monteiro',
        'Xenia Fonseca Leal',
        'Yara Cardoso Castro',
        'Zeca Vasconcelos Azevedo',
      ];

      final List<int> studentIds = [];
      for (String name in allStudentNames) {
        int id = await db.insert('student', {
          'name': name,
          'active': 1,
          'created_at': DateTime.now().toIso8601String(),
        });
        studentIds.add(id);
      }
      log(
        'DatabaseHelper._createTablesAndPopulateData - Alunos de exemplo inseridos. Total: ${studentIds.length} alunos.',
        name: 'DatabaseHelper',
      );

      // Classe_Student
      log(
        'DatabaseHelper._createTablesAndPopulateData - Criando tabela classe_student.',
        name: 'DatabaseHelper',
      );
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
      log(
        'DatabaseHelper._createTablesAndPopulateData - Tabela classe_student criada. Distribuindo alunos por turmas.',
        name: 'DatabaseHelper',
      );

      final now = DateTime.now().toIso8601String();
      final random = math.Random(); // <-- USANDO math.Random() AQUI

      // Distribuir todos os alunos pelas turmas de forma mais dinâmica
      // Cada aluno será adicionado a uma turma aleatória
      // Certifique-se de que classeIds não está vazia e activeClassesCount é válido
      if (classeIds.isNotEmpty) {
        // Obter apenas os IDs das turmas ativas que serão usadas para distribuição principal
        final List<int> activeClasseIdsForDistribution = classeIds.sublist(
          0,
          classeIds.length - (classeIds.contains(archivedClasseId) ? 1 : 0),
        );

        if (activeClasseIdsForDistribution.isNotEmpty) {
          for (int i = 0; i < studentIds.length; i++) {
            final int studentId = studentIds[i];
            // Escolhe uma turma aleatória dentre as turmas ativas para distribuição
            final int randomClasseIndex = random.nextInt(
              activeClasseIdsForDistribution.length,
            );
            final int classeIdToAssign =
                activeClasseIdsForDistribution[randomClasseIndex];

            await db.insert('classe_student', {
              'student_id': studentId,
              'classe_id': classeIdToAssign,
              'start_date': '2024-02-01', // Data de início padrão
              'active': 1,
              'created_at': now,
            });
          }
          log(
            'DatabaseHelper._createTablesAndPopulateData - Todos os ${studentIds.length} alunos distribuídos pelas ${activeClasseIdsForDistribution.length} turmas ativas.',
            name: 'DatabaseHelper',
          );
        } else {
          log(
            'DatabaseHelper._createTablesAndPopulateData - Nenhuma turma ativa para distribuir alunos.',
            name: 'DatabaseHelper',
          );
        }
      } else {
        log(
          'DatabaseHelper._createTablesAndPopulateData - Nenhuma turma criada, alunos não serão distribuídos.',
          name: 'DatabaseHelper',
        );
      }

      // Opcional: Adicionar alguns alunos à turma antiga para fins de teste
      // Encontra o ID da turma arquivada de forma mais segura
      int? finalArchivedClasseId;
      // Busca pelo ID da turma arquivada na lista de classeIds, garantindo que existe
      if (classeIds.isNotEmpty && classeIds.last == archivedClasseId) {
        finalArchivedClasseId = archivedClasseId;
      }

      if (finalArchivedClasseId != null) {
        log(
          'DatabaseHelper._createTablesAndPopulateData - Adicionando alguns alunos à turma arquivada.',
          name: 'DatabaseHelper',
        );
        for (int i = 0; i < 5 && i < studentIds.length; i++) {
          // Adiciona os 5 primeiros alunos à turma antiga
          await db.insert('classe_student', {
            'student_id': studentIds[i],
            'classe_id': finalArchivedClasseId,
            'start_date': '2023-02-01',
            'end_date': '2023-12-31',
            'active': 0, // Inativo para turma antiga
            'created_at': now,
          });
        }
        log(
          'DatabaseHelper._createTablesAndPopulateData - Alunos adicionados à turma arquivada.',
          name: 'DatabaseHelper',
        );
      }

      // Recupera IDs das disciplinas
      log(
        'DatabaseHelper._createTablesAndPopulateData - Recuperando IDs das disciplinas para horários.',
        name: 'DatabaseHelper',
      );
      final List<Map<String, dynamic>> disciplines = await db.query(
        'discipline',
      );
      final int? portuguesId =
          disciplines.firstWhereOrNull((d) => d['name'] == 'Português')?['id']
              as int?;
      final int? matematicaId =
          disciplines.firstWhereOrNull((d) => d['name'] == 'Matemática')?['id']
              as int?;
      final int? historiaId =
          disciplines.firstWhereOrNull((d) => d['name'] == 'História')?['id']
              as int?;
      final int? cienciasId =
          disciplines.firstWhereOrNull((d) => d['name'] == 'Ciências')?['id']
              as int?;
      final int? geografiaId =
          disciplines.firstWhereOrNull((d) => d['name'] == 'Geografia')?['id']
              as int?;
      final int? inglesId =
          disciplines.firstWhereOrNull((d) => d['name'] == 'Inglês')?['id']
              as int?;
      final int? artesId =
          disciplines.firstWhereOrNull((d) => d['name'] == 'Artes')?['id']
              as int?;
      final int? edFisicaId =
          disciplines.firstWhereOrNull(
                (d) => d['name'] == 'Educação Física',
              )?['id']
              as int?;
      log(
        'DatabaseHelper._createTablesAndPopulateData - IDs das disciplinas recuperados.',
        name: 'DatabaseHelper',
      );

      // Grade
      log(
        'DatabaseHelper._createTablesAndPopulateData - Criando tabela grade.',
        name: 'DatabaseHelper',
      );
      await db.execute('''
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
      ''');
      log(
        'DatabaseHelper._createTablesAndPopulateData - Tabela grade criada. Inserindo horários de exemplo.',
        name: 'DatabaseHelper',
      );

      final List<Map<String, dynamic>> gradeData = [
        // Adicionando mais horários para as novas turmas e disciplinas
        // Certifique-se de que classeIds possui índices válidos para essas turmas.
        // Por exemplo, classeIds[0] até classeIds[classeIds.length - 2] para turmas ativas.
        if (classeIds.length > 0) ...[
          {
            'classe_id': classeIds[0],
            'discipline_id': portuguesId,
            'day': 2,
            'start': '08:00',
            'end': '09:00',
            'year': currentYear,
          },
          {
            'classe_id': classeIds[0],
            'discipline_id': matematicaId,
            'day': 3,
            'start': '09:00',
            'end': '10:00',
            'year': currentYear,
          },
        ],
        if (classeIds.length > 1) ...[
          {
            'classe_id': classeIds[1],
            'discipline_id': cienciasId,
            'day': 4,
            'start': '10:00',
            'end': '11:00',
            'year': currentYear,
          },
          {
            'classe_id': classeIds[1],
            'discipline_id': historiaId,
            'day': 5,
            'start': '11:00',
            'end': '12:00',
            'year': currentYear,
          },
        ],
        if (classeIds.length > 2) ...[
          {
            'classe_id': classeIds[2],
            'discipline_id': geografiaId,
            'day': 2,
            'start': '13:00',
            'end': '14:00',
            'year': currentYear,
          },
          {
            'classe_id': classeIds[2],
            'discipline_id': inglesId,
            'day': 3,
            'start': '14:00',
            'end': '15:00',
            'year': currentYear,
          },
        ],
        if (classeIds.length > 3) ...[
          {
            'classe_id': classeIds[3],
            'discipline_id': artesId,
            'day': 4,
            'start': '08:30',
            'end': '09:30',
            'year': currentYear,
          },
          {
            'classe_id': classeIds[3],
            'discipline_id': edFisicaId,
            'day': 5,
            'start': '09:30',
            'end': '10:30',
            'year': currentYear,
          },
        ],
        // Exemplo para uma turma do ensino médio (classeIds.length - 2 é a penúltima turma, que deve ser a última do ensino médio adicionada)
        if (classeIds.length > 1) ...[
          // Garante que há pelo menos uma turma ativa e a arquivada
          {
            'classe_id': classeIds[classeIds.length - 2],
            'discipline_id': portuguesId,
            'day': 2,
            'start': '08:00',
            'end': '09:30',
            'year': currentYear + 1,
          },
          {
            'classe_id': classeIds[classeIds.length - 2],
            'discipline_id': matematicaId,
            'day': 3,
            'start': '09:30',
            'end': '11:00',
            'year': currentYear + 1,
          },
        ],
        // Turma Antiga
        if (finalArchivedClasseId != null) ...[
          {
            'classe_id': finalArchivedClasseId,
            'discipline_id': portuguesId,
            'day': 5,
            'start': '10:00',
            'end': '12:00',
            'year': 2023,
            'active': 0,
          },
        ],
      ];

      final List<int> gradeIds = [];
      for (var g in gradeData) {
        final id = await db.insert('grade', {
          'classe_id': g['classe_id'],
          'discipline_id': g['discipline_id'],
          'day_of_week': g['day'],
          'start_time': g['start'],
          'end_time': g['end'],
          'grade_year': g['year'],
          'active': g.containsKey('active') ? g['active'] : 1,
          'created_at': now,
        });
        gradeIds.add(id);
      }
      log(
        'DatabaseHelper._createTablesAndPopulateData - Horários de exemplo inseridos. Total: ${gradeIds.length} horários.',
        name: 'DatabaseHelper',
      );

      // Attendance
      log(
        'DatabaseHelper._createTablesAndPopulateData - Criando tabela attendance.',
        name: 'DatabaseHelper',
      );
      await db.execute('''
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
      ''');
      log(
        'DatabaseHelper._createTablesAndPopulateData - Tabela attendance criada. Inserindo chamadas de exemplo.',
        name: 'DatabaseHelper',
      );

      final String today = DateTime.now().toIso8601String().substring(0, 10);
      final String yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .substring(0, 10);
      final String twoDaysAgo = DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String()
          .substring(0, 10);

      final List<int> attendanceIds = [];
      // Garante que gradeIds tenha elementos para evitar RangeError
      if (gradeIds.isNotEmpty && classeIds.isNotEmpty) {
        attendanceIds.add(
          await db.insert('attendance', {
            'classe_id': classeIds[0],
            'grade_id': gradeIds[0],
            'date': today,
            'content':
                'Conteúdo da aula de Português: Gramática e Interpretação.',
            'created_at': now,
          }),
        );
      }
      if (gradeIds.length > 2 && classeIds.length > 1) {
        // Garante que gradeIds[2] e classeIds[1] existam
        attendanceIds.add(
          await db.insert('attendance', {
            'classe_id': classeIds[1],
            'grade_id': gradeIds[2],
            'date': yesterday,
            'content': 'Conteúdo da aula de Ciências: Ecossistemas.',
            'created_at': now,
          }),
        );
      }
      if (gradeIds.length > 1 && classeIds.length > 0) {
        // Garante que gradeIds[1] e classeIds[0] existam
        attendanceIds.add(
          await db.insert('attendance', {
            'classe_id': classeIds[0],
            'grade_id': gradeIds[1],
            'date': twoDaysAgo,
            'content': 'Conteúdo da aula de Matemática: Operações básicas.',
            'created_at': now,
          }),
        );
      }
      if (gradeIds.length > 6 && classeIds.length > 9) {
        // Garante que gradeIds[6] e classeIds[9] existam (para turmas do médio)
        attendanceIds.add(
          await db.insert('attendance', {
            'classe_id': classeIds[9],
            'grade_id': gradeIds[6],
            'date': today,
            'content':
                'Conteúdo da aula de Português: Redação e Gêneros Textuais.',
            'created_at': now,
          }),
        );
      }
      log(
        'DatabaseHelper._createTablesAndPopulateData - Chamadas de exemplo inseridas. Total: ${attendanceIds.length} chamadas.',
        name: 'DatabaseHelper',
      );

      // Student Attendance
      log(
        'DatabaseHelper._createTablesAndPopulateData - Criando tabela student_attendance.',
        name: 'DatabaseHelper',
      );
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
      log(
        'DatabaseHelper._createTablesAndPopulateData - Tabela student_attendance criada. Populando presenças/faltas.',
        name: 'DatabaseHelper',
      );

      for (final attId in attendanceIds) {
        log(
          'DatabaseHelper._createTablesAndPopulateData - Populando presenças para chamada ID: $attId.',
          name: 'DatabaseHelper',
        );
        final List<Map<String, dynamic>> attendanceRecord = await db.query(
          'attendance',
          where: 'id = ?',
          whereArgs: [attId],
        );
        if (attendanceRecord.isNotEmpty) {
          final int classeId = attendanceRecord[0]['classe_id'] as int;
          // Obter todos os alunos atualmente ativos na classe especificada
          final List<Map<String, dynamic>> studentsInClass = await db.rawQuery(
            '''
            SELECT s.id FROM student s
            INNER JOIN classe_student cs ON s.id = cs.student_id
            WHERE cs.classe_id = ? AND cs.active = 1 AND s.active = 1;
            ''',
            [classeId],
          );

          for (int i = 0; i < studentsInClass.length; i++) {
            final int studentId = studentsInClass[i]['id'] as int;
            final int presence = (i % 5 == 0)
                ? 0
                : 1; // 1 em cada 5 alunos estará ausente
            await db.insert('student_attendance', {
              'attendance_id': attId,
              'student_id': studentId,
              'presence': presence,
              'active': 1,
              'created_at': now,
            });
          }
          log(
            'DatabaseHelper._createTablesAndPopulateData - ${studentsInClass.length} alunos processados para chamada ID: $attId.',
            name: 'DatabaseHelper',
          );
        } else {
          log(
            'DatabaseHelper._createTablesAndPopulateData - Nenhum registro de chamada encontrado para ID: $attId. Pulando populamento de student_attendance.',
            name: 'DatabaseHelper',
          );
        }
      }
      log(
        'DatabaseHelper._createTablesAndPopulateData - Populamento de student_attendance concluído.',
        name: 'DatabaseHelper',
      );
      await db.execute('''CREATE TABLE homework (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  classe_id INTEGER NOT NULL,
  discipline_id INTEGER,
  title TEXT NOT NULL,
  description TEXT,
  due_date TEXT NOT NULL,
  assigned_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status TEXT NOT NULL DEFAULT 'pending', -- ex: 'pending', 'completed', 'cancelled'
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  active INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (classe_id) REFERENCES classe(id) ON DELETE CASCADE,
  FOREIGN KEY (discipline_id) REFERENCES discipline(id) ON DELETE SET NULL
);'''); // Garante que as chaves estrangeiras estejam ativas após o populamento

      // Occurrence
      log(
        'DatabaseHelper._createTablesAndPopulateData - Criando tabela occurrence.',
        name: 'DatabaseHelper',
      );
      await db.execute('''
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
      ''');
      log(
        'DatabaseHelper._createTablesAndPopulateData - Tabela occurrence criada. Inserindo ocorrências de exemplo.',
        name: 'DatabaseHelper',
      );

      if (attendanceIds.isNotEmpty && studentIds.isNotEmpty) {
        // Garante que há dados para referenciar
        final List<Map<String, dynamic>>
        firstAttendanceStudents = await db.rawQuery(
          'SELECT student_id FROM student_attendance WHERE attendance_id = ? LIMIT 1',
          [attendanceIds[0]],
        );
        if (firstAttendanceStudents.isNotEmpty) {
          final int studentIdForOccurrence =
              firstAttendanceStudents[0]['student_id'] as int;
          await db.insert('occurrence', {
            'attendance_id': attendanceIds[0],
            'student_id': studentIdForOccurrence,
            'occurrence_type': 'Comportamento',
            'description':
                'Aluno apresentou comportamento inadequado durante a aula.',
            'occurrence_date': today,
            'created_at': now,
          });
          log(
            'DatabaseHelper._createTablesAndPopulateData - Ocorrência de comportamento para aluno ${studentIdForOccurrence} na chamada ${attendanceIds[0]} inserida.',
            name: 'DatabaseHelper',
          );
        }

        if (attendanceIds.length > 1) {
          await db.insert('occurrence', {
            'attendance_id': attendanceIds[1],
            'student_id': null,
            'occurrence_type': 'Geral',
            'description':
                'Atraso na entrega de atividades por parte de alguns alunos.',
            'occurrence_date': yesterday,
            'created_at': now,
          });
          log(
            'DatabaseHelper._createTablesAndPopulateData - Ocorrência geral para chamada ${attendanceIds[1]} inserida.',
            name: 'DatabaseHelper',
          );
        }
      } else {
        log(
          'DatabaseHelper._createTablesAndPopulateData - Sem IDs de chamadas ou alunos para inserir ocorrências de exemplo.',
          name: 'DatabaseHelper',
        );
      }
      log(
        'DatabaseHelper._createTablesAndPopulateData - Populamento de ocorrências concluído.',
        name: 'DatabaseHelper',
      );

      log(
        'DatabaseHelper._createTablesAndPopulateData - Conclusão da criação e populamento de dados.',
        name: 'DatabaseHelper',
      );
    } catch (e, s) {
      log(
        'DatabaseHelper._createTablesAndPopulateData - Erro FATAL durante criação/populamento: $e',
        name: 'DatabaseHelper',
        error: e,
        stackTrace: s,
      );
      rethrow; // Re-lança o erro para o onUpgrade/onCreate
    }
  }

  Future<void> close() async {
    log(
      'DatabaseHelper.close - Fechando o banco de dados.',
      name: 'DatabaseHelper',
    );
    try {
      final db = await instance.database;
      await db.close();
      _database = null;
      log(
        'DatabaseHelper.close - Banco de dados fechado com sucesso.',
        name: 'DatabaseHelper',
      );
    } catch (e, s) {
      log(
        'DatabaseHelper.close - Erro ao fechar o banco de dados: $e',
        name: 'DatabaseHelper',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
