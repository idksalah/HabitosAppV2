
import 'package:flutter/material.dart';

import '../modelos/habito.dart';
import '../modelos/usuario.dart';
import '../servicios/preferencias_service.dart';
import '../servicios/estadisticas_service.dart';
import '../widgets/dato_estadistica.dart';

class EstadisticasScreen extends StatefulWidget {
  final Usuario usuario;

  const EstadisticasScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<EstadisticasScreen> createState() {
    return _EstadisticasScreenState();
  }
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  List<Habito> habitos = [];
  List<Map<String, Object?>> estadisticas = [];

  bool cargando = true;

  int aperturas = 0;
  String? aperturaAnterior;

  @override
  void initState() {
    super.initState();
    cargarEstadisticas();
  }

  // Recupera los hábitos y estadísticas del usuario.
  Future<void> cargarEstadisticas() async {
    final lista = await PreferenciasService.obtenerHabitos(
      widget.usuario.id,
    );

    // Actualizamos las rachas si ha cambiado el día.
    await PreferenciasService.actualizarRachas(
      widget.usuario.id,
    );

    // Recuperamos las estadísticas desde SQLite.
    final datos = await EstadisticasService.obtenerPorUsuario(
      widget.usuario.id,
    );

    final totalAperturas =
    await PreferenciasService.obtenerAperturas();

    final fechaAnterior =
    await PreferenciasService.obtenerAperturaAnterior();

    if (!mounted) return;

    setState(() {
      habitos = lista;
      estadisticas = datos;
      aperturas = totalAperturas;
      aperturaAnterior = fechaAnterior;
      cargando = false;
    });
  }

  // Busca las estadísticas de un hábito.
  Map<String, Object?>? buscarEstadistica(Habito habito) {
    for (final dato in estadisticas) {
      if (dato['habitoId'] == habito.id) {
        return dato;
      }
    }

    return null;
  }

  // Muestra una fecha de forma más clara.
  String mostrarFecha(String? fechaGuardada) {
    if (fechaGuardada == null || fechaGuardada.isEmpty) {
      return 'Todavía no hay una apertura anterior registrada';
    }

    final fecha = DateTime.tryParse(fechaGuardada);

    if (fecha == null) {
      return 'Fecha no disponible';
    }

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$anio a las $hora:$minuto';
  }

  // Muestra las estadísticas de cada hábito.
  Widget mostrarEstadisticaHabito(Habito habito) {
    final datos = buscarEstadistica(habito);

    final int? dias = datos?['diasCompletados'] as int?;
    final int? racha = datos?['rachaActual'] as int?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Nombre del hábito.
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(habito.color),
                  child: const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    habito.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Total de días completados.
            DatoEstadistica(
              titulo: 'Días completados',
              valor: dias == null ? 'Sin datos' : '$dias',
              icono: Icons.check_circle,
              color: Colors.green,
            ),

            // Racha actual.
            DatoEstadistica(
              titulo: 'Racha actual',
              valor: racha == null ? 'Sin datos' : '$racha días',
              icono: Icons.local_fire_department,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),

      body: cargando
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Estadísticas de uso',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text(
                'Aperturas de la aplicación',
              ),
              subtitle: Text('$aperturas veces'),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Apertura anterior'),
              subtitle: Text(
                mostrarFecha(aperturaAnterior),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Estadísticas de tus hábitos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          if (habitos.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Todavía no tienes hábitos.',
                ),
              ),
            )
          else
            for (final habito in habitos)
              mostrarEstadisticaHabito(habito),
        ],
      ),
    );
  }
}
