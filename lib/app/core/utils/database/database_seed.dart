import 'package:sqflite/sqflite.dart';
import 'dart:developer';


class DatabaseSeed {
  static Future<void> insertInitialData(Database db) async {
    log(
      'DatabaseSeed.insertInitialData - Iniciando populamento de dados iniciais.',
      name: 'DatabaseSeed',
    );
    final now = DateTime.now().toIso8601String();
    final currentYear = DateTime.now().year;

    // Inserir disciplinas
    log(
      'DatabaseSeed.insertInitialData - Inserindo disciplinas padrão.',
      name: 'DatabaseSeed',
    );
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
    for (String name in defaultDisciplines) {
      final int id = await db.insert('discipline', {'name': name, 'active': 1});
      disciplineIds.add(id);
    }
    log(
      'DatabaseSeed.insertInitialData - Disciplinas padrão inseridas.',
      name: 'DatabaseSeed',
    );

    // Obter o ID da disciplina de Biologia (índice 2 na lista)
    final int biologiaId = disciplineIds[2];

    // Inserir turmas específicas
    log(
      'DatabaseSeed.insertInitialData - Inserindo turmas específicas.',
      name: 'DatabaseSeed',
    );
    final List<int> classeIds = [];

    // Lista de turmas para criar
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
    }

    log(
      'DatabaseSeed.insertInitialData - Turmas específicas inseridas. Total: ${classeIds.length} turmas.',
      name: 'DatabaseSeed',
    );

    // Inserir horários (grade) para as turmas
    log(
      'DatabaseSeed.insertInitialData - Inserindo horários das turmas.',
      name: 'DatabaseSeed',
    );

    // Configurando horários conforme a tabela fornecida
    // 1 = Segunda, 3 = Quarta, 5 = Sexta
    final List<Map<String, dynamic>> scheduleData = [
      // Segunda-feira (seg)
      {'classe_id': classeIds[4], 'day': 1, 'start': '07:00', 'end': '07:50', 'discipline_id': biologiaId},
      {'classe_id': classeIds[4], 'day': 1, 'start': '07:50', 'end': '08:40', 'discipline_id': biologiaId},
      {'classe_id': classeIds[1], 'day': 1, 'start': '08:40', 'end': '09:30', 'discipline_id': biologiaId},
      {'classe_id': classeIds[3], 'day': 1, 'start': '09:50', 'end': '10:40', 'discipline_id': biologiaId},
      {'classe_id': classeIds[3], 'day': 1, 'start': '10:40', 'end': '11:30', 'discipline_id': biologiaId},
      {'classe_id': classeIds[2], 'day': 1, 'start': '11:30', 'end': '12:20', 'discipline_id': biologiaId},
      
      // Quarta-feira (qua)
      {'classe_id': classeIds[0], 'day': 3, 'start': '07:00', 'end': '07:50', 'discipline_id': biologiaId},
      {'classe_id': classeIds[2], 'day': 3, 'start': '07:50', 'end': '08:40', 'discipline_id': biologiaId},
      {'classe_id': classeIds[2], 'day': 3, 'start': '08:40', 'end': '09:30', 'discipline_id': biologiaId},
      {'classe_id': classeIds[4], 'day': 3, 'start': '09:50', 'end': '10:40', 'discipline_id': biologiaId},
      {'classe_id': classeIds[3], 'day': 3, 'start': '10:40', 'end': '11:30', 'discipline_id': biologiaId},
      {'classe_id': classeIds[0], 'day': 3, 'start': '11:30', 'end': '12:20', 'discipline_id': biologiaId},
      
      // Sexta-feira (sex)
      {'classe_id': classeIds[0], 'day': 5, 'start': '07:50', 'end': '08:40', 'discipline_id': biologiaId},
      {'classe_id': classeIds[0], 'day': 5, 'start': '08:40', 'end': '09:30', 'discipline_id': biologiaId},
      {'classe_id': classeIds[4], 'day': 5, 'start': '09:50', 'end': '10:40', 'discipline_id': biologiaId},
      {'classe_id': classeIds[1], 'day': 5, 'start': '10:40', 'end': '11:30', 'discipline_id': biologiaId},
      {'classe_id': classeIds[1], 'day': 5, 'start': '11:30', 'end': '12:20', 'discipline_id': biologiaId},
    ];

