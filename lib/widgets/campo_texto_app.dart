
import 'package:flutter/material.dart';

class CampoTextoApp extends StatelessWidget {
  final String texto;
  final String pista;
  final TextEditingController controlador;
  final bool ocultarTexto;

  const CampoTextoApp({
    super.key,
    required this.texto,
    required this.pista,
    required this.controlador,
    this.ocultarTexto = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texto),
        const SizedBox(height: 8),
        TextField(
          controller: controlador,
          obscureText: ocultarTexto,
          decoration: InputDecoration(
            hintText: pista,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
