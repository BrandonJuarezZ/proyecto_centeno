import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/Personaje.dart';
import '../models/Comentario.dart';
import '../models/PersonajeResponse.dart';
import '../repositories/PersonajeRepository.dart';
import '../builders/personaje_builder.dart';
import '../core/network_client.dart';
import 'AuthService.dart';

/// Servicio para gestionar Personajes
/// Patrón: Singleton + Repository Pattern + Factory Method
class PersonajeService implements IPersonajeRepository {
  static final PersonajeService _instance = PersonajeService._internal();

  static const String baseUrl = 'https://personajes-api-likes.onrender.com/api';
  static const Duration requestTimeout = Duration(seconds: 10);

  late http.Client _httpClient;
  late AuthService _authService;

  PersonajeService._internal() {
    _httpClient = NetworkClient().client;
    _authService = AuthService(); // Obtener singleton de AuthService una sola vez
  }

  factory PersonajeService() {
    return _instance;
  }

  /// Obtiene todos los personajes
  /// Patrón: Factory Method (crea lista de Personajes)
  @override
  Future<List<Personaje>> fetchPersonajes() async {
    print('📥 Obteniendo personajes...');
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/characters/all'),
        headers: _authService.getHeaders(),
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return _parsePersonajeResponse(jsonData);
      } else {
        throw PersonajeException('Error al cargar personajes: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      print('❌ Error de conexión: $e');
      throw PersonajeException('Conexión fallida: $e');
    } catch (e) {
      print('❌ Error al obtener personajes: $e');
      throw PersonajeException('Error: $e');
    }
  }

