
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';

class UsuariosService {
  static const String claveUsuarios = 'usuarios';

  // Recupera todos los usuarios guardados.
  static Future<List<Usuario>> obtenerUsuarios() async {
    final preferencias = await SharedPreferences.getInstance();

    final datos = preferencias.getString(claveUsuarios);

    if (datos == null) {
      return [];
    }

    final lista = jsonDecode(datos) as List;

    final List<Usuario> usuarios = [];

    for (final elemento in lista) {
      usuarios.add(
        Usuario.fromJson(
          Map<String, dynamic>.from(elemento),
        ),
      );
    }

    return usuarios;
  }

  // Guarda la lista de usuarios.
  static Future<void> guardarUsuarios(
      List<Usuario> usuarios,
      ) async {
    final preferencias = await SharedPreferences.getInstance();

    final listaJson = [];

    for (final usuario in usuarios) {
      listaJson.add(usuario.toJson());
    }

    await preferencias.setString(
      claveUsuarios,
      jsonEncode(listaJson),
    );
  }

  // Busca un usuario por su identificador.
  static Future<Usuario?> obtenerUsuarioPorId(String id) async {
    final usuarios = await obtenerUsuarios();

    for (final usuario in usuarios) {
      if (usuario.id == id) {
        return usuario;
      }
    }

    return null;
  }

  // Comprueba si un usuario es administrador.
  static Future<bool> esAdministrador(String id) async {
    final usuario = await obtenerUsuarioPorId(id);

    return usuario != null && usuario.rol == 'admin';
  }

  // Registra un usuario nuevo.
  static Future<bool> registrarUsuario(Usuario usuario) async {
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

    usuarios.add(usuario);

    await guardarUsuarios(usuarios);

    return true;
  }

  // Comprueba los datos de inicio de sesión.
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

  // Elimina un usuario por su identificador.
  static Future<bool> eliminarUsuario(String id) async {
    final usuarios = await obtenerUsuarios();

    Usuario? usuarioEncontrado;

    for (final usuario in usuarios) {
      if (usuario.id == id) {
        usuarioEncontrado = usuario;
        break;
      }
    }

    // No eliminamos usuarios inexistentes ni administradores.
    if (usuarioEncontrado == null ||
        usuarioEncontrado.rol == 'admin') {
      return false;
    }

    usuarios.removeWhere((usuario) {
      return usuario.id == id;
    });

    await guardarUsuarios(usuarios);

    return true;
  }

  // Crea el administrador inicial si todavía no existe.
  static Future<void> crearAdministradorInicial() async {
    final usuarios = await obtenerUsuarios();

    for (final usuario in usuarios) {
      if (usuario.rol == 'admin') {
        return;
      }
    }

    // Cuenta de demostración para las pruebas locales.
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

    await registrarUsuario(administrador);
  }
}
