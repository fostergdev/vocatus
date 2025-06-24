class ClasseReport {
  final int id;
  final String name;
  final List<ScheduleDetail> schedules;

  ClasseReport({
    required this.id,
    required this.name,
    required this.schedules,
  });

  @override
  String toString() {
    return 'ClasseReport(id: $id, name: $name, schedules: $schedules)';
  }
}

class ScheduleDetail {
  final String? disciplineName;
  final int dayOfWeek; 
  final String startTime;
  final String endTime;

  ScheduleDetail({
    this.disciplineName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  String get dayOfWeekName {
    switch (dayOfWeek) {
      case 1: return 'Segunda-feira';
      case 2: return 'Terça-feira';
      case 3: return 'Quarta-feira';
      case 4: return 'Quinta-feira';
      case 5: return 'Sexta-feira';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return 'Desconhecido';
    }
  }

  @override
  String toString() {
    return 'ScheduleDetail(disciplineName: $disciplineName, dayOfWeek: $dayOfWeekName, startTime: $startTime, endTime: $endTime)';
  }
}

