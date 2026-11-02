
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
  final TextEditingController usuarioController =
  TextEditingController();

  final TextEditingController contrasenaController =
  TextEditingController();

  String mensaje = '';

  // Carga los ajustes del usuario.
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

  // Comprueba el usuario y la contraseña.
  Future<void> acceder() async {
    final nombreUsuario = usuarioController.text.trim();
    final contrasena = contrasenaController.text;

    if (nombreUsuario.isEmpty || contrasena.isEmpty) {
      setState(() {
        mensaje = 'Completa todos los campos';
      });
      return;
    }

    final usuario = await UsuariosService.iniciarSesion(
      nombreUsuario,
      contrasena,
    );

    if (!mounted) return;

    if (usuario == null) {
      setState(() {
        mensaje = 'Usuario o contraseña incorrectos';
      });
      return;
    }

    // Cargamos los ajustes del usuario.
    await cargarAjustesUsuario(usuario.id);

    if (!mounted) return;

    // Si es administrador, abrimos administración.
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
      // Recuperamos los datos del usuario.
      final nombreGuardado =
      await PreferenciasService.obtenerNombre(usuario.id);

      final objetivoGuardado =
      await PreferenciasService.obtenerObjetivo(usuario.id);

      if (!mounted) return;

      final nombre = nombreGuardado ?? usuario.nombre;
      final objetivo = objetivoGuardado ?? 3;

      // Abrimos la pantalla de hábitos.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InicioScreen(
            usuario: usuario,
            nombre: nombre,
            objetivo: objetivo,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    usuarioController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            CampoTextoApp(
              texto: 'Usuario',
              pista: 'Introduce tu usuario',
              controlador: usuarioController,
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

            Text(
              mensaje,
              style: const TextStyle(color: Colors.red),
            ),

            const SizedBox(height: 10),

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
