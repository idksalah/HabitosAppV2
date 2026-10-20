import 'package:flutter/material.dart';
import 'package:habitos_app/screens/bienvenida_screen.dart';
import 'package:habitos_app/screens/inicio_screen.dart';
import 'package:habitos_app/services/preferencias_service.dart';

Future<void> main() async {
  // Preparamos Flutter antes de cargar las preferencias.
  WidgetsFlutterBinding.ensureInitialized();

  // Recuperamos los ajustes guardados.
  await PreferenciasService.cargarAjustes();

  // Registramos que la aplicación se ha abierto.
  await PreferenciasService.registrarApertura();

  // Iniciamos la aplicación.
  runApp(const MyApp());
}

// Clase principal de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios del tema seleccionado.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: PreferenciasService.temaActual,
      builder: (context, tema, child) {
        // Escuchamos los cambios del tamaño de letra.
        return ValueListenableBuilder<double>(
          valueListenable: PreferenciasService.tamanoLetra,
          builder: (context, tamano, child) {
            return MaterialApp(
              title: 'HabitosApp',
              debugShowCheckedModeBanner: false,

              // Configuración del tema claro.
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
                useMaterial3: true,
              ),

              // Configuración del tema oscuro.
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.green,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),

              // Aplicamos el tema elegido en Ajustes.
              themeMode: tema,

              // Aplicamos el tamaño de letra en toda la aplicación.
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);

                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(tamano),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },

              // Definimos la ruta inicial.
              routes: {'/': (context) => const PantallaInicial()},
              initialRoute: '/',
            );
          },
        );
      },
    );
  }
}

// Comprueba si el usuario ya ha introducido sus datos.
class PantallaInicial extends StatefulWidget {
  const PantallaInicial({super.key});

  @override
  State<PantallaInicial> createState() {
    return _PantallaInicialState();
  }
}

class _PantallaInicialState extends State<PantallaInicial> {
  String? nombre;
  int? objetivo;
  bool cargando = true;

  @override
  void initState() {
    super.initState();

    // Cargamos los datos al iniciar esta pantalla.
    cargarDatos();
  }

  // Recupera el nombre y el objetivo guardados.
  Future<void> cargarDatos() async {
    final nombreGuardado = await PreferenciasService.obtenerNombre();

    final objetivoGuardado = await PreferenciasService.obtenerObjetivo();

    // Comprobamos que la pantalla siga activa.
    if (!mounted) return;

    setState(() {
      nombre = nombreGuardado;
      objetivo = objetivoGuardado;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mientras se recuperan los datos, mostramos un indicador.
    if (cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si los datos existen, abrimos la pantalla principal.
    if (nombre != null &&
        nombre!.isNotEmpty &&
        objetivo != null &&
        objetivo! > 0) {
      return InicioScreen(nombre: nombre!, objetivo: objetivo!);
    }

    // Si no hay datos guardados, mostramos la bienvenida.
    return const BienvenidaScreen();
  }
}
