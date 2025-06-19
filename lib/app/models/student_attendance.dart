import 'package:flutter/material.dart'; // Para @immutable
import 'package:vocatus/app/models/student.dart'; // Importa Student (para o objeto aninhado)
import 'package:vocatus/app/models/attendance.dart'; // Importa Attendance (para o objeto aninhado, se necessário)

// Enum para o status de presença do aluno
enum PresenceStatus {
  present,    // 0: Presente
  absent,     // 1: Faltou
  justified   // 2: Falta Justificada
}

@immutable // Indica que o objeto é imutável após a criação
class StudentAttendance {
  final int attendanceId; // Chave estrangeira para a chamada (Attendance)
  final int studentId;    // Chave estrangeira para o aluno (Student)
  final PresenceStatus presence; // Status de presença do aluno
  final DateTime? createdAt; // Data e hora de criação do registro
  final bool? active; // Campo para soft delete do registro de presença (default true)

  // Campos extras para conveniência na UI (NÃO persistem no DB diretamente,
  // são preenchidos por JOINs ou lógica no Controller)
  final Student? student; // Objeto Student completo, anexado para fácil acesso na UI
  final Attendance? attendance; // Objeto Attendance completo, se precisar do contexto da chamada na UI

  const StudentAttendance({
    required this.attendanceId,
    required this.studentId,
    required this.presence,
    this.createdAt,
    this.student, // Opcional, para carregar o objeto Student associado
    this.attendance, // Opcional, para carregar o objeto Attendance associado
    this.active = true, // Por padrão, o registro de presença é ativo
  });

  // Construtor de fábrica para criar um objeto StudentAttendance a partir de um Map (do banco de dados)
  factory StudentAttendance.fromMap(Map<String, dynamic> map) {
    return StudentAttendance(
      attendanceId: map['attendance_id'] as int,
      studentId: map['student_id'] as int,
      // Converte o valor inteiro do banco de dados para o enum PresenceStatus
      presence: PresenceStatus.values[map['presence'] as int],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      active: map['active'] == 1, // Converte o int (0 ou 1) para bool
    );
  }

  // Converte o objeto StudentAttendance para um Map, para ser salvo no banco de dados
  Map<String, dynamic> toMap() {
    return {
      'attendance_id': attendanceId,
      'student_id': studentId,
      'presence': presence.index, // Salva o índice do enum (0, 1 ou 2) como int
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'active': (active ?? true) ? 1 : 0, // Salva o status ativo como int (1 ou 0)
    };
  }

  // Método copyWith para criar uma nova instância com valores alterados, mantendo a imutabilidade
  StudentAttendance copyWith({
    int? attendanceId,
    int? studentId,
    PresenceStatus? presence,
    DateTime? createdAt,
    Student? student,
    Attendance? attendance,
    bool? active,
  }) {
    return StudentAttendance(
      attendanceId: attendanceId ?? this.attendanceId,
      studentId: studentId ?? this.studentId,
      presence: presence ?? this.presence,
      createdAt: createdAt ?? this.createdAt,
      student: student ?? this.student,
      attendance: attendance ?? this.attendance,
      active: active ?? this.active,
    );
  }

  // Sobrescreve o operador de igualdade para que dois objetos StudentAttendance sejam considerados iguais
  // se tiverem o mesmo attendanceId e studentId (chave primária composta)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // Se forem o mesmo objeto em memória

    return other is StudentAttendance && // Se 'other' é do tipo StudentAttendance
        other.attendanceId == attendanceId && // E o attendanceId é o mesmo
        other.studentId == studentId; // E o studentId é o mesmo
  }

  // Sobrescreve o hashCode para ser consistente com o operador ==
  @override
  int get hashCode => attendanceId.hashCode ^ studentId.hashCode;
}