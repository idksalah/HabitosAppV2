
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuarios_service.dart';
import '../services/preferencias_service.dart';
import 'login_page.dart';

class AdministracionPage extends StatefulWidget {
  final Usuario usuario;

  const AdministracionPage({
    super.key,
    required this.usuario,
  });

  @override
  State<AdministracionPage> createState() {
    return AdministracionPageState();
  }
}

class AdministracionPageState extends State<AdministracionPage> {
  List<Usuario> usuarios = [];
  bool cargando = true;
  bool esAdmin = false;

  @override
  void initState() {
    super.initState();
    comprobarPermisos();
  }

  Future<void> comprobarPermisos() async {
    final permiso = await UsuariosService.esAdministrador(
      widget.usuario.id,
    );

    if (!mounted) return;

    setState(() {
      esAdmin = permiso;
    });

    if (permiso) {
      await cargarUsuarios();
    } else {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> cargarUsuarios() async {
    final lista = await UsuariosService.obtenerUsuarios();

    if (!mounted) return;

    setState(() {
      usuarios = lista;
      cargando = false;
    });
  }

  Future<void> cerrarSesion() async {
    PreferenciasService.temaActual.value = ThemeMode.light;
    PreferenciasService.tamanoLetra.value = 1.0;
    PreferenciasService.ocultarCompletados.value = false;

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  Future<void> eliminarUsuario(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar usuario'),
          content: Text('¿Quieres eliminar a ${usuario.nombre}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) return;

    final permiso = await UsuariosService.esAdministrador(
      widget.usuario.id,
    );

    if (!permiso) return;

    final eliminado = await UsuariosService.eliminarUsuario(
      usuario.id,
    );

    if (!eliminado) return;

    await PreferenciasService.eliminarDatosUsuario(usuario.id);

    if (!mounted) return;

    setState(() {
      usuarios.removeWhere(
            (elemento) => elemento.id == usuario.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Administración'),
        ),
        body: const Center(
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
        title: const Text('Administración'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: cerrarSesion,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: usuarios.isEmpty
          ? const Center(
        child: Text('No hay usuarios registrados'),
      )
          : ListView.builder(
        itemCount: usuarios.length,
        itemBuilder: (context, index) {
          final usuario = usuarios[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(usuario.nombre),
              subtitle: Text(
                '${usuario.correo}\nRol: ${usuario.rol}',
              ),
              isThreeLine: true,
              trailing: usuario.id == widget.usuario.id
                  ? null
                  : IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  eliminarUsuario(usuario);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
