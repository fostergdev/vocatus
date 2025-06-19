// lib/app/repositories/attendance_select/i_attendance_select_repository.dart

import 'package:vocatus/app/models/grade.dart';
import 'package:vocatus/app/models/discipline.dart';
import 'package:vocatus/app/models/classe.dart';

abstract class IAttendanceSelectRepository {
  // Método para buscar todos os horários agendados com filtros
  Future<List<Grade>> getAllGradesForSelection({
    int? classeId,
    int? disciplineId,
    int? dayOfWeek,
    bool? activeStatus, // Status do horário (ativo/inativo)
    int? year,           // Ano da grade
  });

  // Métodos para buscar dados de dropdowns
  Future<List<Discipline>> getAllActiveDisciplines();
  Future<List<Classe>> getAllActiveClasses();
}