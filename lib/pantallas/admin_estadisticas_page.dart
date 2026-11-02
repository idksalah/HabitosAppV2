
import 'package:flutter/material.dart';

import '../modelos/habito.dart';
import '../modelos/usuario.dart';
import '../servicios/preferencias_service.dart';
import '../servicios/usuarios_service.dart';
import '../servicios/estadisticas_service.dart';
import '../widgets/boton_principal.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/dato_estadistica.dart';

class AdminEstadisticasPage extends StatefulWidget {
  final Usuario usuario;

  const AdminEstadisticasPage({
    super.key,
    required this.usuario,
  });

  @override
  State<AdminEstadisticasPage> createState() {
    return _AdminEstadisticasPageState();
  }
}

class _AdminEstadisticasPageState extends State<AdminEstadisticasPage> {
  List<Usuario> usuarios = [];
  List<Habito> habitos = [];
  List<Map<String, Object?>> estadisticas = [];

  Map<String, String> propietarios = {};

  bool cargando = true;
  bool esAdmin = false;

  @override
  void initState() {
    super.initState();
    comprobarPermisos();
  }

  // Comprueba si el usuario es administrador.
  Future<void> comprobarPermisos() async {
    final permiso = await UsuariosService.esAdministrador(
      widget.usuario.id,
    );

    if (!mounted) return;

    setState(() {
      esAdmin = permiso;
    });

    if (permiso) {
      await cargarDatos();
    } else {
      setState(() {
        cargando = false;
      });
    }
  }

  // Comprueba los permisos antes de hacer cambios.
  Future<bool> tienePermisos() async {
    final permiso = await UsuariosService.esAdministrador(
      widget.usuario.id,
    );

    if (!mounted) return false;

    if (!permiso) {
      mostrarMensaje('No tienes permisos de administrador');
      return false;
    }

    return true;
  }

  // Consulta los usuarios, hábitos y estadísticas.
  Future<void> cargarDatos() async {
    final listaUsuarios = await UsuariosService.obtenerUsuarios();

    final List<Habito> listaHabitos = [];
    final Map<String, String> listaPropietarios = {};

    for (final usuario in listaUsuarios) {
      // Actualizamos las rachas si ha cambiado el día.
      await PreferenciasService.actualizarRachas(
        usuario.id,
      );

      final lista = await PreferenciasService.obtenerHabitos(
        usuario.id,
      );

      for (final habito in lista) {
        listaHabitos.add(habito);
        listaPropietarios[habito.id] = usuario.id;
      }
    }

    final listaEstadisticas =
    await EstadisticasService.obtenerTodas(
      widget.usuario.id,
    );

    if (!mounted) return;

    setState(() {
      usuarios = listaUsuarios;
      habitos = listaHabitos;
      propietarios = listaPropietarios;
      estadisticas = listaEstadisticas;
      cargando = false;
    });
  }

  // Busca el nombre de un hábito.
  String nombreHabito(String habitoId) {
    for (final habito in habitos) {
      if (habito.id == habitoId) {
        return habito.nombre;
      }
    }

    return 'Hábito desconocido';
  }

  // Busca el propietario de un hábito.
  String nombrePropietario(String habitoId) {
    final usuarioId = propietarios[habitoId];

    for (final usuario in usuarios) {
      if (usuario.id == usuarioId) {
        return usuario.usuario;
      }
    }

    return 'Usuario desconocido';
  }

