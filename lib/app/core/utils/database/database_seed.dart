import 'package:sqflite/sqflite.dart';

class DatabaseSeed {
  static Future<void> insertInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();
    final currentYear = DateTime.now().year;

    final List<String> defaultDisciplines = [
      'Português',
      'Matemática',
      'Biologia',
      'Física',
      'Química',
      'História',
      'Ciências',
      'Geografia',
      'Inglês',
      'Artes',
      'Educação Física',
    ];

    final List<int> disciplineIds = [];
    final Map<String, int> disciplineNameToId = {};
    for (String name in defaultDisciplines) {
      final int id = await db.insert('discipline', {'name': name, 'active': 1});
      disciplineIds.add(id);
      disciplineNameToId[name] = id;
    }

    final int biologiaId = disciplineNameToId['Biologia']!;
    final int matematicaId = disciplineNameToId['Matemática']!;
    final int portuguesId = disciplineNameToId['Português']!;
    final int historiaId = disciplineNameToId['História']!;
    final int fisicaId = disciplineNameToId['Física']!;

    final List<int> classeIds = [];
    final Map<String, int> classeNameToId = {};

    final List<Map<String, String>> classes = [
      {'name': '1º Ano A', 'description': 'Turma 1A do ensino médio'},
      {'name': '1º Ano B', 'description': 'Turma 1B do ensino médio'},
      {'name': '2º Ano A', 'description': 'Turma 2A do ensino médio'},
      {'name': '2º Ano B', 'description': 'Turma 2B do ensino médio'},
      {'name': '3º Ano', 'description': 'Turma 3 do ensino médio'},
    ];

    for (final classInfo in classes) {
      final int classeId = await db.insert('classe', {
        'name': classInfo['name'],
        'description': classInfo['description'],
        'school_year': currentYear,
        'active': 1,
        'created_at': now,
      });
      classeIds.add(classeId);
      classeNameToId[classInfo['name']!] = classeId;
    }

    final List<Map<String, dynamic>> scheduleData = [
      {
        'classe_id': classeNameToId['3º Ano']!,
        'day': 1,
        'start': '07:00',
        'end': '07:50',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['3º Ano']!,
        'day': 1,
        'start': '07:50',
        'end': '08:40',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['1º Ano B']!,
        'day': 1,
        'start': '08:40',
        'end': '09:30',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['2º Ano B']!,
        'day': 1,
        'start': '09:50',
        'end': '10:40',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['2º Ano B']!,
        'day': 1,
        'start': '10:40',
        'end': '11:30',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['2º Ano A']!,
        'day': 1,
        'start': '11:30',
        'end': '12:20',
        'discipline_id': biologiaId,
      },

      {
        'classe_id': classeNameToId['1º Ano A']!,
        'day': 3,
        'start': '07:00',
        'end': '07:50',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['2º Ano A']!,
        'day': 3,
        'start': '07:50',
        'end': '08:40',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['2º Ano A']!,
        'day': 3,
        'start': '08:40',
        'end': '09:30',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['3º Ano']!,
        'day': 3,
        'start': '09:50',
        'end': '10:40',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['2º Ano B']!,
        'day': 3,
        'start': '10:40',
        'end': '11:30',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['1º Ano A']!,
        'day': 3,
        'start': '11:30',
        'end': '12:20',
        'discipline_id': biologiaId,
      },

      {
        'classe_id': classeNameToId['1º Ano A']!,
        'day': 5,
        'start': '07:50',
        'end': '08:40',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['1º Ano A']!,
        'day': 5,
        'start': '08:40',
        'end': '09:30',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['3º Ano']!,
        'day': 5,
        'start': '09:50',
        'end': '10:40',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['1º Ano B']!,
        'day': 5,
        'start': '10:40',
        'end': '11:30',
        'discipline_id': biologiaId,
      },
      {
        'classe_id': classeNameToId['1º Ano B']!,
        'day': 5,
        'start': '11:30',
        'end': '12:20',
        'discipline_id': biologiaId,
      },
    ];

    final List<int> scheduleIds = [];
    final Map<String, int> scheduleIdMap =
        {}; 

