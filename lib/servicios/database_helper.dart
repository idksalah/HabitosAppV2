
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Guardamos la base de datos para abrirla una sola vez.
  static Database? _baseDatos;

  // Abre la base de datos.
  static Future<Database> obtenerBaseDatos() async {
    if (_baseDatos != null) {
      return _baseDatos!;
    }

    final ruta = join(
      await getDatabasesPath(),
      'habitos.db',
    );

    _baseDatos = await openDatabase(
      ruta,
      version: 1,

      // Activamos las relaciones entre tablas.
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        // Tabla de usuarios.
        await db.execute('''
          CREATE TABLE usuarios (
            id TEXT PRIMARY KEY,
            usuario TEXT NOT NULL UNIQUE,
            nombre TEXT NOT NULL,
            apellidos TEXT NOT NULL,
            correo TEXT NOT NULL UNIQUE,
            contrasena TEXT NOT NULL,
            fechaCreacion TEXT NOT NULL,
            rol TEXT NOT NULL
          )
        ''');

        // Tabla de hábitos.
        await db.execute('''
          CREATE TABLE habitos (
            id TEXT PRIMARY KEY,
            usuarioId TEXT NOT NULL,
            nombre TEXT NOT NULL,
            color INTEGER NOT NULL,
            fechasCompletado TEXT NOT NULL,
            FOREIGN KEY (usuarioId)
              REFERENCES usuarios(id)
              ON DELETE CASCADE
          )
        ''');

        // Tabla de estadísticas.
        await db.execute('''
          CREATE TABLE estadisticas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habitoId TEXT NOT NULL UNIQUE,
            rachaActual INTEGER NOT NULL,
            diasCompletados INTEGER NOT NULL,
            FOREIGN KEY (habitoId)
              REFERENCES habitos(id)
              ON DELETE CASCADE
          )
        ''');
      },
    );

    return _baseDatos!;
  }
}
