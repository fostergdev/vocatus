import 'package:vocatus/app/core/utils/database/database_helper.dart';

void main() async {
  final dbHelper = DatabaseHelper.instance;
  final db = await dbHelper.database;

  print('Checking raw presence values in student_attendance table:');
  final List<Map<String, dynamic>> result = await db.query('student_attendance');

  if (result.isEmpty) {
    print('No records found in student_attendance table.');
  } else {
    for (var row in result) {
      print('student_id: ${row['student_id']}, attendance_id: ${row['attendance_id']}, presence: ${row['presence']}');
    }
  }

  await db.close();
  print('Database connection closed.');
}
