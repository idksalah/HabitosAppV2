import 'package:flutter/material.dart';
import 'package:habitos_app/screens/estadisticas_screen.dart';
import 'package:habitos_app/screens/ajustes_screen.dart';

import '../models/habito.dart';
import '../services/preferencias_service.dart';
import '../widgets/tarjeta_habito.dart';
import 'editar_habito_screen.dart';

class InicioScreen extends StatefulWidget {
  final String nombre;
  final int objetivo;

  const InicioScreen({super.key, required this.nombre, required this.objetivo});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  List<Habito> habitos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarHabitos();
  }

  // Recupera los hábitos guardados.
  Future<void> cargarHabitos() async {
    final lista = await PreferenciasService.obtenerHabitos();

    if (!mounted) return;

    setState(() {
      habitos = lista;
      cargando = false;
    });
  }

  // Devuelve la fecha de hoy en formato año-mes-día.
  String obtenerFechaHoy() {
    final hoy = DateTime.now();
    final mes = hoy.month.toString().padLeft(2, '0');
    final dia = hoy.day.toString().padLeft(2, '0');

    return '${hoy.year}-$mes-$dia';
  }

  // Comprueba si un hábito está completado hoy.
  bool estaCompletadoHoy(Habito habito) {
    return habito.fechasCompletado.contains(obtenerFechaHoy());
  }

  // Cuenta los hábitos completados hoy.
  int obtenerCompletadosHoy() {
    return habitos.where(estaCompletadoHoy).length;
  }

  // Marca o desmarca un hábito como completado.
  Future<void> cambiarCompletado(Habito habito, bool completado) async {
    final hoy = obtenerFechaHoy();

    if (completado) {
      if (!habito.fechasCompletado.contains(hoy)) {
        habito.fechasCompletado.add(hoy);
      }
    } else {
      habito.fechasCompletado.remove(hoy);
    }

    await PreferenciasService.guardarHabitos(habitos);

    if (!mounted) return;

    setState(() {});
  }

  // Crea y guarda un hábito nuevo.
  Future<void> guardarNuevoHabito(String nombre) async {
    final nuevoHabito = Habito(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      color: Colors.green.toARGB32(),
    );

    final nuevaLista = List<Habito>.from(habitos);
    nuevaLista.add(nuevoHabito);

    await PreferenciasService.guardarHabitos(nuevaLista);

    if (!mounted) return;

    setState(() {
      habitos = nuevaLista;
    });
  }

  // Abre el formulario para añadir un hábito.
  Future<void> mostrarFormulario() async {
    final controlador = TextEditingController();

    String? nombre;

    try {
      nombre = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Nuevo hábito'),
            content: TextField(
              controller: controlador,
              autofocus: false,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (texto) {
                final nombreIntroducido = texto.trim();

                if (nombreIntroducido.isNotEmpty) {
                  Navigator.of(dialogContext).pop(nombreIntroducido);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final texto = controlador.text.trim();

                  if (texto.isNotEmpty) {
                    Navigator.of(dialogContext).pop(texto);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    } finally {
      controlador.dispose();
    }

    if (!mounted) return;

    if (nombre == null || nombre.trim().isEmpty) return;

    await guardarNuevoHabito(nombre);
  }

  // Abre la pantalla de edición y guarda los cambios.
  Future<void> editarHabito(Habito habito) async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditarHabitoScreen(nombre: habito.nombre, color: habito.color),
      ),
    );

    if (!mounted || resultado == null) return;

    final nuevoNombre = resultado['nombre'] as String;
    final nuevoColor = resultado['color'] as int;

    setState(() {
      habito.nombre = nuevoNombre;
      habito.color = nuevoColor;
    });

    await PreferenciasService.guardarHabitos(habitos);
  }

  // Elimina un hábito después de pedir confirmación.
  Future<void> eliminarHabito(Habito habito) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar hábito'),
          content: Text('¿Quieres eliminar "${habito.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) return;

    final nuevaLista = List<Habito>.from(habitos);
    nuevaLista.removeWhere((elemento) => elemento.id == habito.id);

    await PreferenciasService.guardarHabitos(nuevaLista);

    if (!mounted) return;

    setState(() {
      habitos = nuevaLista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis hábitos')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '¡Hola, ${widget.nombre}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Objetivo diario: ${widget.objetivo} hábitos'),
                      const SizedBox(height: 8),
                      Text(
                        'Progreso de hoy: '
                        '${obtenerCompletadosHoy()} / ${widget.objetivo}',
                      ),
                    ],
                  ),
                ),

                // Escucha los cambios en la opción de ocultar completados.
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: PreferenciasService.ocultarCompletados,
                    builder: (context, ocultar, child) {
                      // Filtra solo los hábitos completados hoy.
                      final habitosVisibles = ocultar
                          ? habitos
                                .where((habito) => !estaCompletadoHoy(habito))
                                .toList()
                          : habitos;

                      if (habitosVisibles.isEmpty) {
                        return Center(
                          child: Text(
                            habitos.isEmpty
                                ? 'Todavía no tienes hábitos.\n'
                                      'Pulsa + para añadir uno.'
                                : '¡Has completado todos tus hábitos de hoy!',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: habitosVisibles.length,
                        itemBuilder: (context, index) {
                          final habito = habitosVisibles[index];

                          return TarjetaHabito(
                            habito: habito,
                            completado: estaCompletadoHoy(habito),
                            alCambiarCompletado: (completado) {
                              cambiarCompletado(habito, completado);
                            },
                            alEditar: () {
                              editarHabito(habito);
                            },
                            alEliminar: () {
                              eliminarHabito(habito);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

      // Los tres botones aparecen juntos en la parte inferior derecha.
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Botón de estadísticas.
          FloatingActionButton(
            heroTag: 'estadisticas',
            tooltip: 'Estadísticas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EstadisticasScreen(),
                ),
              );
            },
            child: const Icon(Icons.bar_chart),
          ),

          const SizedBox(height: 12),

          // Botón de ajustes.
          FloatingActionButton(
            heroTag: 'ajustes',
            tooltip: 'Ajustes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AjustesScreen()),
              );
            },
            child: const Icon(Icons.settings),
          ),

          const SizedBox(height: 12),

          // Botón para añadir un hábito.
          FloatingActionButton(
            heroTag: 'nuevoHabito',
            tooltip: 'Añadir hábito',
            onPressed: mostrarFormulario,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
