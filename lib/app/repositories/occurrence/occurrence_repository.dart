import 'package:sqflite/sqflite.dart';
import 'package:vocatus/app/core/utils/database/database_helper.dart';
import 'package:vocatus/app/repositories/occurrence/i_occurrence_repository.dart';

class OccurrenceRepository implements IOccurrenceRepository {
  final DatabaseHelper _dbHelper;

  OccurrenceRepository(this._dbHelper);

  @override
  Future<void> createOccurrence(Map<String, dynamic> occurrenceData) async {
    final db = await _dbHelper.database;
    await db.insert(
      'occurrence',
      occurrenceData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
