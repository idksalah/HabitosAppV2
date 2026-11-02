
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/usuario.dart';
import '../servicios/preferencias_service.dart';
import 'login_page.dart';

class AjustesScreen extends StatefulWidget {
  final Usuario usuario;

  const AjustesScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<AjustesScreen> createState() {
    return _AjustesScreenState();
  }
}

class _AjustesScreenState extends State<AjustesScreen> {
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarAjustes();
  }

  // Recupera los ajustes del usuario.
  Future<void> cargarAjustes() async {
    final preferencias = await SharedPreferences.getInstance();
    final id = widget.usuario.id;

    final oscuro =
        preferencias.getBool('temaOscuro_$id') ?? false;

    final tamano =
        preferencias.getDouble('tamanoLetra_$id') ?? 1.0;

    final ocultar =
        preferencias.getBool('ocultarCompletados_$id') ?? false;

    PreferenciasService.temaActual.value =
    oscuro ? ThemeMode.dark : ThemeMode.light;

    PreferenciasService.tamanoLetra.value = tamano;
    PreferenciasService.ocultarCompletados.value = ocultar;

    if (!mounted) return;

    setState(() {
      cargando = false;
    });
  }

  // Guarda el tema seleccionado.
  Future<void> guardarTema(bool oscuro) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setBool(
      'temaOscuro_${widget.usuario.id}',
      oscuro,
    );

    await PreferenciasService.guardarTema(oscuro);
  }

  // Guarda el tamaño de letra.
  Future<void> guardarTamanoLetra(double tamano) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setDouble(
      'tamanoLetra_${widget.usuario.id}',
      tamano,
    );

    await PreferenciasService.guardarTamanoLetra(tamano);
  }

  // Guarda si queremos ocultar hábitos completados.
  Future<void> guardarOcultarCompletados(bool ocultar) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setBool(
      'ocultarCompletados_${widget.usuario.id}',
      ocultar,
    );

    await PreferenciasService.guardarOcultarCompletados(ocultar);
  }

  // Borra los hábitos y ajustes del usuario.
  Future<void> borrarDatosUsuario() async {
    final id = widget.usuario.id;

    await PreferenciasService.eliminarDatosUsuario(id);

    // Restablecemos los ajustes.
    PreferenciasService.temaActual.value = ThemeMode.light;
    PreferenciasService.tamanoLetra.value = 1.0;
    PreferenciasService.ocultarCompletados.value = false;
  }

  // Pide confirmación antes de borrar los datos.
  Future<void> confirmarBorrado() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Borrar datos'),
          content: const Text(
            'Se borrarán tus hábitos y tus ajustes personales. '
                'Tu cuenta y los datos de otros usuarios se conservarán. '
                '¿Quieres continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmar != true) return;

    // Borramos los datos confirmados.
    await borrarDatosUsuario();

    if (!mounted) return;

    // Volvemos al inicio de sesión.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),

      body: cargando
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cambiar entre tema claro y oscuro.
          ValueListenableBuilder<ThemeMode>(
            valueListenable: PreferenciasService.temaActual,
            builder: (context, tema, child) {
              return SwitchListTile(
                title: const Text('Tema oscuro'),
                value: tema == ThemeMode.dark,
                onChanged: guardarTema,
              );
            },
          ),

          const SizedBox(height: 16),

          // Cambiar el tamaño de letra.
          ValueListenableBuilder<double>(
            valueListenable: PreferenciasService.tamanoLetra,
            builder: (context, tamano, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tamaño de letra: ${tamano.toStringAsFixed(1)}',
                  ),

                  Slider(
                    value: tamano,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: tamano.toStringAsFixed(1),
                    onChanged: guardarTamanoLetra,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Mostrar u ocultar hábitos completados.
          ValueListenableBuilder<bool>(
            valueListenable:
            PreferenciasService.ocultarCompletados,
            builder: (context, ocultar, child) {
              return SwitchListTile(
                title: const Text(
                  'Ocultar hábitos completados',
                ),
                value: ocultar,
                onChanged: guardarOcultarCompletados,
              );
            },
          ),

          const SizedBox(height: 24),

          // Borrar los datos del usuario.
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline),
            label: const Text('Borrar mis datos'),
            onPressed: confirmarBorrado,
          ),
        ],
      ),
    );
  }
}
