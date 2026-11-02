
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/habito.dart';
import 'database_helper.dart';

class PreferenciasService {
  // Claves para guardar los ajustes.
  static const String claveNombre = 'nombre';
  static const String claveObjetivo = 'objetivo';
  static const String claveTemaOscuro = 'temaOscuro';
  static const String claveTamanoLetra = 'tamanoLetra';
  static const String claveOcultarCompletados = 'ocultarCompletados';
  static const String claveAperturas = 'aperturas';
  static const String claveUltimaApertura = 'ultimaApertura';
  static const String claveAperturaAnterior = 'aperturaAnterior';

  // Valores utilizados por las pantallas.
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

  // Cambia el tema.
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

  // Guarda el nombre y el objetivo del usuario.
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

  // Recupera el nombre del usuario.
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

  // Convierte una fecha al formato año-mes-día.
  static String formatoFecha(DateTime fecha) {
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '${fecha.year}-$mes-$dia';
  }

  // Calcula la racha actual de un hábito.
  static int calcularRacha(Habito habito) {
    final fechas = habito.fechasCompletado.toSet();
    final hoy = DateTime.now();

    DateTime fecha = DateTime(
      hoy.year,
      hoy.month,
      hoy.day,
    );

    // Si hoy no está completado, empezamos desde ayer.
    if (!fechas.contains(formatoFecha(fecha))) {
      fecha = DateTime(
        fecha.year,
        fecha.month,
        fecha.day - 1,
      );
    }

    int racha = 0;

    while (fechas.contains(formatoFecha(fecha))) {
      racha++;

      fecha = DateTime(
        fecha.year,
        fecha.month,
        fecha.day - 1,
      );
    }

    return racha;
  }

  // Guarda los hábitos del usuario en SQLite.
  static Future<void> guardarHabitos(
      String usuarioId,
      List<Habito> habitos,
      ) async {
    final db = await DatabaseHelper.obtenerBaseDatos();

    await db.transaction((transaccion) async {
      // Recuperamos los hábitos guardados.
      final anteriores = await transaccion.query(
        'habitos',
        columns: ['id'],
        where: 'usuarioId = ?',
        whereArgs: [usuarioId],
      );

      // Eliminamos los hábitos que ya no existen.
      for (final anterior in anteriores) {
        bool existe = false;

        for (final habito in habitos) {
          if (habito.id == anterior['id']) {
            existe = true;
            break;
          }
        }

        if (!existe) {
          await transaccion.delete(
            'habitos',
            where: 'id = ? AND usuarioId = ?',
            whereArgs: [anterior['id'], usuarioId],
          );
        }
      }

      // Guardamos cada hábito.
      for (final habito in habitos) {
        // Buscamos las fechas guardadas anteriormente.
        final anterior = await transaccion.query(
          'habitos',
          columns: ['fechasCompletado'],
          where: 'id = ? AND usuarioId = ?',
          whereArgs: [habito.id, usuarioId],
        );

        bool fechasCambiadas = anterior.isEmpty;

        if (anterior.isNotEmpty) {
          final texto = anterior.first['fechasCompletado']
          as String;

          final fechasAnteriores =
          List<String>.from(jsonDecode(texto));

          final fechasAntes = fechasAnteriores.toSet();
          final fechasAhora =
          habito.fechasCompletado.toSet();

          // Comprobamos si las fechas son diferentes.
          fechasCambiadas =
              fechasAntes.length != fechasAhora.length ||
                  !fechasAntes.containsAll(fechasAhora);
        }

        final datos = {
          'id': habito.id,
          'usuarioId': usuarioId,
          'nombre': habito.nombre,
          'color': habito.color,
          'fechasCompletado':
          jsonEncode(habito.fechasCompletado),
        };

        // Insertamos o actualizamos el hábito.
        if (anterior.isEmpty) {
          await transaccion.insert(
            'habitos',
            datos,
          );
        } else {
          await transaccion.update(
            'habitos',
            datos,
            where: 'id = ? AND usuarioId = ?',
            whereArgs: [habito.id, usuarioId],
          );
        }

        // Comprobamos si el hábito tiene estadísticas.
        final estadisticaAnterior =
        await transaccion.query(
          'estadisticas',
          columns: ['id'],
          where: 'habitoId = ?',
          whereArgs: [habito.id],
        );

        // Solo recalculamos cuando cambian las fechas
        // o todavía no existen estadísticas.
        if (fechasCambiadas || estadisticaAnterior.isEmpty) {
          final estadisticas = {
            'habitoId': habito.id,
            'rachaActual': calcularRacha(habito),
            'diasCompletados':
            habito.fechasCompletado.toSet().length,
          };

          if (estadisticaAnterior.isEmpty) {
            await transaccion.insert(
              'estadisticas',
              estadisticas,
            );
          } else {
            await transaccion.update(
              'estadisticas',
              estadisticas,
              where: 'habitoId = ?',
              whereArgs: [habito.id],
            );
          }
        }
      }
    });
  }

  // Recupera los hábitos del usuario desde SQLite.
  static Future<List<Habito>> obtenerHabitos(
      String usuarioId,
      ) async {
    final db = await DatabaseHelper.obtenerBaseDatos();

    final datos = await db.query(
      'habitos',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'nombre',
    );

    final List<Habito> habitos = [];

    for (final elemento in datos) {
      final mapa = Map<String, dynamic>.from(elemento);

      // Convertimos las fechas guardadas en JSON.
      mapa['fechasCompletado'] =
          jsonDecode(mapa['fechasCompletado'] as String);

      habitos.add(Habito.fromJson(mapa));
    }

    return habitos;
  }

  // Recupera los nombres de los hábitos.
  static Future<List<String>> obtenerNombresHabitos(
      String usuarioId,
      ) async {
    final db = await DatabaseHelper.obtenerBaseDatos();

    final datos = await db.query(
      'habitos',
      columns: ['nombre'],
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'nombre',
    );

    final List<String> nombres = [];

    for (final elemento in datos) {
      nombres.add(elemento['nombre'] as String);
    }

    return nombres;
  }

  // Borra los hábitos y ajustes de un usuario.
  static Future<void> eliminarDatosUsuario(
      String usuarioId,
      ) async {
    final db = await DatabaseHelper.obtenerBaseDatos();

    // Las estadísticas también se eliminan
    // mediante ON DELETE CASCADE.
    await db.delete(
      'habitos',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );

    final preferencias =
    await SharedPreferences.getInstance();

    await preferencias.remove(
      '${claveNombre}_$usuarioId',
    );

    await preferencias.remove(
      '${claveObjetivo}_$usuarioId',
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

  // Registra una apertura de la aplicación.
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

  // Borra las preferencias generales.
  static Future<void> borrarDatos() async {
    final preferencias =
    await SharedPreferences.getInstance();

    await preferencias.clear();

    temaActual.value = ThemeMode.light;
    tamanoLetra.value = 1.0;
    ocultarCompletados.value = false;
  }
}
