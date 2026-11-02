
import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'services/preferencias_service.dart';
import 'services/usuarios_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargamos los ajustes guardados.
  await PreferenciasService.cargarAjustes();

  // Creamos el administrador inicial.
  await UsuariosService.crearAdministradorInicial();

  // Registramos una apertura de la aplicación.
  await PreferenciasService.registrarApertura();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: PreferenciasService.temaActual,
      builder: (context, tema, child) {
        return ValueListenableBuilder<double>(
          valueListenable: PreferenciasService.tamanoLetra,
          builder: (context, tamano, child) {
            return MaterialApp(
              title: 'HabitosApp',
              debugShowCheckedModeBanner: false,

              // Tema claro.
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.green,
                ),
                useMaterial3: true,
              ),

              // Tema oscuro.
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.green,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),

              themeMode: tema,

              // Tamaño de letra.
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);

                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(tamano),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },

              // Pantalla inicial.
              home: const LoginPage(),
            );
          },
        );
      },
    );
  }
}
