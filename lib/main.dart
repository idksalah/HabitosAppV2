
import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'services/preferencias_service.dart';

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
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.green,
                ),
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

              // Aplicamos el tamaño de letra.
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);

                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(tamano),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },

              // Mostramos primero el inicio de sesión.
              home: const LoginPage(),
            );
          },
        );
      },
    );
  }
}
