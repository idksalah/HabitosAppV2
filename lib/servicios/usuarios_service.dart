
import 'package:sqflite/sqflite.dart';

import '../modelos/usuario.dart';
import 'database_helper.dart';

class UsuariosService {

  // Recupera todos los usuarios de la base de datos.
  static Future<List<Usuario>> obtenerUsuarios() async {
    final db = await DatabaseHelper.obtenerBaseDatos();

    final datos = await db.query('usuarios');

    final List<Usuario> usuarios = [];

    for (final elemento in datos) {
      usuarios.add(
        Usuario.fromJson(
          Map<String, dynamic>.from(elemento),
        ),
      );
    }

    return usuarios;
  }

  // Busca un usuario por su identificador.
  static Future<Usuario?> obtenerUsuarioPorId(String id) async {
    final db = await DatabaseHelper.obtenerBaseDatos();

    final datos = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (datos.isEmpty) {
      return null;
    }

    return Usuario.fromJson(
      Map<String, dynamic>.from(datos.first),
    );
  }

  // Comprueba si un usuario es administrador.
  static Future<bool> esAdministrador(String id) async {
    final usuario = await obtenerUsuarioPorId(id);

    return usuario != null && usuario.rol == 'admin';
  }

  // Guarda los cambios realizados por el administrador.
  static Future<void> guardarUsuarios(
      String administradorId,
      List<Usuario> usuarios,
      ) async {

    // Comprobamos los permisos.
    final permiso = await esAdministrador(administradorId);

    if (!permiso) {
      throw Exception('No tienes permisos de administrador');
    }

    final db = await DatabaseHelper.obtenerBaseDatos();

    for (final usuario in usuarios) {
      final filas = await db.update(
        'usuarios',
        usuario.toJson(),
        where: 'id = ?',
        whereArgs: [usuario.id],
      );

      // Si no existe, lo añadimos.
      if (filas == 0) {
        await db.insert(
          'usuarios',
          usuario.toJson(),
        );
      }
    }
  }

  // Registra un usuario nuevo.
  static Future<bool> registrarUsuario(Usuario usuario) async {

    // El registro normal solo puede crear usuarios.
    if (usuario.rol != 'usuario') {
      return false;
    }

    final db = await DatabaseHelper.obtenerBaseDatos();

    final usuarios = await obtenerUsuarios();

    // Comprobamos que no exista el usuario o el correo.
    for (final elemento in usuarios) {
      if (elemento.usuario.toLowerCase() ==
          usuario.usuario.toLowerCase() ||
          elemento.correo.toLowerCase() ==
              usuario.correo.toLowerCase()) {
        return false;
      }
    }

    // Insertamos el usuario en SQLite.
    final resultado = await db.insert(
      'usuarios',
      usuario.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return resultado != -1;
  }

  // Comprueba los datos para iniciar sesión.
  static Future<Usuario?> iniciarSesion(
      String nombreUsuario,
      String contrasena,
      ) async {
    final usuarios = await obtenerUsuarios();

    for (final usuario in usuarios) {
      if (usuario.usuario.toLowerCase() ==
          nombreUsuario.toLowerCase() &&
          usuario.contrasena == contrasena) {
        return usuario;
      }
    }

    return null;
  }

  // Elimina un usuario de la base de datos.
  static Future<bool> eliminarUsuario(
      String administradorId,
      String id,
      ) async {

    // Comprobamos los permisos.
    final permiso = await esAdministrador(administradorId);

    if (!permiso) {
      return false;
    }

    final db = await DatabaseHelper.obtenerBaseDatos();

    final usuario = await obtenerUsuarioPorId(id);

    // No permitimos eliminar administradores.
    if (usuario == null || usuario.rol == 'admin') {
      return false;
    }

    final resultado = await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );

    return resultado > 0;
  }

  // Crea el administrador inicial si todavía no existe.
  static Future<void> crearAdministradorInicial() async {
    final usuarios = await obtenerUsuarios();

    for (final usuario in usuarios) {
      if (usuario.rol == 'admin') {
        return;
      }
    }

    // Cuenta de prueba para el desarrollo local.
    final administrador = Usuario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      usuario: 'admin',
      nombre: 'Administrador',
      apellidos: 'Sistema',
      correo: 'admin@admin.com',
      contrasena: 'admin1234',
      rol: 'admin',
      fechaCreacion: DateTime.now(),
    );

    // El administrador inicial se crea directamente en SQLite.
    final db = await DatabaseHelper.obtenerBaseDatos();

    await db.insert(
      'usuarios',
      administrador.toJson(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}