    for (final scheduleDataEntry in scheduleData) {
      final int scheduleId = await db.insert('schedule', {
        'classe_id': scheduleDataEntry['classe_id'],
        'discipline_id': scheduleDataEntry['discipline_id'],
        'day_of_week': scheduleDataEntry['day'],
        'start_time': scheduleDataEntry['start'],
        'end_time': scheduleDataEntry['end'],
        'schedule_year': currentYear,
        'active': 1,
        'created_at': now,
      });
      scheduleIds.add(scheduleId);

      
      final String scheduleKey =
          "${scheduleDataEntry['classe_id']}_${scheduleDataEntry['day']}_${scheduleDataEntry['start']}";
      scheduleIdMap[scheduleKey] = scheduleId;
    }

    final List<String> students1A = [
      'Alexandre Pithon Vranjac',
      'Bárbara Evangelista Araujo do Carmo',
      'Carolina Tropiano dos Santos',
      'Caroline Akemi Ohonishi',
      'Gabriel Dias Camargo',
      'Gabrielle Nogueira Calvo',
      'Giovanni de Oliveira Freitas',
      'Guilherme Kobayashi Takehana',
      'Henrique Noah Novais de Araujo',
      'Isabella Lelis Trida Nogueira Gonçalves',
      'Isabelle Teles Rosa',
      'Juliana Bernardes Arnaut',
      'Lara Rodrigues Duarte',
      'Laura Letícia Alves Ferreira dos Santos',
      'Leonardo Granados Furian',
      'Lucas Capucho Leite',
      'Lucas Yamamoto Ribeiro',
      'Maria Eduarda Machado Nievola',
      'Maria Julia Morilla Soares',
      'Mariana Heins Stivanelli',
      'Matheus Hiroshi Ferreira Maruiti',
      'Nicolas Alves Guinè',
      'Nícolas Carreira de Macedo',
      'Octavio da Silva Ribeiro',
      'Paulo Vinícius Fernandes Pereira',
      'Pedro Augusto Rodrigues Vieira',
      'Pedro Henrique Pestana Amaral',
      'Pedro Rocha Veríssimo',
      'Pietro de Castro Silva',
      'Rihanna Amaro Avila',
      'Sophia Caçador Botelho',
      'Vitor Paiva Vieira',
      'Yan Machado Couto Oliveira',
    ];

    
    final Set<String> uniqueStudents1A = {};
    final List<String> duplicateStudents1A = [];
    for (final name in students1A) {
      if (!uniqueStudents1A.add(name)) {
        
        duplicateStudents1A.add(name);
      }
    }

    final List<String> students1B = [
      'Alda Lorena Miranda Ferreira',
      'Aline Cristina do Nascimento Cavalcanti',
      'Amanda Vasques Santos',
      'Arthur Moino Alencar',
      'Brenno Kuusberg Elias da Silva',
      'Bruno Valente de Mendonça Gomes',
      'Caio Vieira Fernandes Teixeira',
      'Clara Beatriz Ventura da Silva',
      'Daniel Greco Morgado Batista',
      'Davi Cypriani de Oliveira Ruela',
      'Enzo Tamari de Zagiacomo',
      'Felipe Melo Moreira',
      'Gabriel de Almeida Shimanoue',
      'Gabriela Xavier Luiz',
      'Gabriella Braga Arias',
      'Giovani Donato',
      'Giovanna Rafaela Treco',
      'Guilherme Pelege Figueira',
      'Guilherme Yuji Hirata',
      'Isabela da Silva Brito',
      'Júlia Santos Krasauskas',
      'Leonardo Augusto de Paula',
      'Luisa Rodrigues Duarte',
      'Marcella Nascimento Fernandes',
      'Marina Kawamura Nascimento',
      'Penelope Munick Lobeu',
      'Pietro Borges Zázzer',
      'Rafael Keluy Attia do Nascimento',
      'Sarah Saturnino Loiola',
      'Sofia Bottaro',
      'Theo Henrique Rodrigues Marino',
    ];

