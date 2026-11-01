
import 'package:flutter/material.dart';

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
  final TextEditingController nombreController =
  TextEditingController();

  final TextEditingController correoController =
  TextEditingController();

  final TextEditingController contrasenaController =
  TextEditingController();

  String mensaje = '';

  Future<void> registrar() async {
    if (nombreController.text.isEmpty ||
        correoController.text.isEmpty ||
        contrasenaController.text.isEmpty) {
      setState(() {
        mensaje = 'Completa todos los campos';
      });
      return;
    }

    final usuario = Usuario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombreController.text.trim(),
      correo: correoController.text.trim(),
      contrasena: contrasenaController.text,
      rol: 'usuario',
      fechaCreacion: DateTime.now(),
    );

    final registrado =
    await UsuariosService.registrarUsuario(usuario);

    if (!mounted) return;

    if (registrado) {
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
    nombreController.dispose();
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CampoTextoApp(
              texto: 'Nombre',
              pista: 'Introduce tu nombre',
              controlador: nombreController,
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
            Text(mensaje),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Volver al inicio de sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
