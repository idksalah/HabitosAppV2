
class Usuario {
  final String id;
  String usuario;
  String nombre;
  String apellidos;
  String correo;
  String contrasena;
  String rol;
  final DateTime fechaCreacion;

  Usuario({
    required this.id,
    required this.usuario,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.contrasena,
    required this.rol,
    required this.fechaCreacion,
  });

  // Convierte los datos del usuario a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario': usuario,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'contrasena': contrasena,
      'rol': rol,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  // Recupera los datos de un usuario desde JSON.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      usuario: json['usuario'] as String? ?? '',
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String? ?? '',
      correo: json['correo'] as String,
      contrasena: json['contrasena'] as String,
      rol: json['rol'] as String,
      fechaCreacion: DateTime.parse(
        json['fechaCreacion'] as String,
      ),
    );
  }
}