    // Inserir horários na tabela grade
    final List<int> gradeIds = [];
    for (final schedule in scheduleData) {
      final int gradeId = await db.insert('grade', {
        'classe_id': schedule['classe_id'],
        'discipline_id': schedule['discipline_id'],
        'day_of_week': schedule['day'],
        'start_time': schedule['start'],
        'end_time': schedule['end'],
        'grade_year': currentYear,
        'active': 1,
        'created_at': now,
      });
      gradeIds.add(gradeId);
    }

    log(
      'DatabaseSeed.insertInitialData - Horários das turmas inseridos. Total: ${gradeIds.length} horários.',
      name: 'DatabaseSeed',
    );

    // Inserir alunos por turma
    log(
      'DatabaseSeed.insertInitialData - Inserindo alunos nas turmas.',
      name: 'DatabaseSeed',
    );

    // Alunos da turma 1A
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

    // Alunos da turma 1B
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

    // Alunos da turma 2A
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

    // Alunos da turma 2B
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

    // Alunos da turma 3
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

    // Inserir alunos da turma 1A
    if (classeIds.isNotEmpty) {
      for (String studentName in students1A) {
        // Inserir o aluno
        final int studentId = await db.insert('student', {
          'name': studentName,
          'active': 1,
          'created_at': now,
        });

        // Associar o aluno à turma 1A
        await db.insert('classe_student', {
          'student_id': studentId,
          'classe_id': classeIds[0],
          'start_date': '2024-02-01',
          'active': 1,
          'created_at': now,
        });
      }
      log(
        'DatabaseSeed.insertInitialData - Alunos da turma 1A inseridos.',
        name: 'DatabaseSeed',
      );
    }

    // Inserir alunos da turma 1B
    if (classeIds.length >= 2) {
      for (String studentName in students1B) {
        // Inserir o aluno
        final int studentId = await db.insert('student', {
          'name': studentName,
          'active': 1,
          'created_at': now,
        });

        // Associar o aluno à turma 1B
        await db.insert('classe_student', {
          'student_id': studentId,
          'classe_id': classeIds[1],
          'start_date': '2024-02-01',
          'active': 1,
          'created_at': now,
        });
      }
      log(
        'DatabaseSeed.insertInitialData - Alunos da turma 1B inseridos.',
        name: 'DatabaseSeed',
      );
    }

    // Inserir alunos da turma 2A
    if (classeIds.length >= 3) {
      for (String studentName in students2A) {
        // Inserir o aluno
        final int studentId = await db.insert('student', {
          'name': studentName,
          'active': 1,
          'created_at': now,
        });

        // Associar o aluno à turma 2A
        await db.insert('classe_student', {
          'student_id': studentId,
          'classe_id': classeIds[2],
          'start_date': '2024-02-01',
          'active': 1,
          'created_at': now,
        });
      }
      log(
        'DatabaseSeed.insertInitialData - Alunos da turma 2A inseridos.',
        name: 'DatabaseSeed',
      );
    }

    // Inserir alunos da turma 2B
    if (classeIds.length >= 4) {
      for (String studentName in students2B) {
        // Inserir o aluno
        final int studentId = await db.insert('student', {
          'name': studentName,
          'active': 1,
          'created_at': now,
        });

        // Associar o aluno à turma 2B
        await db.insert('classe_student', {
          'student_id': studentId,
          'classe_id': classeIds[3],
          'start_date': '2024-02-01',
          'active': 1,
          'created_at': now,
        });
      }
      log(
        'DatabaseSeed.insertInitialData - Alunos da turma 2B inseridos.',
        name: 'DatabaseSeed',
      );
    }

    // Inserir alunos da turma 3
    if (classeIds.length >= 5) {
      for (String studentName in students3) {
        // Inserir o aluno
        final int studentId = await db.insert('student', {
          'name': studentName,
          'active': 1,
          'created_at': now,
        });

        // Associar o aluno à turma 3
        await db.insert('classe_student', {
          'student_id': studentId,
          'classe_id': classeIds[4],
          'start_date': '2024-02-01',
          'active': 1,
          'created_at': now,
        });
      }
      log(
        'DatabaseSeed.insertInitialData - Alunos da turma 3 inseridos.',
        name: 'DatabaseSeed',
      );
    }

    log(
      'DatabaseSeed.insertInitialData - Populamento de dados iniciais concluído com sucesso.',
      name: 'DatabaseSeed',
    );
  }
}
