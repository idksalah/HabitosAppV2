import 'package:flutter/material.dart';

import '../services/preferencias_service.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Permite elegir el tema claro u oscuro.
          ValueListenableBuilder<ThemeMode>(
            valueListenable: PreferenciasService.temaActual,
            builder: (context, tema, child) {
              return SwitchListTile(
                title: const Text('Tema oscuro'),
                value: tema == ThemeMode.dark,
                onChanged: (oscuro) {
                  PreferenciasService.guardarTema(oscuro);
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Permite cambiar el tamaño de la letra.
          ValueListenableBuilder<double>(
            valueListenable: PreferenciasService.tamanoLetra,
            builder: (context, tamano, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tamaño de letra: ${tamano.toStringAsFixed(1)}'),
                  Slider(
                    value: tamano,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: tamano.toStringAsFixed(1),
                    onChanged: (valor) {
                      PreferenciasService.guardarTamanoLetra(valor);
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Permite ocultar los hábitos completados.
          ValueListenableBuilder<bool>(
            valueListenable: PreferenciasService.ocultarCompletados,
            builder: (context, ocultar, child) {
              return SwitchListTile(
                title: const Text('Ocultar hábitos completados'),
                value: ocultar,
                onChanged: (valor) {
                  PreferenciasService.guardarOcultarCompletados(valor);
                },
              );
            },
          ),

          const SizedBox(height: 24),

          // Borra los datos y vuelve a la bienvenida.
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Borrar todos los datos'),
            onPressed: () async {
              final confirmar = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Borrar datos'),
                    content: const Text(
                      'Se borrarán tus datos y tendrás que '
                      'configurar la aplicación de nuevo. ¿Continuar?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text('Borrar'),
                      ),
                    ],
                  );
                },
              );

              if (confirmar != true || !context.mounted) return;

              await PreferenciasService.borrarDatos();

              if (!context.mounted) return;

              // Cerramos las pantallas anteriores y volvemos
              // a la bienvenida.
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
