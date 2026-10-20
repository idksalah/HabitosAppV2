
import 'package:flutter/material.dart';
import '../services/preferencias_service.dart';
import 'inicio_screen.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() {
    return _BienvenidaScreenState();
  }
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  final TextEditingController nombreController =
  TextEditingController();

  final TextEditingController objetivoController =
  TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    objetivoController.dispose();
    super.dispose();
  }

  Future<void> continuar() async {
    final String nombre = nombreController.text.trim();
    final String objetivo = objetivoController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes introducir tu nombre'),
        ),
      );
      return;
    }

    if (objetivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes introducir tu objetivo diario'),
        ),
      );
      return;
    }

    final int? numeroObjetivo = int.tryParse(objetivo);

    if (numeroObjetivo == null || numeroObjetivo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Introduce un número entero mayor que cero',
          ),
        ),
      );
      return;
    }

    await PreferenciasService.guardarDatosUsuario(
      nombre,
      numeroObjetivo,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => InicioScreen(
          nombre: nombre,
          objetivo: numeroObjetivo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitosApp'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bienvenido a HabitosApp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Organiza tus hábitos diarios',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del usuario',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: objetivoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Objetivo diario de hábitos',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: continuar,
                child: const Text('Comenzar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
