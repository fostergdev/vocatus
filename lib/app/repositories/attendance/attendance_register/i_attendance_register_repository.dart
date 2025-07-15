
// lib/app/repositories/attendance_register/i_attendance_register_repository.dart

import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import 'package:vocatus/app/models/student.dart';

abstract class IAttendanceRegisterRepository {
  Future<Attendance> createOrUpdateAttendance(
    Attendance attendance,
    List<StudentAttendance> studentAttendances,
  );
  Future<Attendance?> getAttendanceByScheduleAndDate(int scheduleId, DateTime date);
  Future<List<StudentAttendance>> getStudentAttendancesByAttendanceId(
    int attendanceId,
  );
  Future<void> toggleAttendanceActiveStatus(int attendanceId, bool newStatus);
  Future<List<Student>> getStudentsByClasseId(int classeId);
}
