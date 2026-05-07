import 'Comentario.dart';

/// Modelo de dominio para Personaje
/// Patrón: Value Object Pattern (inmutable)
class Personaje {
  final int id;
  final String nombre;
  final String descripcion;
  final String videojuego;
  final String imagenUrl;
  final String? creadoPorNombre;
  final int likes;
  final int dislikes;
  final bool usuarioHizoPlike; // True si el usuario actual dio like
  final bool usuarioHizoDislike; // True si el usuario actual dio dislike
  final List<Comentario> comentarios;

  const Personaje({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.videojuego,
    required this.imagenUrl,
    this.creadoPorNombre,
    this.likes = 0,
    this.dislikes = 0,
    this.usuarioHizoPlike = false,
    this.usuarioHizoDislike = false,
    this.comentarios = const [],
  });

  /// Factory Constructor - Patrón: Factory Method
  factory Personaje.fromJson(Map<String, dynamic> json) {
    List<Comentario> comentariosList = [];
    if (json['comentarios'] != null && json['comentarios'] is List) {
      comentariosList = (json['comentarios'] as List)
          .map((c) => Comentario.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    return Personaje(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      videojuego: json['videojuego'] ?? '',
      imagenUrl: json['imagenUrl'] ?? '',
      creadoPorNombre: json['creadoPor'] != null 
          ? json['creadoPor']['username'] ?? 'Desconocido'
          : 'Desconocido',
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      usuarioHizoPlike: json['usuarioHizoPlike'] ?? false,
      usuarioHizoDislike: json['usuarioHizoDislike'] ?? false,
      comentarios: comentariosList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'videojuego': videojuego,
      'imagenUrl': imagenUrl,
      'creadoPorNombre': creadoPorNombre,
      'likes': likes,
      'dislikes': dislikes,
      'usuarioHizoPlike': usuarioHizoPlike,
      'usuarioHizoDislike': usuarioHizoDislike,
      'comentarios': comentarios.map((c) => c.toJson()).toList(),
    };
  }

  /// Implementar equality para comparación
  /// Patrón: Value Object Pattern
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Personaje &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nombre == other.nombre &&
          videojuego == other.videojuego;

  @override
  int get hashCode => id.hashCode ^ nombre.hashCode ^ videojuego.hashCode;

  /// CopyWith para crear una copia modificada
  /// Patrón: Fluent Builder Pattern
  Personaje copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? videojuego,
    String? imagenUrl,
    String? creadoPorNombre,
    int? likes,
    int? dislikes,
    bool? usuarioHizoPlike,
    bool? usuarioHizoDislike,
    List<Comentario>? comentarios,
  }) {
    return Personaje(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      videojuego: videojuego ?? this.videojuego,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      creadoPorNombre: creadoPorNombre ?? this.creadoPorNombre,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      usuarioHizoPlike: usuarioHizoPlike ?? this.usuarioHizoPlike,
      usuarioHizoDislike: usuarioHizoDislike ?? this.usuarioHizoDislike,
      comentarios: comentarios ?? this.comentarios,
    );
  }
}