
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuarios_service.dart';
import '../services/preferencias_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

import 'login_page.dart';
import 'registro_page.dart';

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
      await cargarUsuarios();
    } else {
      setState(() {
        cargando = false;
      });
    }
  }

  // Recupera todos los usuarios.
  Future<void> cargarUsuarios() async {
    final lista = await UsuariosService.obtenerUsuarios();

    if (!mounted) return;

    setState(() {
      usuarios = lista;
      cargando = false;
    });
  }

  // Abre el registro para crear un usuario.
  Future<void> crearUsuario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistroPage(),
      ),
    );

    if (!mounted) return;

    await cargarUsuarios();
  }

  // Permite editar los datos de un usuario.
  Future<void> editarUsuario(Usuario usuario) async {
    final usuarioController = TextEditingController(
      text: usuario.usuario,
    );

    final nombreController = TextEditingController(
      text: usuario.nombre,
    );

    final apellidosController = TextEditingController(
      text: usuario.apellidos,
    );

    final correoController = TextEditingController(
      text: usuario.correo,
    );

    String rolSeleccionado = usuario.rol;
    String mensaje = '';

    final guardar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, actualizarDialogo) {
            return AlertDialog(
              title: const Text('Editar usuario'),

              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CampoTextoApp(
                        texto: 'Usuario',
                        pista: 'Nombre de usuario',
                        controlador: usuarioController,
                      ),

                      const SizedBox(height: 12),

                      CampoTextoApp(
                        texto: 'Nombre',
                        pista: 'Nombre',
                        controlador: nombreController,
                      ),

                      const SizedBox(height: 12),

                      CampoTextoApp(
                        texto: 'Apellidos',
                        pista: 'Apellidos',
                        controlador: apellidosController,
                      ),

                      const SizedBox(height: 12),

                      CampoTextoApp(
                        texto: 'Correo',
                        pista: 'Correo electrónico',
                        controlador: correoController,
                      ),

                      const SizedBox(height: 12),

                      // El administrador puede cambiar el rol.
                      DropdownButtonFormField<String>(
                        initialValue: rolSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'usuario',
                            child: Text('Usuario'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Administrador'),
                          ),
                        ],
                        onChanged: usuario.id == widget.usuario.id
                            ? null
                            : (valor) {
                          if (valor != null) {
                            actualizarDialogo(() {
                              rolSeleccionado = valor;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      Text(
                        mensaje,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
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
                    if (usuarioController.text.trim().isEmpty ||
                        nombreController.text.trim().isEmpty ||
                        apellidosController.text.trim().isEmpty ||
                        correoController.text.trim().isEmpty) {
                      actualizarDialogo(() {
                        mensaje = 'Completa todos los campos';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (guardar == true) {
      // Comprobamos que no haya nombres o correos repetidos.
      bool repetido = false;

      for (final elemento in usuarios) {
        if (elemento.id != usuario.id) {
          if (elemento.usuario.toLowerCase() ==
              usuarioController.text.trim().toLowerCase() ||
              elemento.correo.toLowerCase() ==
                  correoController.text.trim().toLowerCase()) {
            repetido = true;
          }
        }
      }

      if (!mounted) return;

      if (repetido) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El usuario o el correo ya existe',
            ),
          ),
        );
      } else {
        usuario.usuario = usuarioController.text.trim();
        usuario.nombre = nombreController.text.trim();
        usuario.apellidos = apellidosController.text.trim();
        usuario.correo = correoController.text.trim();
        usuario.rol = rolSeleccionado;

        await UsuariosService.guardarUsuarios(usuarios);

        if (!mounted) return;

        setState(() {});
      }
    }

    usuarioController.dispose();
    nombreController.dispose();
    apellidosController.dispose();
    correoController.dispose();
  }

  // Pide confirmación antes de eliminar un usuario.
  Future<void> eliminarUsuario(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar usuario'),
          content: Text(
            '¿Quieres eliminar a ${usuario.nombre}?',
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
    final permiso = await UsuariosService.esAdministrador(
      widget.usuario.id,
    );

    if (!permiso) return;

    final eliminado = await UsuariosService.eliminarUsuario(
      usuario.id,
    );

    if (!eliminado) return;

    await PreferenciasService.eliminarDatosUsuario(
      usuario.id,
    );

    if (!mounted) return;

    await cargarUsuarios();
  }

  // Cierra la sesión del administrador.
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

      body: Column(
        children: [
          // Botón para añadir usuarios.
          Padding(
            padding: const EdgeInsets.all(16),
            child: BotonPrincipal(
              texto: 'Añadir usuario',
              accion: crearUsuario,
            ),
          ),

          // Lista de usuarios.
          Expanded(
            child: usuarios.isEmpty
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

                    title: Text(
                      '${usuario.nombre} ${usuario.apellidos}',
                    ),

                    subtitle: Text(
                      'Usuario: ${usuario.usuario}\n'
                          'Correo: ${usuario.correo}\n'
                          'Rol: ${usuario.rol}',
                    ),

                    isThreeLine: true,

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar usuario',
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            editarUsuario(usuario);
                          },
                        ),

                        if (usuario.rol != 'admin')
                          IconButton(
                            tooltip: 'Eliminar usuario',
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              eliminarUsuario(usuario);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
