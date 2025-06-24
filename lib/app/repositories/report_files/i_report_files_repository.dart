// app/repositories/report_files/i_report_files_repository.dart

import 'package:vocatus/app/models/classe.dart';
import 'package:vocatus/app/models/student.dart';
import 'package:vocatus/app/models/attendance.dart';
import 'package:vocatus/app/models/student_attendance.dart';
import 'package:vocatus/app/models/grade.dart';

abstract class IReportFilesRepository {
  // For Classes in History (only inactive/archived classes)
  Future<List<Classe>> getArchivedClasses();
  Future<List<int>> getYearsOfArchivedClasses();

  // For Students in History (students with AT LEAST ONE inactive enrollment)
  Future<List<Student>> getStudentsWithInactiveEnrollments();
  Future<List<int>>
  getYearsOfStudentsWithInactiveEnrollments(); // Years from classes where these students had inactive enrollments

  // Detail and general history methods (no active filter unless specified)
  Future<Classe?> getClasseById(int classeId);
  Future<List<Classe>> getStudentInactiveEnrollments(int studentId);
  Future<Student?> getStudentById(int studentId);

  // For historical students associated with a class (regardless of current link status)
  Future<List<Student>> getStudentsAssociatedWithClasseHistory(int classeId);

  // Historical schedules for a class (all, active or inactive)
  Future<List<Grade>> getClasseSchedulesHistory(int classeId);
  // Historical attendances for a class (all, active or inactive)
  Future<List<Attendance>> getClasseAttendances(int classeId);
  // Historical classes a student was in (all enrollments, active or inactive)
  Future<List<Classe>> getClassesAssociatedWithStudentHistory(int studentId);

  // CRUCIAL: Returns ALL enrollments for a student (active and inactive)
  Future<List<Classe>> getStudentEnrollments(int studentId);

  Future<List<StudentAttendance>> getStudentAttendanceHistory(int studentId);
  Future<List<StudentAttendance>> getStudentAttendanceDetailsForAttendance(
    int attendanceId,
  );
}
