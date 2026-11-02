import 'package:flutter/material.dart';

import '../modelos/habito.dart';
import '../modelos/usuario.dart';
import '../servicios/preferencias_service.dart';
import '../servicios/usuarios_service.dart';
import '../widgets/boton_principal.dart';
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

  Future<void> comprobarPermisos() async {
    final permiso = await UsuariosService.esAdministrador(widget.usuario.id);
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

  // Consulta los hábitos de todos los usuarios.
  Future<void> cargarDatos() async {
    final listaUsuarios = await UsuariosService.obtenerUsuarios();
    final List<Habito> listaHabitos = [];
    final Map<String, String> listaPropietarios = {};

    for (final usuario in listaUsuarios) {
      final lista = await PreferenciasService.obtenerHabitos(usuario.id);
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

  String nombrePropietario(String habitoId) {
    final usuarioId = propietarios[habitoId];
    for (final usuario in usuarios) {
      if (usuario.id == usuarioId) {
        return usuario.usuario;
      }
    }
    return 'Usuario desconocido';
  }

  Future<String?> seleccionarUsuario() async {
    return await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Selecciona un usuario'),
          children: [
            for (final usuario in usuarios)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, usuario.id),
                child: Text(usuario.usuario),
              ),
          ],
        );
      },
    );
  }

  Future<void> crearHabito() async {
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

    final nuevosHabitos = await PreferenciasService.obtenerHabitos(usuarioId);
    nuevosHabitos.add(
      Habito(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        nombre: nombre,
        color: resultado['color'] as int,
      ),
    );

    await PreferenciasService.guardarHabitos(usuarioId, nuevosHabitos);
    if (mounted) await cargarDatos();
  }

  Future<void> editarHabito(Habito habito) async {
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

    final lista = await PreferenciasService.obtenerHabitos(usuarioId);

    for (final elemento in lista) {
      if (elemento.id == habito.id) {
        elemento.nombre = (resultado['nombre'] as String).trim();
        elemento.color = resultado['color'] as int;
        break;
      }
    }

    await PreferenciasService.guardarHabitos(usuarioId, lista);
    if (mounted) await cargarDatos();
  }

  Future<void> eliminarHabito(Habito habito) async {
    final usuarioId = propietarios[habito.id];
    if (usuarioId == null) return;

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

    final lista = await PreferenciasService.obtenerHabitos(usuarioId);
    lista.removeWhere((elemento) => elemento.id == habito.id);

    await PreferenciasService.guardarHabitos(usuarioId, lista);
    if (mounted) await cargarDatos();
  }

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
              ? const Center(child: Text('No hay hábitos'))
              : ListView.builder(
                  itemCount: habitos.length,
                  itemBuilder: (context, index) {
                    final habito = habitos[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(habito.color),
                          child: const Icon(Icons.water_drop, color: Colors.white),
                        ),
                        title: Text(habito.nombre),
                        subtitle: Text('Usuario: ${nombrePropietario(habito.id)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar hábito',
                              icon: const Icon(Icons.edit),
                              onPressed: () => editarHabito(habito),
                            ),
                            IconButton(
                              tooltip: 'Eliminar hábito',
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarHabito(habito),
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!esAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso denegado')),
        body: const Center(child: Text('No tienes permisos para acceder')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar hábitos')),
      body: construirHabitos(),
    );
  }
}
