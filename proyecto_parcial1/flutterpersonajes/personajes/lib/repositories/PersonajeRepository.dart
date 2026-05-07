import '../models/Personaje.dart';
import '../models/Comentario.dart';

/// Interfaz para el Repositorio de Personajes
/// Patrón: Repository Pattern + Abstraction
/// Define el contrato que debe cumplir cualquier implementación
abstract class IPersonajeRepository {
  /// Obtiene todos los personajes
  /// Retorna: Lista de personajes o excepción
  Future<List<Personaje>> fetchPersonajes();

  /// Crea un nuevo personaje
  /// Parámetros: datos del personaje
  /// Retorna: Personaje creado con ID o excepción
  Future<Personaje> createPersonaje(
    String nombre,
    String descripcion,
    String videojuego,
    String imagenUrl,
  );

  /// Elimina un personaje por ID
  /// Parámetros: ID del personaje a eliminar
  /// Retorna: void o excepción si falla
  Future<void> deletePersonaje(int id);

  /// Actualiza un personaje existente
  /// Patrón: Extension Method (nuevo)
  Future<Personaje> updatePersonaje(Personaje personaje);

  /// Obtiene un personaje por ID
  /// Patrón: Specification Pattern (nuevo)
  Future<Personaje?> getPersonajeById(int id);

  /// Busca personajes por videojuego
  /// Patrón: Query Object (nuevo)
  Future<List<Personaje>> searchByVideojuego(String videojuego);

  /// Da like a un personaje
  /// Parámetros: ID del personaje
  /// Retorna: Personaje actualizado con el nuevo contador de likes
  Future<Personaje> likePersonaje(int personajeId);

  /// Da dislike a un personaje
  /// Parámetros: ID del personaje
  /// Retorna: Personaje actualizado con el nuevo contador de dislikes
  Future<Personaje> dislikePersonaje(int personajeId);

  /// Agrega un comentario a un personaje
  /// Parámetros: ID del personaje, contenido del comentario
  /// Retorna: Comentario creado con ID
  Future<Comentario> agregarComentario(int personajeId, String contenido);

  /// Obtiene los comentarios de un personaje
  /// Parámetros: ID del personaje
  /// Retorna: Lista de comentarios
  Future<List<Comentario>> obtenerComentarios(int personajeId);

  /// Elimina un comentario
  /// Parámetros: ID del comentario
  /// Retorna: void o excepción si falla
  Future<void> eliminarComentario(int comentarioId);

  /// Limpia recursos
  void dispose();
}