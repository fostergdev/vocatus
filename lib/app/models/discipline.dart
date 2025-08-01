import 'dart:convert';

class Discipline {
  final int? id;
  final String name;
  final DateTime? createdAt;
  final bool? active;

  const Discipline({
    this.id,
    required this.name,
    this.createdAt,
    this.active,
  });

  Discipline copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    bool? active,
  }) {
    return Discipline(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
      'active': active == null ? null : (active! ? 1 : 0),
    };
  }

  factory Discipline.fromMap(Map<String, dynamic> map) {
    return Discipline(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      createdAt: map['created_at'] != null && 
                (map['created_at'] is String) && 
                (map['created_at'] as String).isNotEmpty
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      active: map['active'] != null ? (map['active'] as int) == 1 : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Discipline.fromJson(String source) =>
      Discipline.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Discipline(id: $id, name: $name, createdAt: $createdAt, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Discipline &&
        other.id == id; 
  }

  @override
  int get hashCode => id.hashCode; 
}