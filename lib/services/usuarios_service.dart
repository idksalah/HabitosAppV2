
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';

class UsuariosService {
  static const String claveUsuarios = 'usuarios';

  static Future<List<Usuario>> obtenerUsuarios() async {
    final preferencias = await SharedPreferences.getInstance();

    final datos = preferencias.getString(claveUsuarios);

    if (datos == null) {
      return [];
    }

    final lista = jsonDecode(datos) as List;

    return lista.map((elemento) {
      return Usuario.fromJson(
        Map<String, dynamic>.from(elemento),
      );
    }).toList();
  }

  static Future<bool> registrarUsuario(Usuario usuario) async {
    final usuarios = await obtenerUsuarios();

    for (final elemento in usuarios) {
      if (elemento.correo.toLowerCase() ==
          usuario.correo.toLowerCase()) {
        return false;
      }
    }

    usuarios.add(usuario);

    final preferencias = await SharedPreferences.getInstance();

    final listaJson = usuarios.map((usuario) {
      return usuario.toJson();
    }).toList();

    await preferencias.setString(
      claveUsuarios,
      jsonEncode(listaJson),
    );

    return true;
  }

  static Future<Usuario?> iniciarSesion(
      String correo,
      String contrasena,
      ) async {
    final usuarios = await obtenerUsuarios();

    for (final usuario in usuarios) {
      if (usuario.correo.toLowerCase() == correo.toLowerCase() &&
          usuario.contrasena == contrasena) {
        return usuario;
      }
    }

    return null;
  }

  static Future<bool> eliminarUsuario(String id) async {
    final usuarios = await obtenerUsuarios();

    usuarios.removeWhere((usuario) => usuario.id == id);

    final preferencias = await SharedPreferences.getInstance();

    final listaJson = usuarios.map((usuario) {
      return usuario.toJson();
    }).toList();

    await preferencias.setString(
      claveUsuarios,
      jsonEncode(listaJson),
    );

    return true;
  }

  static Future<void> crearAdministradorInicial() async {
    final usuarios = await obtenerUsuarios();

    for (final usuario in usuarios) {
      if (usuario.rol == 'admin') {
        return;
      }
    }

    final administrador = Usuario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: 'admin',
      correo: 'admin@admin.com',
      contrasena: 'admin1234',
      rol: 'admin',
      fechaCreacion: DateTime.now(),
    );

    await registrarUsuario(administrador);
  }

}
