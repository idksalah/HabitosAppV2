
import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'services/preferencias_service.dart';
import 'services/usuarios_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UsuariosService.crearAdministradorInicial();

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
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.green,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.green,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              themeMode: tema,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);

                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(tamano),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: const LoginPage(),
            );
          },
        );
      },
    );
  }
}
