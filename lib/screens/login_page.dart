
import 'package:flutter/material.dart';

import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import '../services/usuarios_service.dart';
import 'registro_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController correoController =
  TextEditingController();

  final TextEditingController contrasenaController =
  TextEditingController();

  String mensaje = '';

  Future<void> acceder() async {
    if (correoController.text.isEmpty ||
        contrasenaController.text.isEmpty) {
      setState(() {
        mensaje = 'Completa todos los campos';
      });
      return;
    }

    final usuario = await UsuariosService.iniciarSesion(
      correoController.text,
      contrasenaController.text,
    );

    if (usuario == null) {
      setState(() {
        mensaje = 'Correo o contraseña incorrectos';
      });
      return;
    }

    setState(() {
      mensaje = 'Bienvenido ${usuario.nombre}';
    });
  }

  @override
  void dispose() {
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CampoTextoApp(
              texto: 'Correo electrónico',
              pista: 'Introduce tu correo',
              controlador: correoController,
            ),
            const SizedBox(height: 20),
            CampoTextoApp(
              texto: 'Contraseña',
              pista: 'Introduce tu contraseña',
              controlador: contrasenaController,
              ocultarTexto: true,
            ),
            const SizedBox(height: 20),
            BotonPrincipal(
              texto: 'Acceder',
              accion: acceder,
            ),
            const SizedBox(height: 10),
            Text(mensaje),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistroPage(),
                  ),
                );
              },
              child: const Text('Crear una cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
