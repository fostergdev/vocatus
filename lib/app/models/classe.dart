// lib/app/models/classe.dart

import 'dart:convert';
import 'package:vocatus/app/models/grade.dart'; // Importa Grade para a lista de agendamentos
import 'package:vocatus/app/models/discipline.dart'; // Importa Discipline, pois Grade pode ter uma referência a ela

class Classe {
  final int? id;
  final String name;
  final String? description;
  final int schoolYear;
  final DateTime? createdAt;
  final bool? active;
  final List<Grade> schedules; // Lista de Grades para os agendamentos

  Classe({
    this.id,
    required this.name,
    this.description,
    required this.schoolYear,
    this.createdAt,
    this.active = true, // Valor padrão para bool
    this.schedules = const [], // Inicializa como lista vazia por padrão
  });

  /// Retorna uma nova instância de Classe com os campos fornecidos,
  /// mantendo os valores originais se não forem especificados.
  Classe copyWith({
    int? id,
    String? name,
    String? description,
    int? schoolYear,
    DateTime? createdAt,
    bool? active,
    List<Grade>? schedules,
  }) {
    return Classe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      schoolYear: schoolYear ?? this.schoolYear,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
      schedules: schedules ?? this.schedules,
    );
  }

  /// Cria uma instância de [Classe] a partir de um [Map].
  /// Esta factory é para carregar a CLASSE BASE do banco de dados (tabela 'classe').
  /// Ela NÃO espera os dados de 'schedules' diretamente do map da tabela 'classe'.
  /// Os 'schedules' serão preenchidos separadamente no controlador,
  /// a partir da query `getClassesRawReport` que retorna dados JOINED.
  factory Classe.fromMap(Map<String, dynamic> map) {
    return Classe(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      schoolYear: map['school_year'] as int,
      createdAt: map['created_at'] != null && (map['created_at'] is String) && (map['created_at'] as String).isNotEmpty
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      active: map['active'] != null ? (map['active'] as int) == 1 : null, // Mapeia int do DB para bool
      schedules: [], // Sempre inicia vazia, será preenchida no ReportsController
    );
  }

  /// Constrói uma lista de objetos [Classe] a partir dos dados brutos do relatório,
  /// que incluem informações de `classe`, `grade` e `discipline` (via JOIN).
  ///
  /// Este método é essencial para processar o resultado da sua query
  /// `getClassesRawReport`, agrupando os horários (grades) em suas respectivas turmas.
  static List<Classe> fromRawReportList(List<Map<String, dynamic>> rawData) {
    final Map<int, Classe> classesMap = {};

    for (var row in rawData) {
      final int? classeId = row['classe_id'] as int?;
      if (classeId == null) continue; // Pula a linha se não houver ID da turma

      // Se a turma ainda não está no mapa, cria um novo objeto Classe
      if (!classesMap.containsKey(classeId)) {
        classesMap[classeId] = Classe(
          id: classeId,
          name: row['classe_name'] as String,
          description: row['description'] as String?,
          schoolYear: row['school_year'] as int,
          createdAt: row['created_at'] != null && (row['created_at'] is String) && (row['created_at'] as String).isNotEmpty
              ? DateTime.tryParse(row['created_at'] as String)
              : null,
          active: row['classe_active'] != null ? (row['classe_active'] as int) == 1 : null,
          schedules: [], // Inicializa vazio, os horários serão adicionados abaixo
        );
      }

      // Verifica se há detalhes de horário (Grade) nesta linha
      // É importante verificar 'grade_id' para garantir que esta parte da linha
      // realmente representa um horário e não apenas um registro de turma sem horário.
      if (row['grade_id'] != null && row['day_of_week'] != null && row['start_time'] != null) {
        final Discipline? discipline = row['discipline_id'] != null
            ? Discipline(
                id: row['discipline_id'] as int,
                name: row['discipline_name'] as String,
                active: true, // Assumindo ativo se ID e nome existirem
              )
            : null;

        final Grade grade = Grade(
          id: row['grade_id'] as int, // O ID da grade (horário específico)
          classeId: classeId,
          disciplineId: row['discipline_id'] as int?,
          dayOfWeek: row['day_of_week'] as int,
          startTimeTotalMinutes: Grade.timeStringToInt(row['start_time'] as String),
          endTimeTotalMinutes: Grade.timeStringToInt(row['end_time'] as String),
          gradeYear: row['school_year'] as int, // O ano da grade é o mesmo da turma
          discipline: discipline,
          active: true, // Assumindo ativo
        );

        // Adiciona a grade à lista de schedules da Classe correspondente no mapa
        classesMap[classeId]!.schedules.add(grade);
      }
    }
    // Retorna a lista de objetos Classe a partir dos valores do mapa
    return classesMap.values.toList();
  }

  /// Converte a instância de [Classe] para um [Map], geralmente para armazenamento no banco de dados.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'school_year': schoolYear,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'active': (active ?? true) ? 1 : 0, // Mapeia bool para int (1 ou 0) para o DB
    };
  }

  /// Converte a instância de [Classe] para uma string JSON.
  String toJson() => json.encode(toMap());

  /// Cria uma instância de [Classe] a partir de uma string JSON.
  factory Classe.fromJson(String source) =>
      Classe.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Classe(id: $id, name: $name, schoolYear: $schoolYear, active: $active, schedules: ${schedules.length} schedules)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Classe && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}