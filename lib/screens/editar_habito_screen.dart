import 'package:flutter/material.dart';

class EditarHabitoScreen extends StatefulWidget {
  final String nombre;
  final int color;

  const EditarHabitoScreen({
    super.key,
    required this.nombre,
    required this.color,
  });

  @override
  State<EditarHabitoScreen> createState() => _EditarHabitoScreenState();
}

class _EditarHabitoScreenState extends State<EditarHabitoScreen> {
  late final TextEditingController nombreController;
  late int colorSeleccionado;

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(text: widget.nombre);
    colorSeleccionado = widget.color;
  }

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  Widget botonColor(String nombre, Color color) {
    final bool seleccionado = colorSeleccionado == color.toARGB32();

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
          if (seleccionado) const Icon(Icons.check),
          const SizedBox(width: 4),
          Text(nombre),
        ],
      ),
    );
  }

  void guardar() {
    final String nombre = nombreController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce el nombre del hábito')),
      );
      return;
    }

    Navigator.pop(context, {'nombre': nombre, 'color': colorSeleccionado});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar hábito')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del hábito',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Selecciona un color:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                botonColor('Azul', Colors.blue),
                botonColor('Verde', Colors.green),
                botonColor('Naranja', Colors.orange),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: guardar, child: const Text('Guardar')),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
