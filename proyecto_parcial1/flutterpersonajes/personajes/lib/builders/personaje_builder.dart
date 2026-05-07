import '../models/Personaje.dart';

/// Builder Pattern para construir objetos Personaje
/// Permite construir objetos complejos paso a paso
/// Patrón: Builder
class PersonajeBuilder {
  int? _id;
  String? _nombre;
  String _descripcion = '';
  String? _videojuego;
  String _imagenUrl = '';
  String _creadoPorNombre = 'Desconocido';

  PersonajeBuilder();

  PersonajeBuilder withId(int id) {
    _id = id;
    return this;
  }

  PersonajeBuilder withNombre(String nombre) {
    _nombre = nombre;
    return this;
  }

  PersonajeBuilder withDescripcion(String descripcion) {
    _descripcion = descripcion;
    return this;
  }

  PersonajeBuilder withVideojuego(String videojuego) {
    _videojuego = videojuego;
    return this;
  }

  PersonajeBuilder withImagenUrl(String imagenUrl) {
    _imagenUrl = imagenUrl;
    return this;
  }

  PersonajeBuilder withCreadoPorNombre(String nombre) {
    _creadoPorNombre = nombre;
    return this;
  }

  /// Construye el Personaje
  /// Lanza excepción si faltan campos requeridos
  Personaje build() {
    if (_id == null) {
      throw Exception('ID es requerido para construir un Personaje');
    }
    if (_nombre == null || _nombre!.isEmpty) {
      throw Exception('Nombre es requerido para construir un Personaje');
    }
    if (_videojuego == null || _videojuego!.isEmpty) {
      throw Exception('Videojuego es requerido para construir un Personaje');
    }

    return Personaje(
      id: _id!,
      nombre: _nombre!,
      descripcion: _descripcion,
      videojuego: _videojuego!,
      imagenUrl: _imagenUrl,
      creadoPorNombre: _creadoPorNombre,
    );
  }

  /// Construye desde JSON (Factory Method)
  static PersonajeBuilder fromJson(Map<String, dynamic> json) {
    return PersonajeBuilder()
        .withId(json['id'] ?? 0)
        .withNombre(json['nombre'] ?? '')
        .withDescripcion(json['descripcion'] ?? '')
        .withVideojuego(json['videojuego'] ?? '')
        .withImagenUrl(json['imagenUrl'] ?? '')
        .withCreadoPorNombre(
          json['creadoPor'] != null
              ? json['creadoPor']['username'] ?? 'Desconocido'
              : 'Desconocido',
        );
  }

  /// Copia el builder con valores modificados
  PersonajeBuilder copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? videojuego,
    String? imagenUrl,
    String? creadoPorNombre,
  }) {
    return PersonajeBuilder()
        .withId(id ?? _id!)
        .withNombre(nombre ?? _nombre!)
        .withDescripcion(descripcion ?? _descripcion)
        .withVideojuego(videojuego ?? _videojuego!)
        .withImagenUrl(imagenUrl ?? _imagenUrl)
        .withCreadoPorNombre(creadoPorNombre ?? _creadoPorNombre);
  }
}
