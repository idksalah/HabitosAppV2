
import 'package:flutter/material.dart';

class DatoEstadistica extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const DatoEstadistica({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icono,
              size: 30,
              color: color,
            ),

            const SizedBox(height: 8),

            Text(
              valor,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(titulo),
          ],
        ),
      ),
    );
  }
}
