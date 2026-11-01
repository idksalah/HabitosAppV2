
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habito.dart';

class PreferenciasService {
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

  static final ValueNotifier<ThemeMode> temaActual =
  ValueNotifier(ThemeMode.light);

  static final ValueNotifier<double> tamanoLetra =
  ValueNotifier(1.0);

  static final ValueNotifier<bool> ocultarCompletados =
  ValueNotifier(false);

  static Future<void> cargarAjustes() async {
    final preferencias = await SharedPreferences.getInstance();

    final oscuro = preferencias.getBool(claveTemaOscuro) ?? false;
    final tamano = preferencias.getDouble(claveTamanoLetra) ?? 1.0;
    final ocultar =
        preferencias.getBool(claveOcultarCompletados) ?? false;

    temaActual.value = oscuro ? ThemeMode.dark : ThemeMode.light;
    tamanoLetra.value = tamano;
    ocultarCompletados.value = ocultar;
  }

  static Future<void> guardarTema(bool oscuro) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setBool(claveTemaOscuro, oscuro);
    temaActual.value = oscuro ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> guardarTamanoLetra(double tamano) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setDouble(claveTamanoLetra, tamano);
    tamanoLetra.value = tamano;
  }

  static Future<void> guardarOcultarCompletados(bool ocultar) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setBool(claveOcultarCompletados, ocultar);
    ocultarCompletados.value = ocultar;
  }

  static Future<void> guardarDatosUsuario(
      String nombre,
      int objetivo,
      ) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setString(claveNombre, nombre);
    await preferencias.setInt(claveObjetivo, objetivo);
  }

  static Future<String?> obtenerNombre() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString(claveNombre);
  }

  static Future<int?> obtenerObjetivo() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getInt(claveObjetivo);
  }

  static Future<void> guardarHabitos(
      String usuarioId,
      List<Habito> habitos,
      ) async {
    final preferencias = await SharedPreferences.getInstance();

    final listaJson = habitos.map((habito) => habito.toJson()).toList();

    await preferencias.setString(
      '${claveHabitos}_$usuarioId',
      jsonEncode(listaJson),
    );

    final nombres = habitos.map((habito) => habito.nombre).toList();

    await preferencias.setStringList(
      '${claveNombresHabitos}_$usuarioId',
      nombres,
    );
  }

  static Future<List<Habito>> obtenerHabitos(String usuarioId) async {
    final preferencias = await SharedPreferences.getInstance();

    final textoJson = preferencias.getString(
      '${claveHabitos}_$usuarioId',
    );

    if (textoJson == null) {
      return [];
    }

    final List<dynamic> listaJson = jsonDecode(textoJson);

    return listaJson.map((elemento) {
      return Habito.fromJson(Map<String, dynamic>.from(elemento));
    }).toList();
  }

  static Future<List<String>> obtenerNombresHabitos(
      String usuarioId,
      ) async {
    final preferencias = await SharedPreferences.getInstance();

    return preferencias.getStringList(
      '${claveNombresHabitos}_$usuarioId',
    ) ??
        [];
  }

  static Future<bool> hayDatosUsuario() async {
    final nombre = await obtenerNombre();
    final objetivo = await obtenerObjetivo();

    return nombre != null &&
        nombre.isNotEmpty &&
        objetivo != null &&
        objetivo > 0;
  }

  static Future<void> registrarApertura() async {
    final preferencias = await SharedPreferences.getInstance();

    final aperturas = preferencias.getInt(claveAperturas) ?? 0;
    final ultimaApertura = preferencias.getString(claveUltimaApertura);

    if (ultimaApertura != null) {
      await preferencias.setString(
        claveAperturaAnterior,
        ultimaApertura,
      );
    }

    await preferencias.setInt(claveAperturas, aperturas + 1);

    final ahora = DateTime.now().toIso8601String();

    await preferencias.setString(claveUltimaApertura, ahora);
  }

  static Future<int> obtenerAperturas() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getInt(claveAperturas) ?? 0;
  }

  static Future<String?> obtenerUltimaApertura() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString(claveUltimaApertura);
  }

  static Future<String?> obtenerAperturaAnterior() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString(claveAperturaAnterior);
  }

  static Future<void> borrarDatos() async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.clear();

    temaActual.value = ThemeMode.light;
    tamanoLetra.value = 1.0;
    ocultarCompletados.value = false;
  }
}