  /// Crea un nuevo personaje
  /// Patrón: Builder Pattern + Factory Method
  @override
  Future<Personaje> createPersonaje(
    String nombre,
    String descripcion,
    String videojuego,
    String imagenUrl,
  ) async {
    print('📝 Creando personaje: {nombre: $nombre, videojuego: $videojuego}');
    try {
      final headers = _authService.getHeaders();
      print('📝 Headers: $headers');
      print('🔑 Token disponible: ${AuthService().isLoggedIn}');

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/characters/create'),
        headers: headers,
        body: jsonEncode({
          'nombre': nombre,
          'descripcion': descripcion,
          'videojuego': videojuego,
          'imagenUrl': imagenUrl,
        }),
      ).timeout(requestTimeout, onTimeout: () {
        print('⏱️ TIMEOUT: La petición tardó más de 10 segundos');
        throw PersonajeException('Request timeout after 10 seconds');
      });

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final personaje = _createPersonajeFromJson(jsonDecode(response.body));
        print('✅ Personaje creado: ${personaje.nombre}');
        return personaje;
      } else {
        throw PersonajeException('Error al crear personaje: ${response.body}');
      }
    } on http.ClientException catch (e) {
      print('❌ Error de conexión: $e');
      throw PersonajeException('Conexión fallida: $e');
    } catch (e) {
      print('❌ Error en createPersonaje: $e');
      rethrow;
    }
  }

  /// Elimina un personaje
  @override
  Future<void> deletePersonaje(int id) async {
    print('🗑️ Eliminando personaje con ID: $id');
    try {
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/characters/$id'),
        headers: _authService.getHeaders(),
      ).timeout(requestTimeout);

      if (response.statusCode != 200 &&
          response.statusCode != 204 &&
          response.statusCode != 201) {
        throw PersonajeException('Error al eliminar personaje: ${response.statusCode}');
      }
      print('✅ Personaje eliminado');
    } on http.ClientException catch (e) {
      print('❌ Error de conexión: $e');
      throw PersonajeException('Conexión fallida: $e');
    } catch (e) {
      print('❌ Error al eliminar: $e');
      rethrow;
    }
  }

  /// Actualiza un personaje existente
  /// Patrón: Template Method (similar a createPersonaje)
  @override
  Future<Personaje> updatePersonaje(Personaje personaje) async {
    print('✏️ Actualizando personaje: ${personaje.nombre}');
    try {
      final headers = AuthService().getHeaders();
      final response = await _httpClient.put(
        Uri.parse('$baseUrl/characters/${personaje.id}'),
        headers: headers,
        body: jsonEncode(personaje.toJson()),
      ).timeout(requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final personajeActualizado = _createPersonajeFromJson(jsonDecode(response.body));
        print('✅ Personaje actualizado: ${personajeActualizado.nombre}');
        return personajeActualizado;
      } else {
        throw PersonajeException('Error al actualizar personaje: ${response.body}');
      }
    } catch (e) {
      print('❌ Error al actualizar: $e');
      rethrow;
    }
  }

  /// Obtiene un personaje por ID
  /// Patrón: Specification Pattern
  @override
  Future<Personaje?> getPersonajeById(int id) async {
    print('🔍 Buscando personaje con ID: $id');
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/characters/$id'),
        headers: AuthService().getHeaders(),
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        return _createPersonajeFromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        print('❌ Personaje no encontrado');
        return null;
      } else {
        throw PersonajeException('Error al obtener personaje: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener personaje: $e');
      return null;
    }
  }

  /// Busca personajes por videojuego
  /// Patrón: Query Object
  @override
  Future<List<Personaje>> searchByVideojuego(String videojuego) async {
    print('🎮 Buscando personajes de: $videojuego');
    try {
      final allPersonajes = await fetchPersonajes();
      final filtered = allPersonajes
          .where((p) => p.videojuego.toLowerCase().contains(videojuego.toLowerCase()))
          .toList();
      print('✅ Encontrados ${filtered.length} personajes de $videojuego');
      return filtered;
    } catch (e) {
      print('❌ Error al buscar: $e');
      return [];
    }
  }

  /// Factory Method para crear Personaje desde JSON
  /// Utiliza PersonajeBuilder para construcción
  Personaje _createPersonajeFromJson(Map<String, dynamic> json) {
    return PersonajeBuilder.fromJson(json).build();
  }

  /// Parsea la respuesta del servidor (paginada o lista)
  /// Patrón: Strategy Pattern (diferentes estrategias de parsing)
  List<Personaje> _parsePersonajeResponse(dynamic jsonData) {
    if (jsonData is Map && jsonData.containsKey('content')) {
      // Respuesta paginada
      final personajeResponse = PersonajeResponse.fromJson(jsonData as Map<String, dynamic>);
      return personajeResponse.content;
    } else if (jsonData is List) {
      // Respuesta como lista directa
      return (jsonData as List)
          .map((p) => PersonajeBuilder.fromJson(p as Map<String, dynamic>).build())
          .toList();
    }
    return [];
  }

  /// Da like a un personaje
  /// Patrón: Command Pattern (acción reversible)
  @override
  Future<Personaje> likePersonaje(int personajeId) async {
    print('👍 Dando like al personaje: $personajeId');
    try {
      final headers = _authService.getHeaders();
      final url = 'https://personajes-api-likes.onrender.com/api/character-reactions/like/$personajeId';
      print('📝 URL: $url');
      final response = await _httpClient.post(
        Uri.parse(url),
        headers: headers,
      ).timeout(requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Like registrado');
        return await fetchPersonajes().then((list) => list.firstWhere((p) => p.id == personajeId));
      } else {
        throw PersonajeException('Error al dar like: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al dar like: $e');
      rethrow;
    }
  }

  /// Da dislike (hate) a un personaje
  /// Patrón: Command Pattern (acción reversible)
  @override
  Future<Personaje> dislikePersonaje(int personajeId) async {
    print('👎 Dando dislike al personaje: $personajeId');
    try {
      final headers = _authService.getHeaders();
      final url = 'https://personajes-api-likes.onrender.com/api/character-reactions/hate/$personajeId';
      print('📝 URL: $url');
      final response = await _httpClient.post(
        Uri.parse(url),
        headers: headers,
      ).timeout(requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Dislike registrado');
        return await fetchPersonajes().then((list) => list.firstWhere((p) => p.id == personajeId));
      } else {
        throw PersonajeException('Error al dar dislike: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al dar dislike: $e');
      rethrow;
    }
  }

  /// Agrega un comentario a un personaje
  /// Patrón: Factory Method (crea nuevo comentario)
  @override
  Future<Comentario> agregarComentario(int personajeId, String contenido) async {
    print('💬 Agregando comentario a personaje: $personajeId');
    try {
      final url = 'https://personajes-api-likes.onrender.com/api/comentarios';
      final response = await _httpClient.post(
        Uri.parse(url),
        headers: _authService.getHeaders(),
        body: jsonEncode({
          'contenido': contenido,
          'personajeId': personajeId,
        }),
      ).timeout(requestTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Comentario.fromJson(json);
      } else {
        throw PersonajeException('Error al agregar comentario: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al agregar comentario: $e');
      rethrow;
    }
  }

  /// Obtiene los comentarios de un personaje
  /// Patrón: Query Object
  @override
  Future<List<Comentario>> obtenerComentarios(int personajeId) async {
    print('📝 Obteniendo comentarios de personaje: $personajeId');
    try {
      final url = 'https://personajes-api-likes.onrender.com/api/comentarios/$personajeId';
      final response = await _httpClient.get(
        Uri.parse(url),
        headers: _authService.getHeaders(),
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          return (jsonData as List)
              .map((c) => Comentario.fromJson(c as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw PersonajeException('Error al obtener comentarios: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener comentarios: $e');
      return [];
    }
  }

  /// Elimina un comentario
  @override
  Future<void> eliminarComentario(int comentarioId) async {
    print('🗑️ Eliminando comentario: $comentarioId');
    try {
      final url = 'https://personajes-api-likes.onrender.com/api/comentarios/$comentarioId';
      final response = await _httpClient.delete(
        Uri.parse(url),
        headers: _authService.getHeaders(),
      ).timeout(requestTimeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw PersonajeException('Error al eliminar comentario: ${response.statusCode}');
      }
      print('✅ Comentario eliminado');
    } catch (e) {
      print('❌ Error al eliminar comentario: $e');
      rethrow;
    }
  }

  /// Limpia recursos
  @override
  void dispose() {
    _httpClient.close();
  }
}

/// Excepción personalizada para errores de Personajes
/// Patrón: Custom Exception
class PersonajeException implements Exception {
  final String message;
  PersonajeException(this.message);

  @override
  String toString() => 'PersonajeException: $message';
}