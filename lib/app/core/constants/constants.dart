import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class Constants {
  Constants._();

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return "Segunda-feira";
      case 2:
        return "Terça-feira";
      case 3:
        return "Quarta-feira";
      case 4:
        return "Quinta-feira";
      case 5:
        return "Sexta-feira";
      case 6:
        return "Sábado";
      case 7:
        return "Domingo";
      default:
        return "Dia inválido";
    }
  }

  static Future<void> insertDefaultDisciplines(Database db) async {
    final defaultDisciplines = [
      'matemática',
      'português',
      'história',
      'geografia',
      'física',
      'química',
      'biologia',
      'inglês',
      'artes',
      'educação física',
    ];

    for (var discipline in defaultDisciplines) {
      await db.insert('discipline', {
        'name': discipline.toLowerCase(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  static const Color primaryColor = Color(0xFF6A1B9A);
}
