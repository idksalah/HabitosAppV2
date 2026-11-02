
import 'package:flutter/material.dart';

import '../modelos/habito.dart';
import '../modelos/usuario.dart';
import '../servicios/preferencias_service.dart';
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
  bool cargando = true;

  int aperturas = 0;
  String? aperturaAnterior;

  @override
  void initState() {
    super.initState();
    cargarEstadisticas();
  }

  // Recupera las estadísticas del usuario.
  Future<void> cargarEstadisticas() async {
    final lista = await PreferenciasService.obtenerHabitos(
      widget.usuario.id,
    );

    final totalAperturas =
    await PreferenciasService.obtenerAperturas();

    final fechaAnterior =
    await PreferenciasService.obtenerAperturaAnterior();

    if (!mounted) return;

    setState(() {
      habitos = lista;
      aperturas = totalAperturas;
      aperturaAnterior = fechaAnterior;
      cargando = false;
    });
  }

  // Convierte una fecha al formato año-mes-día.
  String formatoFecha(DateTime fecha) {
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '${fecha.year}-$mes-$dia';
  }

  // Calcula la racha actual de un hábito.
  int calcularRacha(Habito habito) {
    if (habito.fechasCompletado.isEmpty) {
      return 0;
    }

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
              Card(
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

                      // Componente reutilizable.
                      DatoEstadistica(
                        titulo: 'Días completados',
                        valor:
                        '${habito.fechasCompletado.toSet().length}',
                        icono: Icons.check_circle,
                        color: Colors.green,
                      ),

                      // Utilizamos el mismo componente.
                      DatoEstadistica(
                        titulo: 'Racha actual',
                        valor: '${calcularRacha(habito)} días',
                        icono: Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
