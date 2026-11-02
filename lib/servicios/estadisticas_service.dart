
import 'database_helper.dart';

class EstadisticasService {
  // Consulta todas las estadísticas guardadas.
  static Future<List<Map<String, Object?>>> obtenerTodas() async {
    final db = await DatabaseHelper.obtenerBaseDatos();

    return await db.query('estadisticas');
  }

  // Crea una estadística para un hábito.
  static Future<void> crear(
      String habitoId,
      int racha,
      int dias,
      ) async {
    final db = await DatabaseHelper.obtenerBaseDatos();

    await db.insert(
      'estadisticas',
      {
        'habitoId': habitoId,
        'rachaActual': racha,
        'diasCompletados': dias,
      },
    );
  }

  // Modifica las estadísticas de un hábito.
  static Future<void> actualizar(
      String habitoId,
      int racha,
      int dias,
      ) async {
    final db = await DatabaseHelper.obtenerBaseDatos();

    await db.update(
      'estadisticas',
      {
        'rachaActual': racha,
        'diasCompletados': dias,
      },
      where: 'habitoId = ?',
      whereArgs: [habitoId],
    );
  }

  // Elimina las estadísticas de un hábito.
  static Future<void> eliminar(String habitoId) async {
    final db = await DatabaseHelper.obtenerBaseDatos();

    await db.delete(
      'estadisticas',
      where: 'habitoId = ?',
      whereArgs: [habitoId],
    );
  }
}
