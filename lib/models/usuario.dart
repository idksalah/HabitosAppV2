
class Usuario {
  final String id;
  String nombre;
  String correo;
  String contrasena;
  String rol;
  final DateTime fechaCreacion;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.rol,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'contrasena': contrasena,
      'rol': rol,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      contrasena: json['contrasena'],
      rol: json['rol'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}
