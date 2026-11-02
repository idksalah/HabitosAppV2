
import 'database_helper.dart';
import 'usuarios_service.dart';

class EstadisticasService {
  // Comprueba si el usuario es administrador.
  static Future<bool> esAdmin(String usuarioId) async {
    return await UsuariosService.esAdministrador(usuarioId);
  }

  // Consulta todas las estadísticas.
  // Solo puede hacerlo el administrador.
  static Future<List<Map<String, Object?>>> obtenerTodas(
      String administradorId,
      ) async {
    if (!await esAdmin(administradorId)) {
      throw Exception('Acceso denegado');
    }

    final db = await DatabaseHelper.obtenerBaseDatos();

    return await db.query('estadisticas');
  }

  // Consulta las estadísticas de un usuario.
  static Future<List<Map<String, Object?>>> obtenerPorUsuario(
      String usuarioId,
      ) async {
    final db = await DatabaseHelper.obtenerBaseDatos();

    final habitos = await db.query(
      'habitos',
      columns: ['id'],
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );

    final List<Map<String, Object?>> estadisticas = [];

    for (final habito in habitos) {
      final datos = await db.query(
        'estadisticas',
        where: 'habitoId = ?',
        whereArgs: [habito['id']],
      );

      estadisticas.addAll(datos);
    }

    return estadisticas;
  }

  // Crea estadísticas de un hábito.
  static Future<void> crear(
      String administradorId,
      String habitoId,
      int racha,
      int dias,
      ) async {
    if (!await esAdmin(administradorId)) {
      throw Exception('Acceso denegado');
    }

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
      String administradorId,
      String habitoId,
      int racha,
      int dias,
      ) async {
    if (!await esAdmin(administradorId)) {
      throw Exception('Acceso denegado');
    }

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
  static Future<void> eliminar(
      String administradorId,
      String habitoId,
      ) async {
    if (!await esAdmin(administradorId)) {
      throw Exception('Acceso denegado');
    }

    final db = await DatabaseHelper.obtenerBaseDatos();

    await db.delete(
      'estadisticas',
      where: 'habitoId = ?',
      whereArgs: [habitoId],
    );
  }
}
