
import 'package:flutter/material.dart';

class BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback accion;

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: accion,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(
            fontSize: 16,
          ),
        ),
        child: Text(texto),
      ),
    );
  }
}
