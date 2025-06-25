// lib/app/models/classe.dart

import 'dart:convert';
import 'package:vocatus/app/models/grade.dart'; // Importa Grade, pois Classe agora terá uma lista de Grades

class Classe {
  final int? id;
  final String name;
  final String? description;
  final int schoolYear;
  final DateTime? createdAt;
  final bool? active; // <--- O `active` é bool aqui, como no seu modelo original.
  final List<Grade> schedules; // <--- Lista de Grades para os agendamentos.

  Classe({
    this.id,
    required this.name,
    this.description,
    required this.schoolYear,
    this.createdAt,
    this.active = true, // Valor padrão para bool
    this.schedules = const [], // Inicializa como lista vazia por padrão
  });

  Classe copyWith({
    int? id,
    String? name,
    String? description,
    int? schoolYear,
    DateTime? createdAt,
    bool? active, // Tipo bool
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

  factory Classe.fromMap(Map<String, dynamic> map) {
    // Note: Esta factory é para carregar a CLASSE BASE do banco de dados (tabela 'classe').
    // Ela NÃO espera os dados de 'schedules' diretamente do map da tabela 'classe'.
    // Os 'schedules' serão preenchidos separadamente no controlador,
    // a partir da query `getClassesRawReport` que retorna dados JOINED.
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

  String toJson() => json.encode(toMap());

  factory Classe.fromJson(String source) =>
      Classe.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Classe(id: $id, name: $name, schoolYear: $schoolYear, active: $active, schedules: $schedules)';
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