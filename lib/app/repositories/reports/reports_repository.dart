import 'package:vocatus/app/core/utils/database_helper.dart';
import 'package:vocatus/app/repositories/reports/i_reports_repository.dart';

class ReportsRepository implements IReportsRepository {
  final DatabaseHelper _dbHelper;

  ReportsRepository(this._dbHelper);

  @override
  Future<List<Map<String, dynamic>>> getClassesRawReport(int year) async {
    final db = await _dbHelper.database;
    // Consulta SQL para obter ID da classe, nome da classe, nome da disciplina,
    // dia da semana, hora de início e hora de término para o ano letivo especificado.
    // Usamos LEFT JOIN para a disciplina, pois grade.discipline_id pode ser NULL.
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT
        c.id AS classe_id,
        c.name AS classe_name,
        d.name AS discipline_name,
        g.day_of_week,
        g.start_time,
        g.end_time
      FROM classe c
      JOIN grade g ON c.id = g.classe_id
      LEFT JOIN discipline d ON g.discipline_id = d.id
      WHERE c.school_year = ? AND c.active = 1 AND g.active = 1
      ORDER BY c.name, g.day_of_week, g.start_time;
    ''',
      [year],
    );

    return result;
  }
}
