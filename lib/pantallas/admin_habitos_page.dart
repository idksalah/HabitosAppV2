
import 'package:flutter/material.dart';

import '../modelos/habito.dart';
import '../modelos/usuario.dart';
import '../servicios/preferencias_service.dart';
import '../servicios/usuarios_service.dart';
import '../widgets/boton_principal.dart';
import '../widgets/tarjeta_habito.dart';

import 'editar_habito_screen.dart';

class AdminHabitosPage extends StatefulWidget {
  final Usuario usuario;

  const AdminHabitosPage({
    super.key,
    required this.usuario,
  });

  @override
  State<AdminHabitosPage> createState() {
    return _AdminHabitosPageState();
  }
}

class _AdminHabitosPageState extends State<AdminHabitosPage> {
  List<Usuario> usuarios = [];
  List<Habito> habitos = [];
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

  // Muestra mensajes en pantalla.
  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  // Consulta los hábitos de todos los usuarios.
  Future<void> cargarDatos() async {
    final listaUsuarios = await UsuariosService.obtenerUsuarios();

    final List<Habito> listaHabitos = [];
    final Map<String, String> listaPropietarios = {};

    for (final usuario in listaUsuarios) {
      final lista = await PreferenciasService.obtenerHabitos(
        usuario.id,
      );

      for (final habito in lista) {
        listaHabitos.add(habito);
        listaPropietarios[habito.id] = usuario.id;
      }
    }

    if (!mounted) return;

    setState(() {
      usuarios = listaUsuarios;
      habitos = listaHabitos;
      propietarios = listaPropietarios;
      cargando = false;
    });
  }

  // Busca el nombre del propietario del hábito.
  String nombrePropietario(String habitoId) {
    final usuarioId = propietarios[habitoId];

    for (final usuario in usuarios) {
      if (usuario.id == usuarioId) {
        return usuario.usuario;
      }
    }

    return 'Usuario desconocido';
  }

  // Obtiene la fecha de hoy.
  String obtenerFechaHoy() {
    final hoy = DateTime.now();

    final mes = hoy.month.toString().padLeft(2, '0');
    final dia = hoy.day.toString().padLeft(2, '0');

    return '${hoy.year}-$mes-$dia';
  }

  // Comprueba si el hábito está completado hoy.
  bool estaCompletadoHoy(Habito habito) {
    return habito.fechasCompletado.contains(
      obtenerFechaHoy(),
    );
  }

  // Permite marcar o desmarcar un hábito.
  Future<void> cambiarCompletado(
      Habito habito,
      bool completado,
      ) async {
    if (!await tienePermisos()) return;

    final usuarioId = propietarios[habito.id];

    if (usuarioId == null) return;

    final lista = await PreferenciasService.obtenerHabitos(
      usuarioId,
    );

    final hoy = obtenerFechaHoy();

    for (final elemento in lista) {
      if (elemento.id == habito.id) {
        if (completado) {
          if (!elemento.fechasCompletado.contains(hoy)) {
            elemento.fechasCompletado.add(hoy);
          }
        } else {
          elemento.fechasCompletado.remove(hoy);
        }

        break;
      }
    }

    await PreferenciasService.guardarHabitos(
      usuarioId,
      lista,
    );

    if (!mounted) return;

    await cargarDatos();
  }

  // Permite seleccionar un usuario.
  Future<String?> seleccionarUsuario() async {
    return await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Selecciona un usuario'),

          children: [
            for (final usuario in usuarios)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    usuario.id,
                  );
                },
                child: Text(usuario.usuario),
              ),
          ],
        );
      },
    );
  }

  // Crea un hábito para el usuario seleccionado.
  Future<void> crearHabito() async {
    if (!await tienePermisos()) return;

    final usuarioId = await seleccionarUsuario();

    if (!mounted || usuarioId == null) return;

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

    final nombre = (resultado['nombre'] as String).trim();

    if (nombre.isEmpty) return;

    // Comprobamos otra vez los permisos antes de guardar.
    if (!await tienePermisos()) return;

    final nuevosHabitos =
    await PreferenciasService.obtenerHabitos(usuarioId);

    nuevosHabitos.add(
      Habito(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        nombre: nombre,
        color: resultado['color'] as int,
      ),
    );

    await PreferenciasService.guardarHabitos(
      usuarioId,
      nuevosHabitos,
    );

    if (!mounted) return;

    await cargarDatos();
  }

  // Modifica el nombre y el color de un hábito.
  Future<void> editarHabito(Habito habito) async {
    if (!await tienePermisos()) return;

    if (!mounted) return;

    final usuarioId = propietarios[habito.id];


    if (usuarioId == null) return;

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

    final nombre = (resultado['nombre'] as String).trim();

    if (nombre.isEmpty) return;

    if (!await tienePermisos()) return;

    final lista = await PreferenciasService.obtenerHabitos(
      usuarioId,
    );

    for (final elemento in lista) {
      if (elemento.id == habito.id) {
        elemento.nombre = nombre;
        elemento.color = resultado['color'] as int;
        break;
      }
    }

    await PreferenciasService.guardarHabitos(
      usuarioId,
      lista,
    );

    if (!mounted) return;

    await cargarDatos();
  }

  // Elimina un hábito después de pedir confirmación.
  Future<void> eliminarHabito(Habito habito) async {
    final usuarioId = propietarios[habito.id];

    if (usuarioId == null) return;

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

    if (!await tienePermisos()) return;

    final lista = await PreferenciasService.obtenerHabitos(
      usuarioId,
    );

    lista.removeWhere((elemento) {
      return elemento.id == habito.id;
    });

    await PreferenciasService.guardarHabitos(
      usuarioId,
      lista,
    );

    if (!mounted) return;

    await cargarDatos();
  }

  // Construye la lista de hábitos.
  Widget construirHabitos() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: BotonPrincipal(
            texto: 'Añadir hábito',
            accion: crearHabito,
          ),
        ),

        Expanded(
          child: habitos.isEmpty
              ? const Center(
            child: Text('No hay hábitos'),
          )
              : ListView.builder(
            itemCount: habitos.length,

            itemBuilder: (context, index) {
              final habito = habitos[index];

              return Column(
                children: [
                  // Mostramos el usuario propietario.
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Usuario: ${nombrePropietario(habito.id)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Reutilizamos la tarjeta de hábitos.
                  TarjetaHabito(
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
                  ),
                ],
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
          child: Text('No tienes permisos para acceder'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar hábitos'),
      ),
      body: construirHabitos(),
    );
  }
}
