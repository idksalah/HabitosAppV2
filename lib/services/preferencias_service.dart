// Importamos las librerías necesarias.
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

  // Valores que pueden consultar las pantallas.
  static final ValueNotifier<ThemeMode> temaActual = ValueNotifier(
    ThemeMode.light,
  );

  static final ValueNotifier<double> tamanoLetra = ValueNotifier(1.0);

  static final ValueNotifier<bool> ocultarCompletados = ValueNotifier(false);

  // Carga las preferencias guardadas al iniciar la aplicación.
  static Future<void> cargarAjustes() async {
    final preferencias = await SharedPreferences.getInstance();

    final oscuro = preferencias.getBool(claveTemaOscuro) ?? false;
    final tamano = preferencias.getDouble(claveTamanoLetra) ?? 1.0;
    final ocultar = preferencias.getBool(claveOcultarCompletados) ?? false;

    temaActual.value = oscuro ? ThemeMode.dark : ThemeMode.light;
    tamanoLetra.value = tamano;
    ocultarCompletados.value = ocultar;
  }

  // Guarda y aplica el tema seleccionado.
  static Future<void> guardarTema(bool oscuro) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setBool(claveTemaOscuro, oscuro);

    temaActual.value = oscuro ? ThemeMode.dark : ThemeMode.light;
  }

  // Guarda y aplica el tamaño de letra.
  static Future<void> guardarTamanoLetra(double tamano) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setDouble(claveTamanoLetra, tamano);

    tamanoLetra.value = tamano;
  }

  // Guarda si queremos ocultar los hábitos completados.
  static Future<void> guardarOcultarCompletados(bool ocultar) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setBool(claveOcultarCompletados, ocultar);

    ocultarCompletados.value = ocultar;
  }

  // Guarda el nombre y el objetivo del usuario.
  static Future<void> guardarDatosUsuario(String nombre, int objetivo) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setString(claveNombre, nombre);
    await preferencias.setInt(claveObjetivo, objetivo);
  }

  // Recupera el nombre del usuario.
  static Future<String?> obtenerNombre() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString(claveNombre);
  }

  // Recupera el objetivo diario.
  static Future<int?> obtenerObjetivo() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getInt(claveObjetivo);
  }

  // Guarda los hábitos como texto JSON.
  static Future<void> guardarHabitos(List<Habito> habitos) async {
    final preferencias = await SharedPreferences.getInstance();

    final listaJson = <Map<String, dynamic>>[];

    for (final habito in habitos) {
      listaJson.add(habito.toJson());
    }

    await preferencias.setString(claveHabitos, jsonEncode(listaJson));

    // También guardamos los nombres como List<String>.
    // Esto permite utilizar el tipo de dato específico de SharedPreferences.
    final nombres = habitos.map((habito) => habito.nombre).toList();

    await preferencias.setStringList(claveNombresHabitos, nombres);
  }

  // Recupera los hábitos guardados desde JSON.
  static Future<List<Habito>> obtenerHabitos() async {
    final preferencias = await SharedPreferences.getInstance();
    final textoJson = preferencias.getString(claveHabitos);

    if (textoJson == null) {
      return [];
    }

    final List<dynamic> listaJson = jsonDecode(textoJson);
    final List<Habito> habitos = [];

    for (final elemento in listaJson) {
      habitos.add(Habito.fromJson(Map<String, dynamic>.from(elemento)));
    }

    return habitos;
  }

  // Recupera la lista de nombres usando getStringList().
  static Future<List<String>> obtenerNombresHabitos() async {
    final preferencias = await SharedPreferences.getInstance();

    return preferencias.getStringList(claveNombresHabitos) ?? [];
  }

  // Comprueba si ya hay datos de usuario.
  static Future<bool> hayDatosUsuario() async {
    final nombre = await obtenerNombre();
    final objetivo = await obtenerObjetivo();

    return nombre != null &&
        nombre.isNotEmpty &&
        objetivo != null &&
        objetivo > 0;
  }

  // Registra una apertura y conserva la fecha de la sesión anterior.
  static Future<void> registrarApertura() async {
    final preferencias = await SharedPreferences.getInstance();

    final aperturas = preferencias.getInt(claveAperturas) ?? 0;
    final ultimaApertura = preferencias.getString(claveUltimaApertura);

    if (ultimaApertura != null) {
      await preferencias.setString(claveAperturaAnterior, ultimaApertura);
    }

    await preferencias.setInt(claveAperturas, aperturas + 1);

    final ahora = DateTime.now().toIso8601String();

    await preferencias.setString(claveUltimaApertura, ahora);
  }

  // Recupera el número total de aperturas.
  static Future<int> obtenerAperturas() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getInt(claveAperturas) ?? 0;
  }

  // Recupera la fecha y hora de la última apertura.
  static Future<String?> obtenerUltimaApertura() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString(claveUltimaApertura);
  }

  // Recupera la fecha y hora de la apertura anterior.
  static Future<String?> obtenerAperturaAnterior() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString(claveAperturaAnterior);
  }

  // Borra todos los datos y restablece los ajustes.
  static Future<void> borrarDatos() async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.clear();

    temaActual.value = ThemeMode.light;
    tamanoLetra.value = 1.0;
    ocultarCompletados.value = false;
  }
}