    final List<String> students2A = [
      'Agatha Martinez Korosue',
      'Alessandra Primolan Romio',
      'Ana Luiza Jeske Levino',
      'Anna Carolina Franco Prates',
      'Bruna Evaristo Quejo',
      'Fernando Januario de Andrade',
      'Gabriel Marques dos Santos',
      'Gabriel Santos Alves',
      'Giovanna Soares de Oliveira',
      'Hector Miguel Fagundes de Lima',
      'Heitor Moretti Pinheiro',
      'Helena Sanches Monteiro',
      'Heloisa Regina Araujo Alves',
      'Jade Silva Tomé',
      'João Gabriel de Almeida Camilo',
      'Julia Yukimi Yamashita',
      'Karina Almeida Ferreira da Silva',
      'Livia Carrijo Yamashiro',
      'Lucas Moraes Beeppler',
      'Lucca Rodrigues Duarte',
      'Luiza Melo Rodrigues',
      'Maria Eduarda Rodrigues Pereira',
      'Nina Tangari de Oliveira',
      'Pedro Santos Alves',
      'Thiago Uehara Tavares',
      'Yasmin Duarte Melo Longue',
    ];

    final List<String> students2B = [
      'Alex Leme Tiba',
      'Arthur Arruda Grigoli',
      'Arthur Branco Santos',
      'Arthur Izidio de Oliveira Ramalho',
      'Arthur Moretti Pinheiro',
      'Artur Andrade Cavalheiro Lima',
      'Beatriz da Silva Jacobina Santos',
      'Bianca Teixeira Gonella da Silva',
      'Carolina Cunha Mardegan',
      'Fellipe Eiji Mizushima',
      'Gabriela Stella Ortelan',
      'Giovanna Flora Rocha Porto',
      'Giovanna Yumi Pak',
      'Giulia Vieira Fernandes Teixeira',
      'Heloisa Diniz Souza Macedo',
      'Henrique Mota e Silva',
      'Isabella Magila Kilian',
      'Lucas Bastos Soares',
      'Manuela Licciardi Ferreira Palmeira',
      'Marcela Pires Dias',
      'Maria Julia Pestana Amaral',
      'Matteo Pereira de Francesco',
      'Pamella Loyolla Rocha de Sousa',
      'Pedro Antunes de Souza',
      'Pedro Luiz Santos Magalhães',
      'Sophia Almeida Sousa',
      'Talita Yumi Pires Sato',
    ];

    final List<String> students3 = [
      'Ana Beatriz Vieira Aguilar',
      'Ana Vitoria Pena Ferraz',
      'Arthur Caram Fiorese Herrada',
      'Beatriz de Oliveira Trevisan',
      'Beatriz Lourenço do Poço',
      'Bruno Kazuya Takinami',
      'Carolina Paschoa Barbosa',
      'Eduardo Mamede Oliveira',
      'Felipe Alves Andretta',
      'Felipe Castilhioni de Andrade',
      'Felipe Motitsuki Tan',
      'Fernando Hideki Takano',
      'Gabriela Pithon Vranjac',
      'Gabriella de Souza Cabral',
      'Giovana Ribeiro Mota',
      'Grazielly Victoria dos Santos da Silva',
      'Isabela Dias Siqueira',
      'Isabela Yumi Lima',
      'Isabella Gomes Rodrigues',
      'Isabella Telles de Oliveira',
      'Julia Cardoso de Oliveira Ferreira',
      'Julia Wietholter Vancin',
      'Laura Cristina Costa',
      'Laura Souza Araujo Lima',
      'Leandro Tamarindo Dias',
      'Leonardo Amora da Fonseca',
      'Lucas Amora da Fonseca',
      'Manuela Nascimento Leonardi',
      'Maria Clara Mendes de Oliveira',
      'Maria Fernanda Lourenço Silva',
      'Maria Fernanda Rodrigues Barreto',
      'Maria Fernanda Souza Barbosa',
      'Maria Paula Serafim Furtado',
      'Mariane Sousa Ferrara',
      'Mel Novais de Araujo',
      'Murilo de Oliveira Correa',
      'Murilo Rufino Santos',
      'Natalia Pereira Lanza',
      'Otavio Fernandes Virgilio',
      'Pedro Mattos Toledo Ribeiro',
      'Sabryna Deboni de Souza',
      'Thiago Motitsuki Tan',
      'Thiago Vinicius Franco de Queiroz Custodio Leves',
      'Vinicius Pacheco Araujo',
    ];

