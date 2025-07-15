import 'package:flutter/material.dart';

class Constants {
  Constants._();

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static const bool isDevelopmentMode = true;

  static String getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return "SEG";
      case 2:
        return "TER";
      case 3:
        return "QUA";
      case 4:
        return "QUI";
      case 5:
        return "SEX";
      case 6:
        return "SAB";
      case 7:
        return "DOM";
      default:
        return "N/A";
    }
  }

  static const Color primaryColor = Color(0xFF6A1B9A);
}
