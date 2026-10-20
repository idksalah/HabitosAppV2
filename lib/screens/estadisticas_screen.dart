import 'package:flutter/material.dart';

import '../models/habito.dart';
import '../services/preferencias_service.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  List<Habito> habitos = [];
  bool cargando = true;

  int aperturas = 0;
  String? aperturaAnterior;

  @override
  void initState() {
    super.initState();
    cargarEstadisticas();
  }

  // Recupera las estadísticas de hábitos y de uso.
  Future<void> cargarEstadisticas() async {
    final lista = await PreferenciasService.obtenerHabitos();
    final totalAperturas = await PreferenciasService.obtenerAperturas();
    final fechaAnterior = await PreferenciasService.obtenerAperturaAnterior();

    if (!mounted) return;

    setState(() {
      habitos = lista;
      aperturas = totalAperturas;
      aperturaAnterior = fechaAnterior;
      cargando = false;
    });
  }

  // Calcula la racha actual de un hábito.
  int calcularRacha(Habito habito) {
    if (habito.fechasCompletado.isEmpty) {
      return 0;
    }

    final fechas = habito.fechasCompletado.toSet();
    DateTime fecha = DateTime.now();

    String formatoFecha(DateTime fecha) {
      final mes = fecha.month.toString().padLeft(2, '0');
      final dia = fecha.day.toString().padLeft(2, '0');

      return '${fecha.year}-$mes-$dia';
    }

    // Si hoy no está completado, comprobamos desde ayer.
    if (!fechas.contains(formatoFecha(fecha))) {
      fecha = fecha.subtract(const Duration(days: 1));
    }

    int racha = 0;

    while (fechas.contains(formatoFecha(fecha))) {
      racha++;
      fecha = fecha.subtract(const Duration(days: 1));
    }

    return racha;
  }

  // Convierte la fecha guardada en una fecha legible.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Estadísticas de uso',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.phone_android),
                    title: const Text('Aperturas de la aplicación'),
                    subtitle: Text('$aperturas veces'),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Apertura anterior'),
                    subtitle: Text(mostrarFecha(aperturaAnterior)),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Estadísticas de tus hábitos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (habitos.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Todavía no tienes hábitos.'),
                    ),
                  )
                else
                  ...habitos.map((habito) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(habito.color),
                          child: const Icon(
                            Icons.water_drop,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(habito.nombre),
                        subtitle: Text(
                          'Días completados: '
                          '${habito.fechasCompletado.toSet().length}\n'
                          'Racha actual: ${calcularRacha(habito)} días',
                        ),
                        isThreeLine: true,
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
