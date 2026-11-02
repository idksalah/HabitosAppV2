
import 'package:flutter/material.dart';

import 'estadisticas_screen.dart';
import 'ajustes_screen.dart';
import 'login_page.dart';
import 'editar_habito_screen.dart';

import '../models/habito.dart';
import '../models/usuario.dart';
import '../services/preferencias_service.dart';
import '../widgets/tarjeta_habito.dart';

class InicioScreen extends StatefulWidget {
  final Usuario usuario;
  final String nombre;
  final int objetivo;

  const InicioScreen({
    super.key,
    required this.usuario,
    required this.nombre,
    required this.objetivo,
  });

  @override
  State<InicioScreen> createState() {
    return _InicioScreenState();
  }
}

class _InicioScreenState extends State<InicioScreen> {
  List<Habito> habitos = [];
  bool cargando = true;

  String nombreActual = '';
  int objetivoActual = 3;

  @override
  void initState() {
    super.initState();

    nombreActual = widget.nombre;
    objetivoActual = widget.objetivo;

    cargarPerfil();
    cargarHabitos();
  }

  // Cierra la sesión y vuelve al login.
  void cerrarSesion() {
    PreferenciasService.temaActual.value = ThemeMode.light;
    PreferenciasService.tamanoLetra.value = 1.0;
    PreferenciasService.ocultarCompletados.value = false;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  // Recupera el nombre y objetivo del usuario.
  Future<void> cargarPerfil() async {
    final id = widget.usuario.id;

    String? nombre =
    await PreferenciasService.obtenerNombre(id);

    int? objetivo =
    await PreferenciasService.obtenerObjetivo(id);

    if (nombre == null ||
        nombre.isEmpty ||
        objetivo == null ||
        objetivo <= 0) {
      nombre = widget.usuario.nombre;
      objetivo = 3;

      await PreferenciasService.guardarDatosUsuario(
        id,
        nombre,
        objetivo,
      );
    }

    if (!mounted) return;

    setState(() {
      nombreActual = nombre!;
      objetivoActual = objetivo!;
    });
  }

  // Recupera los hábitos guardados del usuario.
  Future<void> cargarHabitos() async {
    final lista = await PreferenciasService.obtenerHabitos(
      widget.usuario.id,
    );

    if (!mounted) return;

    setState(() {
      habitos = lista;
      cargando = false;
    });
  }

  // Obtiene la fecha actual.
  String obtenerFechaHoy() {
    final hoy = DateTime.now();

    final mes = hoy.month.toString().padLeft(2, '0');
    final dia = hoy.day.toString().padLeft(2, '0');

    return '${hoy.year}-$mes-$dia';
  }

  // Comprueba si un hábito está completado hoy.
  bool estaCompletadoHoy(Habito habito) {
    return habito.fechasCompletado.contains(
      obtenerFechaHoy(),
    );
  }

  // Cuenta los hábitos completados hoy.
  int obtenerCompletadosHoy() {
    int completados = 0;

    for (final habito in habitos) {
      if (estaCompletadoHoy(habito)) {
        completados++;
      }
    }

    return completados;
  }

  // Marca o desmarca un hábito como completado.
  Future<void> cambiarCompletado(
      Habito habito,
      bool completado,
      ) async {
    final hoy = obtenerFechaHoy();

    if (completado) {
      if (!habito.fechasCompletado.contains(hoy)) {
        habito.fechasCompletado.add(hoy);
      }
    } else {
      habito.fechasCompletado.remove(hoy);
    }

    await PreferenciasService.guardarHabitos(
      widget.usuario.id,
      habitos,
    );

    if (!mounted) return;

    setState(() {});
  }

  // Abre la pantalla para crear un nuevo hábito.
  Future<void> mostrarFormulario() async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarHabitoScreen(
          nombre: '',
          color: Colors.green.toARGB32(),
        ),
      ),
    );

    if (!mounted || resultado == null) return;

    final nombre = resultado['nombre'] as String;
    final color = resultado['color'] as int;

    if (nombre.trim().isEmpty) return;

    await guardarNuevoHabito(nombre.trim(), color);
  }

  // Crea y guarda un nuevo hábito.
  Future<void> guardarNuevoHabito(
      String nombre,
      int color,
      ) async {
    final nuevoHabito = Habito(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      color: color,
    );

    final nuevaLista = List<Habito>.from(habitos);

    nuevaLista.add(nuevoHabito);

    await PreferenciasService.guardarHabitos(
      widget.usuario.id,
      nuevaLista,
    );

    if (!mounted) return;

    setState(() {
      habitos = nuevaLista;
    });
  }

  // Abre la pantalla para editar un hábito.
  Future<void> editarHabito(Habito habito) async {
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarHabitoScreen(
          nombre: habito.nombre,
          color: habito.color,
        ),
      ),
    );

    if (!mounted || resultado == null) return;

    final nuevoNombre = resultado['nombre'] as String;
    final nuevoColor = resultado['color'] as int;

    if (nuevoNombre.trim().isEmpty) return;

    setState(() {
      habito.nombre = nuevoNombre.trim();
      habito.color = nuevoColor;
    });

    await PreferenciasService.guardarHabitos(
      widget.usuario.id,
      habitos,
    );
  }

  // Elimina un hábito después de pedir confirmación.
  Future<void> eliminarHabito(Habito habito) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar hábito'),
          content: Text(
            '¿Quieres eliminar "${habito.nombre}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) return;

    final nuevaLista = List<Habito>.from(habitos);

    nuevaLista.removeWhere(
          (elemento) => elemento.id == habito.id,
    );

    await PreferenciasService.guardarHabitos(
      widget.usuario.id,
      nuevaLista,
    );

    if (!mounted) return;

    setState(() {
      habitos = nuevaLista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis hábitos'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: cerrarSesion,
          ),
        ],
      ),

      body: cargando
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          // Información del usuario.
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '¡Hola, $nombreActual!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),

                const SizedBox(height: 8),

                Text(
                  'Objetivo diario: $objetivoActual hábitos',
                ),

                const SizedBox(height: 8),

                Text(
                  'Progreso de hoy: '
                      '${obtenerCompletadosHoy()} / '
                      '$objetivoActual',
                ),
              ],
            ),
          ),

          // Lista de hábitos.
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable:
              PreferenciasService.ocultarCompletados,

              builder: (context, ocultar, child) {
                final List<Habito> habitosVisibles = [];

                for (final habito in habitos) {
                  if (!ocultar ||
                      !estaCompletadoHoy(habito)) {
                    habitosVisibles.add(habito);
                  }
                }

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
                        cambiarCompletado(
                          habito,
                          completado,
                        );
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

      // Botones de navegación.
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Estadísticas.
          FloatingActionButton(
            heroTag: 'estadisticas',
            tooltip: 'Estadísticas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EstadisticasScreen(
                    usuario: widget.usuario,
                  ),
                ),
              );
            },
            child: const Icon(Icons.bar_chart),
          ),

          const SizedBox(height: 12),

          // Ajustes.
          FloatingActionButton(
            heroTag: 'ajustes',
            tooltip: 'Ajustes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AjustesScreen(
                    usuario: widget.usuario,
                  ),
                ),
              );
            },
            child: const Icon(Icons.settings),
          ),

          const SizedBox(height: 12),

          // Añadir hábito.
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
