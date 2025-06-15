// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';


class WeekdayModel {
  int id;
  String name;
  WeekdayModel({
    required this.id,
    required this.name,
  });

  WeekdayModel copyWith({
    int? id,
    String? name,
  }) {
    return WeekdayModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory WeekdayModel.fromMap(Map<String, dynamic> map) {
    return WeekdayModel(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory WeekdayModel.fromJson(String source) => WeekdayModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'WeekdayModel(id: $id, name: $name)';

  @override
  bool operator ==(covariant WeekdayModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}