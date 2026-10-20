
class Habito {
  final String id;
  String nombre;
  int color;
  List<String> fechasCompletado;

  Habito({
    required this.id,
    required this.nombre,
    required this.color,
    List<String>? fechasCompletado,
  }) : fechasCompletado = fechasCompletado ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'fechasCompletado': fechasCompletado,
    };
  }

  factory Habito.fromJson(Map<String, dynamic> json) {
    return Habito(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      color: json['color'] as int,
      fechasCompletado: List<String>.from(
        json['fechasCompletado'] ?? [],
      ),
    );
  }
}