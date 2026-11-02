import 'package:flutter/material.dart';

import '../modelos/usuario.dart';
import '../servicios/usuarios_service.dart';
import '../servicios/preferencias_service.dart';
import '../widgets/boton_principal.dart';
import '../widgets/campo_texto_app.dart';
import 'admin_habitos_page.dart';
import 'admin_estadisticas_page.dart';
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

  // Comprueba si el usuario tiene permiso de administrador.
  Future<void> comprobarPermisos() async {
    final permiso = await UsuariosService.esAdministrador(widget.usuario.id);

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

  // Recupera los usuarios de la base de datos.
  Future<void> cargarUsuarios() async {
    final lista = await UsuariosService.obtenerUsuarios();

    if (!mounted) return;

    setState(() {
      usuarios = lista;
      cargando = false;
    });
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> crearUsuario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistroPage()),
    );

    if (!mounted) return;
    await cargarUsuarios();
  }

  Future<void> editarUsuario(Usuario usuario) async {
    final usuarioController = TextEditingController(text: usuario.usuario);
    final nombreController = TextEditingController(text: usuario.nombre);
    final apellidosController = TextEditingController(text: usuario.apellidos);
    final correoController = TextEditingController(text: usuario.correo);
    final contrasenaController = TextEditingController();

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
                      CampoTextoApp(
                        texto: 'Nueva contraseña (opcional)',
                        pista: 'Déjala vacía para conservar la actual',
                        controlador: contrasenaController,
                        ocultarTexto: true,
                      ),
                      const SizedBox(height: 12),
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
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
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

    if (guardar == true && mounted) {
      bool repetido = false;

      for (final elemento in usuarios) {
        if (elemento.id != usuario.id &&
            (elemento.usuario.toLowerCase() ==
                    usuarioController.text.trim().toLowerCase() ||
                elemento.correo.toLowerCase() ==
                    correoController.text.trim().toLowerCase())) {
          repetido = true;
        }
      }

      if (repetido) {
        mostrarMensaje('El usuario o el correo ya existe');
      } else {
        usuario.usuario = usuarioController.text.trim();
        usuario.nombre = nombreController.text.trim();
        usuario.apellidos = apellidosController.text.trim();
        usuario.correo = correoController.text.trim();
        usuario.rol = rolSeleccionado;
        if (contrasenaController.text.isNotEmpty) {
          usuario.contrasena = contrasenaController.text;
        }

        await UsuariosService.guardarUsuarios(usuarios);
        if (mounted) await cargarUsuarios();
      }
    }

    usuarioController.dispose();
    nombreController.dispose();
    apellidosController.dispose();
    correoController.dispose();
    contrasenaController.dispose();
  }

  Future<void> eliminarUsuario(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar usuario'),
          content: Text('¿Quieres eliminar a ${usuario.nombre}?'),
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

    final permiso = await UsuariosService.esAdministrador(widget.usuario.id);
    if (!permiso) return;

    final eliminado = await UsuariosService.eliminarUsuario(usuario.id);
    if (!eliminado) return;

    await PreferenciasService.eliminarDatosUsuario(usuario.id);
    if (mounted) await cargarUsuarios();
  }

  // Abre la gestión de hábitos de todos los usuarios.
  void abrirHabitos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminHabitosPage(usuario: widget.usuario),
      ),
    );
  }

  // Abre la gestión de estadísticas.
  void abrirEstadisticas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEstadisticasPage(usuario: widget.usuario),
      ),
    );
  }

  void cerrarSesion() {
    PreferenciasService.temaActual.value = ThemeMode.light;
    PreferenciasService.tamanoLetra.value = 1.0;
    PreferenciasService.ocultarCompletados.value = false;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Widget construirUsuarios() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: BotonPrincipal(
            texto: 'Añadir usuario',
            accion: crearUsuario,
          ),
        ),
        Expanded(
          child: usuarios.isEmpty
              ? const Center(child: Text('No hay usuarios'))
              : ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = usuarios[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text('${usuario.nombre} ${usuario.apellidos}'),
                        subtitle: Text(
                          'Usuario: ${usuario.usuario}\n'
                          'Correo: ${usuario.correo}\n'
                          'Rol: ${usuario.rol}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar usuario',
                              icon: const Icon(Icons.edit),
                              onPressed: () => editarUsuario(usuario),
                            ),
                            if (usuario.rol != 'admin')
                              IconButton(
                                tooltip: 'Eliminar usuario',
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => eliminarUsuario(usuario),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                BotonPrincipal(
                  texto: 'Gestionar hábitos',
                  accion: abrirHabitos,
                ),
                const SizedBox(height: 8),
                BotonPrincipal(
                  texto: 'Gestionar estadísticas',
                  accion: abrirEstadisticas,
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(child: construirUsuarios()),
        ],
      ),
    );
  }
}
