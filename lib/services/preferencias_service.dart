
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habito.dart';

class PreferenciasService {
  // Claves para guardar los datos.
  static const String claveNombre = 'nombre';
  static const String claveObjetivo = 'objetivo';
  static const String claveHabitos = 'habitos';
  static const String claveNombresHabitos = 'nombresHabitos';
  static const String claveTemaOscuro = 'temaOscuro';
  static const String claveTamanoLetra = 'tamanoLetra';
  static const String claveOcultarCompletados = 'ocultarCompletados';
  static const String claveAperturas = 'aperturas';
  static const String claveUltimaApertura = 'ultimaApertura';
  static const String claveAperturaAnterior = 'aperturaAnterior';

  // Valores que utilizan las pantallas.
  static final ValueNotifier<ThemeMode> temaActual =
  ValueNotifier(ThemeMode.light);

  static final ValueNotifier<double> tamanoLetra =
  ValueNotifier(1.0);

  static final ValueNotifier<bool> ocultarCompletados =
  ValueNotifier(false);

  // Carga los ajustes iniciales.
  static Future<void> cargarAjustes() async {
    temaActual.value = ThemeMode.light;
    tamanoLetra.value = 1.0;
    ocultarCompletados.value = false;
  }

  // Cambia el tema de la aplicación.
  static Future<void> guardarTema(bool oscuro) async {
    temaActual.value =
    oscuro ? ThemeMode.dark : ThemeMode.light;
  }

  // Cambia el tamaño de letra.
  static Future<void> guardarTamanoLetra(double tamano) async {
    tamanoLetra.value = tamano;
  }

  // Cambia la opción de ocultar hábitos completados.
  static Future<void> guardarOcultarCompletados(
      bool ocultar,
      ) async {
    ocultarCompletados.value = ocultar;
  }

  // Guarda el nombre y el objetivo de un usuario.
  static Future<void> guardarDatosUsuario(
      String usuarioId,
      String nombre,
      int objetivo,
      ) async {
    final preferencias =
    await SharedPreferences.getInstance();

    await preferencias.setString(
      '${claveNombre}_$usuarioId',
      nombre,
    );

    await preferencias.setInt(
      '${claveObjetivo}_$usuarioId',
      objetivo,
    );
  }

  // Recupera el nombre de un usuario.
  static Future<String?> obtenerNombre(
      String usuarioId,
      ) async {
    final preferencias =
    await SharedPreferences.getInstance();

    return preferencias.getString(
      '${claveNombre}_$usuarioId',
    );
  }

  // Recupera el objetivo diario.
  static Future<int?> obtenerObjetivo(
      String usuarioId,
      ) async {
    final preferencias =
    await SharedPreferences.getInstance();

    return preferencias.getInt(
      '${claveObjetivo}_$usuarioId',
    );
  }

  // Guarda los hábitos de un usuario.
  static Future<void> guardarHabitos(
      String usuarioId,
      List<Habito> habitos,
      ) async {
    final preferencias =
    await SharedPreferences.getInstance();

    final listaJson = <Map<String, dynamic>>[];

    for (final habito in habitos) {
      listaJson.add(habito.toJson());
    }

    await preferencias.setString(
      '${claveHabitos}_$usuarioId',
      jsonEncode(listaJson),
    );

    // Guarda también los nombres de los hábitos.
    final List<String> nombres = [];

    for (final habito in habitos) {
      nombres.add(habito.nombre);
    }

    await preferencias.setStringList(
      '${claveNombresHabitos}_$usuarioId',
      nombres,
    );
  }

  // Recupera los hábitos de un usuario.
  static Future<List<Habito>> obtenerHabitos(
      String usuarioId,
      ) async {
    final preferencias =
    await SharedPreferences.getInstance();

    final textoJson = preferencias.getString(
      '${claveHabitos}_$usuarioId',
    );

    if (textoJson == null || textoJson.isEmpty) {
      return [];
    }

    final List<dynamic> listaJson = jsonDecode(textoJson);

    final List<Habito> habitos = [];

    for (final elemento in listaJson) {
      habitos.add(
        Habito.fromJson(
          Map<String, dynamic>.from(elemento),
        ),
      );
    }

    return habitos;
  }

  // Recupera los nombres de los hábitos.
  static Future<List<String>> obtenerNombresHabitos(
      String usuarioId,
      ) async {
    final preferencias =
    await SharedPreferences.getInstance();

    return preferencias.getStringList(
      '${claveNombresHabitos}_$usuarioId',
    ) ??
        [];
  }

  // Borra los datos y ajustes de un usuario.
  static Future<void> eliminarDatosUsuario(
      String usuarioId,
      ) async {
    final preferencias =
    await SharedPreferences.getInstance();

    await preferencias.remove(
      '${claveNombre}_$usuarioId',
    );

    await preferencias.remove(
      '${claveObjetivo}_$usuarioId',
    );

    await preferencias.remove(
      '${claveHabitos}_$usuarioId',
    );

    await preferencias.remove(
      '${claveNombresHabitos}_$usuarioId',
    );

    await preferencias.remove(
      '${claveTemaOscuro}_$usuarioId',
    );

    await preferencias.remove(
      '${claveTamanoLetra}_$usuarioId',
    );

    await preferencias.remove(
      '${claveOcultarCompletados}_$usuarioId',
    );
  }

  // Comprueba si el usuario tiene datos guardados.
  static Future<bool> hayDatosUsuario(
      String usuarioId,
      ) async {
    final nombre = await obtenerNombre(usuarioId);
    final objetivo = await obtenerObjetivo(usuarioId);

    return nombre != null &&
        nombre.isNotEmpty &&
        objetivo != null &&
        objetivo > 0;
  }

  // Registra una nueva apertura de la aplicación.
  static Future<void> registrarApertura() async {
    final preferencias =
    await SharedPreferences.getInstance();

    final aperturas =
        preferencias.getInt(claveAperturas) ?? 0;

    final ultimaApertura =
    preferencias.getString(claveUltimaApertura);

    if (ultimaApertura != null) {
      await preferencias.setString(
        claveAperturaAnterior,
        ultimaApertura,
      );
    }

    await preferencias.setInt(
      claveAperturas,
      aperturas + 1,
    );

    final ahora = DateTime.now().toIso8601String();

    await preferencias.setString(
      claveUltimaApertura,
      ahora,
    );
  }

  // Recupera el número de aperturas.
  static Future<int> obtenerAperturas() async {
    final preferencias =
    await SharedPreferences.getInstance();

    return preferencias.getInt(claveAperturas) ?? 0;
  }

  // Recupera la última apertura.
  static Future<String?> obtenerUltimaApertura() async {
    final preferencias =
    await SharedPreferences.getInstance();

    return preferencias.getString(
      claveUltimaApertura,
    );
  }

  // Recupera la apertura anterior.
  static Future<String?> obtenerAperturaAnterior() async {
    final preferencias =
    await SharedPreferences.getInstance();

    return preferencias.getString(
      claveAperturaAnterior,
    );
  }

  // Borra todos los datos guardados en SharedPreferences.
  static Future<void> borrarDatos() async {
    final preferencias =
    await SharedPreferences.getInstance();

    await preferencias.clear();

    temaActual.value = ThemeMode.light;
    tamanoLetra.value = 1.0;
    ocultarCompletados.value = false;
  }
}
