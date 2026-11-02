
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';
import '../services/usuarios_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() {
    return RegistroPageState();
  }
}

class RegistroPageState extends State<RegistroPage> {
  final TextEditingController usuarioController =
  TextEditingController();

  final TextEditingController nombreController =
  TextEditingController();

  final TextEditingController apellidosController =
  TextEditingController();

  final TextEditingController correoController =
  TextEditingController();

  final TextEditingController contrasenaController =
  TextEditingController();

  String mensaje = '';

  // Comprueba los datos y registra un usuario.
  Future<void> registrar() async {
    final usuarioTexto = usuarioController.text.trim();
    final nombre = nombreController.text.trim();
    final apellidos = apellidosController.text.trim();
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text;

    if (usuarioTexto.isEmpty ||
        nombre.isEmpty ||
        apellidos.isEmpty ||
        correo.isEmpty ||
        contrasena.isEmpty) {
      setState(() {
        mensaje = 'Completa todos los campos';
      });
      return;
    }

    // Comprobamos que el usuario no exista.
    final usuarios = await UsuariosService.obtenerUsuarios();

    if (!mounted) return;

    for (final elemento in usuarios) {
      if (elemento.usuario.toLowerCase() ==
          usuarioTexto.toLowerCase()) {
        setState(() {
          mensaje = 'Este nombre de usuario ya existe';
        });
        return;
      }
    }

    // Creamos el usuario con sus datos.
    final nuevoUsuario = Usuario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      usuario: usuarioTexto,
      nombre: nombre,
      apellidos: apellidos,
      correo: correo,
      contrasena: contrasena,
      rol: 'usuario',
      fechaCreacion: DateTime.now(),
    );

    // Guardamos el usuario.
    final registrado =
    await UsuariosService.registrarUsuario(nuevoUsuario);

    if (!mounted) return;

    if (registrado) {
      final preferencias =
      await SharedPreferences.getInstance();

      // Ajustes iniciales del usuario.
      await preferencias.setBool(
        'temaOscuro_${nuevoUsuario.id}',
        false,
      );

      await preferencias.setDouble(
        'tamanoLetra_${nuevoUsuario.id}',
        1.0,
      );

      await preferencias.setBool(
        'ocultarCompletados_${nuevoUsuario.id}',
        false,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario registrado correctamente'),
        ),
      );

      Navigator.pop(context);
    } else {
      setState(() {
        mensaje = 'Este correo ya está registrado';
      });
    }
  }

  @override
  void dispose() {
    usuarioController.dispose();
    nombreController.dispose();
    apellidosController.dispose();
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CampoTextoApp(
              texto: 'Usuario',
              pista: 'Introduce tu nombre de usuario',
              controlador: usuarioController,
            ),

            const SizedBox(height: 20),

            CampoTextoApp(
              texto: 'Nombre',
              pista: 'Introduce tu nombre',
              controlador: nombreController,
            ),

            const SizedBox(height: 20),

            CampoTextoApp(
              texto: 'Apellidos',
              pista: 'Introduce tus apellidos',
              controlador: apellidosController,
            ),

            const SizedBox(height: 20),

            CampoTextoApp(
              texto: 'Correo electrónico',
              pista: 'Introduce tu correo',
              controlador: correoController,
            ),

            const SizedBox(height: 20),

            CampoTextoApp(
              texto: 'Contraseña',
              pista: 'Crea una contraseña',
              controlador: contrasenaController,
              ocultarTexto: true,
            ),

            const SizedBox(height: 20),

            BotonPrincipal(
              texto: 'Registrarse',
              accion: registrar,
            ),

            const SizedBox(height: 10),

            Text(
              mensaje,
              style: const TextStyle(color: Colors.red),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Volver al inicio de sesión',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
