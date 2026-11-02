
import 'package:flutter/material.dart';

import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

class EditarHabitoScreen extends StatefulWidget {
  final String nombre;
  final int color;

  const EditarHabitoScreen({
    super.key,
    required this.nombre,
    required this.color,
  });

  @override
  State<EditarHabitoScreen> createState() {
    return _EditarHabitoScreenState();
  }
}

class _EditarHabitoScreenState extends State<EditarHabitoScreen> {
  late final TextEditingController nombreController;
  late int colorSeleccionado;

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(
      text: widget.nombre,
    );

    colorSeleccionado = widget.color;
  }

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  // Crea un botón para seleccionar un color.
  Widget botonColor(String nombre, Color color) {
    final bool seleccionado =
        colorSeleccionado == color.toARGB32();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        setState(() {
          colorSeleccionado = color.toARGB32();
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (seleccionado)
            const Icon(Icons.check),

          const SizedBox(width: 4),

          Text(nombre),
        ],
      ),
    );
  }

  // Comprueba el nombre y devuelve los datos.
  void guardar() {
    final String nombre = nombreController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introduce el nombre del hábito'),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'nombre': nombre,
      'color': colorSeleccionado,
    });
  }

  @override
  Widget build(BuildContext context) {
    // Comprueba si estamos creando o editando.
    final bool esNuevo = widget.nombre.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          esNuevo ? 'Nuevo hábito' : 'Editar hábito',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo reutilizable para escribir el nombre.
            CampoTextoApp(
              texto: 'Nombre del hábito',
              pista: 'Introduce el nombre',
              controlador: nombreController,
            ),

            const SizedBox(height: 24),

            const Text(
              'Selecciona un color:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Botones para elegir el color.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                botonColor('Azul', Colors.blue),
                botonColor('Verde', Colors.green),
                botonColor('Naranja', Colors.orange),
              ],
            ),

            const SizedBox(height: 32),

            // Botón reutilizable para guardar.
            BotonPrincipal(
              texto: 'Guardar',
              accion: guardar,
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
