/// Modelo para un Comentario
/// Patrón: Value Object Pattern (inmutable)
class Comentario {
  final int id;
  final String contenido;
  final String nombreUsuario;
  final DateTime fechaCreacion;
  final int personajeId;

  const Comentario({
    required this.id,
    required this.contenido,
    required this.nombreUsuario,
    required this.fechaCreacion,
    required this.personajeId,
  });

  /// Factory Constructor - Patrón: Factory Method
  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'] ?? 0,
      contenido: json['contenido'] ?? '',
      nombreUsuario: json['usuario']?['username'] ?? json['nombreUsuario'] ?? 'Anónimo',
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion']) 
          : DateTime.now(),
      personajeId: json['personajeId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contenido': contenido,
      'nombreUsuario': nombreUsuario,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'personajeId': personajeId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comentario &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// CopyWith para crear una copia modificada
  Comentario copyWith({
    int? id,
    String? contenido,
    String? nombreUsuario,
    DateTime? fechaCreacion,
    int? personajeId,
  }) {
    return Comentario(
      id: id ?? this.id,
      contenido: contenido ?? this.contenido,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      personajeId: personajeId ?? this.personajeId,
    );
  }
}
