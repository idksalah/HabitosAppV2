
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuarios_service.dart';

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

  @override
  void initState() {
    super.initState();

    if (widget.usuario.rol == 'admin') {
      cargarUsuarios();
    } else {
      cargando = false;
    }
  }

  // Recuperamos los usuarios registrados.
  Future<void> cargarUsuarios() async {
    final lista = await UsuariosService.obtenerUsuarios();

    if (!mounted) return;

    setState(() {
      usuarios = lista;
      cargando = false;
    });
  }

  // Eliminamos un usuario.
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

    if (confirmar != true) return;

    await UsuariosService.eliminarUsuario(usuario.id);

    if (!mounted) return;

    setState(() {
      usuarios.removeWhere(
            (elemento) => elemento.id == usuario.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Comprobamos que el usuario sea administrador.
    if (widget.usuario.rol != 'admin') {
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
      ),
      body: cargando
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : usuarios.isEmpty
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
