
import 'package:flutter/material.dart';

import '../models/habito.dart';
import 'boton_principal.dart';

class TarjetaHabito extends StatelessWidget {
  final Habito habito;
  final bool completado;
  final IconData icono;
  final ValueChanged<bool> alCambiarCompletado;
  final VoidCallback alEditar;
  final VoidCallback alEliminar;

  const TarjetaHabito({
    super.key,
    required this.habito,
    required this.completado,
    this.icono = Icons.water_drop,
    required this.alCambiarCompletado,
    required this.alEditar,
    required this.alEliminar,
  });

  // Devuelve el nombre del color del hábito.
  String obtenerNombreColor() {
    if (habito.color == Colors.blue.toARGB32()) {
      return 'Azul';
    } else if (habito.color == Colors.green.toARGB32()) {
      return 'Verde';
    } else if (habito.color == Colors.orange.toARGB32()) {
      return 'Naranja';
    }

    return 'Personalizado';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: completado,
                  onChanged: (valor) {
                    if (valor != null) {
                      alCambiarCompletado(valor);
                    }
                  },
                ),

                CircleAvatar(
                  backgroundColor: Color(habito.color),
                  child: Icon(
                    icono,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habito.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        completado
                            ? 'Completado hoy'
                            : 'Pendiente',
                      ),

                      Text(
                        'Color: ${obtenerNombreColor()}',
                      ),

                      Text(
                        'Días completados: '
                            '${habito.fechasCompletado.toSet().length}',
                      ),
                    ],
                  ),
                ),

                IconButton(
                  tooltip: 'Eliminar hábito',
                  onPressed: alEliminar,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),

            const SizedBox(height: 8),

            BotonPrincipal(
              texto: 'Editar hábito',
              accion: alEditar,
            ),
          ],
        ),
      ),
    );
  }
}
