
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import '../services/usuarios_service.dart';
import '../services/preferencias_service.dart';
import 'registro_page.dart';
import 'inicio_screen.dart';
import 'administracion_page.dart';

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

  Future<void> cargarAjustesUsuario(String usuarioId) async {
    final preferencias = await SharedPreferences.getInstance();

    final oscuro =
        preferencias.getBool('temaOscuro_$usuarioId') ?? false;

    final tamano =
        preferencias.getDouble('tamanoLetra_$usuarioId') ?? 1.0;

    final ocultar =
        preferencias.getBool('ocultarCompletados_$usuarioId') ?? false;

    PreferenciasService.temaActual.value =
    oscuro ? ThemeMode.dark : ThemeMode.light;

    PreferenciasService.tamanoLetra.value = tamano;

    PreferenciasService.ocultarCompletados.value = ocultar;
  }

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

    if (!mounted) return;

    if (usuario == null) {
      setState(() {
        mensaje = 'Correo o contraseña incorrectos';
      });
      return;
    }

    await cargarAjustesUsuario(usuario.id);

    if (!mounted) return;

    if (usuario.rol == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdministracionPage(
            usuario: usuario,
          ),
        ),
      );
    } else {
      String? nombre =
      await PreferenciasService.obtenerNombre(usuario.id);

      int? objetivo =
      await PreferenciasService.obtenerObjetivo(usuario.id);

      nombre ??= usuario.nombre;
      objetivo ??= 3;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InicioScreen(
            usuario: usuario,
            nombre: nombre!,
            objetivo: objetivo!,
          ),
        ),
      );
    }
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