    final Map<String, List<int>> classeStudentIds = {
      '1º Ano A': [],
      '1º Ano B': [],
      '2º Ano A': [],
      '2º Ano B': [],
      '3º Ano': [],
    };

    if (classeNameToId.containsKey('1º Ano A')) {
      final int classe1AId = classeNameToId['1º Ano A']!;
      for (String studentName in students1A) {
        final int studentId = await db.insert('student', {
          'name': studentName,
          'active': 1,
          'created_at': now,
        });

        await db.insert('classe_student', {
          'student_id': studentId,
          'classe_id': classe1AId,
          'start_date': '2024-02-01',
          'active': 1,
          'created_at': now,
        });

        classeStudentIds['1º Ano A']!.add(studentId);
      }
    }

    if (classeNameToId.containsKey('1º Ano B')) {
      final int classe1BId = classeNameToId['1º Ano B']!;
      for (String studentName in students1B) {
        final int studentId = await db.insert('student', {
          'name': studentName,
          'active': 1,
          'created_at': now,
        });

        await db.insert('classe_student', {
          'student_id': studentId,
          'classe_id': classe1BId,
          'start_date': '2024-02-01',
          'active': 1,
          'created_at': now,
        });

        classeStudentIds['1º Ano B']!.add(studentId);
      }
    }

    if (classeNameToId.containsKey('2º Ano A')) {
      final int classe2AId = classeNameToId['2º Ano A']!;
      for (String studentName in students2A) {
        final int studentId = await db.insert('student', {
          'name': studentName,
          'active': 1,
          'created_at': now,
        });

        await db.insert('classe_student', {
          'student_id': studentId,
          'classe_id': classe2AId,
          'start_date': '2024-02-01',
          'active': 1,
          'created_at': now,
        });

        classeStudentIds['2º Ano A']!.add(studentId);
      }
    }

    if (classeNameToId.containsKey('2º Ano B')) {
      final int classe2BId = classeNameToId['2º Ano B']!;
      for (String studentName in students2B) {
        final int studentId = await db.insert('student', {
          'name': studentName,
          'active': 1,
          'created_at': now,
        });

        await db.insert('classe_student', {
          'student_id': studentId,
          'classe_id': classe2BId,
          'start_date': '2024-02-01',
          'active': 1,
          'created_at': now,
        });

        classeStudentIds['2º Ano B']!.add(studentId);
      }
    }