  // Muestra un mensaje en pantalla.
  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  // Pide la racha y los días completados.
  Future<Map<String, int>?> pedirEstadisticas(
      int racha,
      int dias,
      ) async {
    final rachaController = TextEditingController(
      text: '$racha',
    );

    final diasController = TextEditingController(
      text: '$dias',
    );

    String mensaje = '';

    final resultado = await showDialog<Map<String, int>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, actualizarDialogo) {
            return AlertDialog(
              title: const Text('Datos estadísticos'),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CampoTextoApp(
                      texto: 'Racha actual',
                      pista: 'Número de días seguidos',
                      controlador: rachaController,
                    ),

                    const SizedBox(height: 12),

                    CampoTextoApp(
                      texto: 'Días completados',
                      pista: 'Número de días',
                      controlador: diasController,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      mensaje,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancelar'),
                ),

                ElevatedButton(
                  onPressed: () {
                    final nuevaRacha = int.tryParse(
                      rachaController.text.trim(),
                    );

                    final nuevosDias = int.tryParse(
                      diasController.text.trim(),
                    );

                    if (nuevaRacha == null ||
                        nuevosDias == null ||
                        nuevaRacha < 0 ||
                        nuevosDias < 0 ||
                        nuevaRacha > nuevosDias) {
                      actualizarDialogo(() {
                        mensaje = 'Introduce números válidos';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'racha': nuevaRacha,
                      'dias': nuevosDias,
                    });
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    rachaController.dispose();
    diasController.dispose();

    return resultado;
  }

  // Crea estadísticas para un hábito.
  Future<void> crearEstadistica() async {
    final List<Habito> disponibles = [];

    // Buscamos hábitos que todavía no tengan estadísticas.
    for (final habito in habitos) {
      bool existe = false;

      for (final dato in estadisticas) {
        if (dato['habitoId'] == habito.id) {
          existe = true;
        }
      }

      if (!existe) {
        disponibles.add(habito);
      }
    }

    if (disponibles.isEmpty) {
      mostrarMensaje(
        'Todos los hábitos ya tienen estadísticas',
      );
      return;
    }

    // Seleccionamos el hábito.
    final habitoId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Selecciona un hábito'),
          children: [
            for (final habito in disponibles)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    habito.id,
                  );
                },
                child: Text(
                  '${habito.nombre} '
                      '(${nombrePropietario(habito.id)})',
                ),
              ),
          ],
        );
      },
    );

    if (!mounted || habitoId == null) return;

    final datos = await pedirEstadisticas(0, 0);

    if (!mounted || datos == null) return;

    // Comprobamos los permisos antes de guardar.
    if (!await tienePermisos()) return;

    await EstadisticasService.crear(
      widget.usuario.id,
      habitoId,
      datos['racha']!,
      datos['dias']!,
    );

    if (!mounted) return;

    await cargarDatos();
  }

  // Modifica las estadísticas de un hábito.
  Future<void> editarEstadistica(
      Map<String, Object?> estadistica,
      ) async {
    final habitoId = estadistica['habitoId'] as String;
    final racha = estadistica['rachaActual'] as int;
    final dias = estadistica['diasCompletados'] as int;

    final datos = await pedirEstadisticas(
      racha,
      dias,
    );

    if (!mounted || datos == null) return;

    // Comprobamos los permisos antes de actualizar.
    if (!await tienePermisos()) return;

    await EstadisticasService.actualizar(
      widget.usuario.id,
      habitoId,
      datos['racha']!,
      datos['dias']!,
    );

    if (!mounted) return;

    await cargarDatos();
  }

  // Elimina las estadísticas de un hábito.
  Future<void> eliminarEstadistica(
      Map<String, Object?> estadistica,
      ) async {
    final habitoId = estadistica['habitoId'] as String;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar estadísticas'),

          content: Text(
            '¿Eliminar las estadísticas de '
                '${nombreHabito(habitoId)}?',
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

    // Comprobamos los permisos antes de eliminar.
    if (!await tienePermisos()) return;

    await EstadisticasService.eliminar(
        widget.usuario.id,
        habitoId);

    if (!mounted) return;

    await cargarDatos();
  }

  // Construye la lista de estadísticas.
  Widget construirEstadisticas() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: BotonPrincipal(
            texto: 'Añadir estadísticas',
            accion: crearEstadistica,
          ),
        ),

        Expanded(
          child: estadisticas.isEmpty
              ? const Center(
            child: Text('No hay estadísticas'),
          )
              : ListView.builder(
            itemCount: estadisticas.length,

            itemBuilder: (context, index) {
              final dato = estadisticas[index];
              final habitoId = dato['habitoId'] as String;

              return Card(
                margin: const EdgeInsets.all(8),

                child: Padding(
                  padding: const EdgeInsets.all(8),

                  child: Column(
                    children: [
                      // Nombre y propietario del hábito.
                      Text(
                        '${nombreHabito(habitoId)} '
                            '(${nombrePropietario(habitoId)})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Datos estadísticos reutilizables.
                      Row(
                        children: [
                          Expanded(
                            child: DatoEstadistica(
                              titulo: 'Racha actual',
                              valor: '${dato['rachaActual']}',
                              icono:
                              Icons.local_fire_department,
                              color: Colors.orange,
                            ),
                          ),

                          Expanded(
                            child: DatoEstadistica(
                              titulo: 'Días completados',
                              valor: '${dato['diasCompletados']}',
                              icono: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      // Botones de editar y eliminar.
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              editarEstadistica(dato);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar'),
                          ),

                          TextButton.icon(
                            onPressed: () {
                              eliminarEstadistica(dato);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!esAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Acceso denegado'),
        ),
        body: const Center(
          child: Text(
            'No tienes permisos para acceder',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar estadísticas'),
      ),
      body: construirEstadisticas(),
    );
  }
}