    if (classeNameToId.containsKey('3º Ano')) {
      final int classe3AnoId = classeNameToId['3º Ano']!;
      for (String studentName in students3) {
        int studentId;
        final existingStudent = await db.query(
          'student',
          where: 'name = ?',
          whereArgs: [studentName],
        );
        if (existingStudent.isNotEmpty) {
          studentId = existingStudent.first['id'] as int;
        } else {
          studentId = await db.insert('student', {
            'name': studentName,
            'active': 1,
            'created_at': now,
          });
        }

        await db.insert('classe_student', {
          'student_id': studentId,
          'classe_id': classe3AnoId,
          'start_date': '2024-02-01',
          'active': 1,
          'created_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        classeStudentIds['3º Ano']!.add(studentId);
      }

      final List<Map<String, dynamic>> homeworksToInsert = [];

      if (classeNameToId.containsKey('1º Ano A')) {
        final int classe1AId = classeNameToId['1º Ano A']!;
        homeworksToInsert.add({
          'classe_id': classe1AId,
          'discipline_id': portuguesId,
          'title': 'Redação sobre o Meio Ambiente',
          'description':
              'Escrever uma redação dissertativa-argumentativa sobre a importância da preservação ambiental.',
          'due_date': DateTime.now()
              .add(const Duration(days: 5))
              .toIso8601String()
              .split('T')[0],
          'status': 'pending',
          'assigned_date': now, 
          'created_at': now,
          'active': 1,
        });
        homeworksToInsert.add({
          'classe_id': classe1AId,
          'discipline_id': matematicaId,
          'title': 'Exercícios de Álgebra Linear',
          'description':
              'Capítulos 1 a 3 do livro didático, exercícios ímpares.',
          'due_date': DateTime.now()
              .add(const Duration(days: 10))
              .toIso8601String()
              .split('T')[0],
          'status': 'pending',
          'assigned_date': now, 
          'created_at': now,
          'active': 1,
        });
        homeworksToInsert.add({
          'classe_id': classe1AId,
          'discipline_id': portuguesId,
          'title': 'Leitura e Análise de "Dom Casmurro"',
          'description':
              'Ler os capítulos 1-10 e fazer um resumo dos personagens principais.',
          'due_date': DateTime.now()
              .subtract(const Duration(days: 7))
              .toIso8601String()
              .split('T')[0],
          'status': 'pending',
          'assigned_date': now, 
          'created_at': now,
          'active': 1,
        });
        homeworksToInsert.add({
          'classe_id': classe1AId,
          'discipline_id': matematicaId,
          'title': 'Prova de Recuperação de Funções',
          'description':
              'Revisar todo o conteúdo de funções para a prova do dia 15/07.',
          'due_date': DateTime.now()
              .add(const Duration(days: 15))
              .toIso8601String()
              .split('T')[0],
          'status': 'pending',
          'assigned_date': now, 
          'created_at': now,
          'active': 1,
        });
      }

      if (classeNameToId.containsKey('2º Ano A')) {
        final int classe2AId = classeNameToId['2º Ano A']!;
        homeworksToInsert.add({
          'classe_id': classe2AId,
          'discipline_id': biologiaId,
          'title': 'Pesquisa sobre Ecossistemas Brasileiros',
          'description':
              'Apresentar um trabalho sobre um bioma brasileiro à escolha.',
          'due_date': DateTime.now()
              .add(const Duration(days: 12))
              .toIso8601String()
              .split('T')[0],
          'status': 'pending',
          'assigned_date': now, 
          'created_at': now,
          'active': 1,
        });
        homeworksToInsert.add({
          'classe_id': classe2AId,
          'discipline_id': historiaId,
          'title': 'Seminário sobre a Revolução Industrial',
          'description': 'Dividir em grupos e preparar a apresentação.',
          'due_date': DateTime.now()
              .add(const Duration(days: 20))
              .toIso8601String()
              .split('T')[0],
          'status': 'pending',
          'assigned_date': now, 
          'created_at': now,
          'active': 1,
        });
        homeworksToInsert.add({
          'classe_id': classe2AId,
          'discipline_id': biologiaId,
          'title': 'Relatório de Laboratório: Mitose e Meiose',
          'description':
              'Descrever os resultados da observação microscópica e análise.',
          'due_date': DateTime.now()
              .add(const Duration(days: 3))
              .toIso8601String()
              .split('T')[0],
          'status': 'pending',
          'assigned_date': now, 
          'created_at': now,
          'active': 1,
        });
      }

      if (classeNameToId.containsKey('3º Ano')) {
        final int classe3AnoId = classeNameToId['3º Ano']!;
        homeworksToInsert.add({
          'classe_id': classe3AnoId,
          'discipline_id': fisicaId,
          'title': 'Resolução de Problemas de Eletricidade',
          'description':
              'Lista de exercícios complementares sobre circuitos elétricos.',
          'due_date': DateTime.now()
              .add(const Duration(days: 7))
              .toIso8601String()
              .split('T')[0],
          'status': 'pending',
          'assigned_date': now, 
          'created_at': now,
          'active': 1,
        });
        homeworksToInsert.add({
          'classe_id': classe3AnoId,
          'discipline_id': fisicaId,
          'title': 'Simulado ENEM: Parte de Física',
          'description': 'Realizar o simulado online disponível na plataforma.',
          'due_date': DateTime.now()
              .add(const Duration(days: 2))
              .toIso8601String()
              .split('T')[0],
          'status': 'pending',
          'assigned_date': now, 
          'created_at': now,
          'active': 1,
        });
      }

      for (final homeworkData in homeworksToInsert) {
        await db.insert('homework', homeworkData);
      }

      final Map<String, List<int>> classeAttendanceIds = {
        '1º Ano A': [],
        '1º Ano B': [],
        '2º Ano A': [],
        '2º Ano B': [],
        '3º Ano': [],
      };

      final Map<int, List<int>> attendanceStudentMap = {};

      
      for (int weekOffset = 0; weekOffset < 4; weekOffset++) {
        for (final scheduleEntry in scheduleData) {
          final int classeId = scheduleEntry['classe_id'];
          final int dayOfWeek = scheduleEntry['day'];

          
          final String scheduleKey =
              "${scheduleEntry['classe_id']}_${scheduleEntry['day']}_${scheduleEntry['start']}";
          final int scheduleId = scheduleIdMap[scheduleKey] ?? scheduleIds[0];

          final String classeName = classes.firstWhere(
            (c) => classeNameToId[c['name']] == classeId,
          )['name']!;

          
          final DateTime now = DateTime.now();
          final DateTime thisWeek = now.subtract(
            Duration(days: now.weekday - 1),
          ); 
          final DateTime classDate = thisWeek
              .subtract(Duration(days: 7 * weekOffset))
              .add(Duration(days: dayOfWeek - 1));

          
          final List<Map<String, dynamic>> existingAttendance = await db.query(
            'attendance',
            where: 'classe_id = ? AND schedule_id = ? AND date = ?',
            whereArgs: [
              classeId,
              scheduleId,
              classDate.toIso8601String().split('T')[0],
            ],
          );

          
          if (existingAttendance.isEmpty) {
            // Conteúdos de biologia realistas
            final List<String> biologyContents = [
              'Introdução à Citologia: Estrutura e função das células',
              'Genética Mendeliana: Leis de Mendel e herança genética',
              'Ecologia: Cadeias alimentares e relações ecológicas',
              'Fisiologia Humana: Sistema digestório e respiratório',
              'Evolução: Teoria da evolução e seleção natural',
              'Botânica: Estrutura das plantas e fotossíntese',
              'Microbiologia: Vírus, bactérias e vacinas',
              'Zoologia: Classificação dos animais vertebrados',
              'Biotecnologia: Engenharia genética e transgênicos',
              'Imunologia: Resposta imune e vacinas',
              'Embriologia: Desenvolvimento embrionário',
              'Parasitologia: Principais parasitos humanos',
              'Genética Molecular: DNA, RNA e síntese proteica',
              'Ecossistemas brasileiros: Mata Atlântica e Cerrado',
              'Sustentabilidade e impactos ambientais',
            ];
            final int contentIndex = (weekOffset * scheduleData.length + scheduleData.indexOf(scheduleEntry)) % biologyContents.length;
            final String content = biologyContents[contentIndex];
            final int attendanceId = await db.insert('attendance', {
              'classe_id': classeId,
              'schedule_id': scheduleId,
              'date': classDate.toIso8601String().split('T')[0],
              'content': content,
              'active': 1,
              'created_at': now.toIso8601String(),
            });

            classeAttendanceIds[classeName]!.add(attendanceId);
            attendanceStudentMap[attendanceId] = [];

            
            final List<int> studentIds = classeStudentIds[classeName] ?? [];
            for (final studentId in studentIds) {
              final bool isPresent = (studentId % 100) < 85;

              await db.insert('student_attendance', {
                'student_id': studentId,
                'attendance_id': attendanceId,
                'presence': isPresent ? 1 : 0,
                'active': 1,
                'created_at': now.toIso8601String(),
              });

              if (isPresent) {
                attendanceStudentMap[attendanceId]!.add(studentId);
              }
            }
          }
        }
      }

      final List<String> occurrenceTypes = [
        'comportamento',
        'saude',
        'atraso',
        'material',
        'geral',
        'outros',
      ];

      
      final List<Map<String, dynamic>> generalOccurrences = [
        {
          'classe': '1º Ano A',
          'type': 'geral',
          'title': 'Comunicado sobre Feira de Ciências',
          'description':
              'Todos os alunos devem entregar os formulários de autorização para participação na Feira de Ciências até sexta-feira.',
        },
        {
          'classe': '1º Ano A',
          'type': 'comportamento',
          'title': 'Comportamento em Sala',
          'description':
              'A turma demonstrou excelente comportamento durante a visita do diretor.',
        },
        {
          'classe': '1º Ano B',
          'type': 'geral',
          'title': 'Mudança de Horário',
          'description':
              'As aulas de sexta-feira serão transferidas para o período da tarde devido à manutenção nas salas.',
        },
        {
          'classe': '2º Ano A',
          'type': 'outros',
          'title': 'Resultados da Avaliação Bimestral',
          'description':
              'A turma teve desempenho abaixo do esperado na avaliação bimestral de matemática. Será agendada uma aula de reforço.',
        },
        {
          'classe': '2º Ano B',
          'type': 'saude',
          'title': 'Alerta de Saúde',
          'description':
              'Vários alunos reportaram sintomas de gripe. Pais, por favor, fiquem atentos aos sintomas e mantenham seus filhos em casa se necessário.',
        },
        {
          'classe': '3º Ano',
          'type': 'outros',
          'title': 'Simulado ENEM',
          'description':
              'O simulado ENEM ocorrerá no próximo sábado. Presença obrigatória para todos os alunos.',
        },
        {
          'classe': '3º Ano',
          'type': 'geral',
          'title': 'Informações sobre Formatura',
          'description':
              'Reunião sobre a formatura marcada para quinta-feira às 19h com presença dos pais.',
        },
      ];

      
      for (final occurrence in generalOccurrences) {
        final String classeName = occurrence['classe'] as String;
        if (classeAttendanceIds.containsKey(classeName) &&
            classeAttendanceIds[classeName]!.isNotEmpty) {
          final int attendanceId =
              classeAttendanceIds[classeName]![0]; 

          await db.insert('occurrence', {
            'attendance_id': attendanceId,
            'student_id': null, 
            'occurrence_type': occurrence['type'],
            'title': occurrence['title'],
            'description': occurrence['description'],
            'occurrence_date': DateTime.now()
                .subtract(Duration(days: (attendanceId % 14)))
                .toIso8601String()
                .split('T')[0],
            'active': 1,
            'created_at': now,
          });
        }
      }

      
      final List<Map<String, dynamic>> studentOccurrences = [
        {
          'classe': '1º Ano A',
          'student_index': 2, 
          'type': 'comportamento',
          'title': 'Conversa Excessiva',
          'description':
              'Aluno conversando excessivamente durante a explicação da matéria.',
        },
        {
          'classe': '1º Ano A',
          'student_index': 5,
          'type': 'outros',
          'title': 'Destaque Positivo',
          'description':
              'Aluno demonstrou excelente compreensão do conteúdo e auxiliou os colegas com dificuldades.',
        },
        {
          'classe': '1º Ano A',
          'student_index': 8,
          'type': 'saude',
          'title': 'Mal-estar em Sala',
          'description':
              'Aluno relatou dor de cabeça durante a aula e foi encaminhado à enfermaria.',
        },
        {
          'classe': '1º Ano B',
          'student_index': 0,
          'type': 'comportamento',
          'title': 'Uso de Celular',
          'description':
              'Aluno utilizando celular durante a avaliação. Aparelho recolhido conforme regras da escola.',
        },
        {
          'classe': '1º Ano B',
          'student_index': 3,
          'type': 'outros',
          'title': 'Não Entregou Trabalho',
          'description':
              'Aluno não entregou o trabalho de biologia na data estipulada.',
        },
        {
          'classe': '2º Ano A',
          'student_index': 1,
          'type': 'comportamento',
          'title': 'Atitude Desrespeitosa',
          'description':
              'Aluno respondeu de forma desrespeitosa ao ser corrigido durante a aula.',
        },
        {
          'classe': '2º Ano A',
          'student_index': 4,
          'type': 'outros',
          'title': 'Melhora no Desempenho',
          'description':
              'Aluno demonstrou significativa melhora no desempenho em matemática.',
        },
        {
          'classe': '2º Ano B',
          'student_index': 2,
          'type': 'geral',
          'title': 'Uniforme Incompleto',
          'description':
              'Aluno compareceu à aula sem o uniforme completo. Já é a terceira ocorrência no mês.',
        },
        {
          'classe': '3º Ano',
          'student_index': 5,
          'type': 'outros',
          'title': 'Aprovação em Vestibular',
          'description':
              'Aluno foi aprovado no vestibular da universidade federal. Parabéns!',
        },
        {
          'classe': '3º Ano',
          'student_index': 9,
          'type': 'comportamento',
          'title': 'Liderança Positiva',
          'description':
              'Aluno demonstrou excelente liderança ao organizar grupo de estudos para o ENEM.',
        },
      ];

      
      for (final occurrence in studentOccurrences) {
        final String classeName = occurrence['classe'] as String;
        if (classeStudentIds.containsKey(classeName) &&
            classeStudentIds[classeName]!.length >
                occurrence['student_index'] &&
            classeAttendanceIds[classeName]!.isNotEmpty) {
          final int studentId =
              classeStudentIds[classeName]![occurrence['student_index']];
          final int attendanceId =
              classeAttendanceIds[classeName]![0]; 

          await db.insert('occurrence', {
            'attendance_id': attendanceId,
            'student_id': studentId,
            'occurrence_type': occurrence['type'],
            'title': occurrence['title'],
            'description': occurrence['description'],
            'occurrence_date': DateTime.now()
                .subtract(Duration(days: (attendanceId % 10)))
                .toIso8601String()
                .split('T')[0],
            'active': 1,
            'created_at': now,
          });
        }
      }

      
      final List<String> behavioralTitles = [
        'Conversa Excessiva',
        'Uso de Celular',
        'Comportamento Exemplar',
        'Atitude Desrespeitosa',
        'Participação Positiva',
        'Atraso na Aula',
        'Saída sem Autorização',
        'Liderança Positiva',
      ];

      final List<String> academicTitles = [
        'Destaque em Avaliação',
        'Dificuldade com Conteúdo',
        'Não Entregou Trabalho',
        'Melhora no Desempenho',
        'Participação em Olimpíada',
        'Nota Baixa',
        'Destaque em Projeto',
        'Falta de Atenção nas Aulas',
      ];

      final List<String> healthTitles = [
        'Mal-estar em Sala',
        'Acidente no Intervalo',
        'Restrição Médica',
        'Alergias Alimentares',
        'Condição Médica Especial',
        'Dispensa da Educação Física',
        'Medicação na Escola',
      ];

      
      for (final classeName in classeNameToId.keys) {
        if (classeStudentIds.containsKey(classeName) &&
            classeAttendanceIds.containsKey(classeName)) {
          final List<int> studentIds = classeStudentIds[classeName]!;
          final List<int> attendanceIds = classeAttendanceIds[classeName]!;

          if (studentIds.isEmpty || attendanceIds.isEmpty) continue;

          
          for (int i = 0; i < 20; i++) {
            final int randomStudentIndex = i % studentIds.length;
            final int randomAttendanceIndex = i % attendanceIds.length;

            final int studentId = studentIds[randomStudentIndex];
            final int attendanceId = attendanceIds[randomAttendanceIndex];

            final String occurrenceType =
                occurrenceTypes[i % occurrenceTypes.length];

            String title;
            if (occurrenceType == 'comportamento') {
              title = behavioralTitles[i % behavioralTitles.length];
            } else if (occurrenceType == 'outros') {
              title = academicTitles[i % academicTitles.length];
            } else if (occurrenceType == 'saude') {
              title = healthTitles[i % healthTitles.length];
            } else {
              title = 'Ocorrência ${occurrenceType.toLowerCase()}';
            }

            await db.insert('occurrence', {
              'attendance_id': attendanceId,
              'student_id': studentId,
              'occurrence_type': occurrenceType,
              'title': title,
              'description':
                  'Descrição detalhada da ocorrência ${i + 1} para o aluno na turma $classeName.',
              'occurrence_date': DateTime.now()
                  .subtract(Duration(days: (i * 3) % 30))
                  .toIso8601String()
                  .split('T')[0],
              'active': 1,
              'created_at': now,
            });
          }

          
          for (int i = 0; i < 5; i++) {
            final int randomAttendanceIndex = i % attendanceIds.length;
            final int attendanceId = attendanceIds[randomAttendanceIndex];

            final String occurrenceType =
                occurrenceTypes[(i + 2) % occurrenceTypes.length];

            await db.insert('occurrence', {
              'attendance_id': attendanceId,
              'student_id': null, 
              'occurrence_type': occurrenceType,
              'title': 'Ocorrência Geral da Turma $classeName #${i + 1}',
              'description':
                  'Descrição de ocorrência geral para toda a turma $classeName.',
              'occurrence_date': DateTime.now()
                  .subtract(Duration(days: (i * 5) % 30))
                  .toIso8601String()
                  .split('T')[0],
              'active': 1,
              'created_at': now,
            });
          }
        }
      }
    }
  }
}
