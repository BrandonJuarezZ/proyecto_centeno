import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Personaje.dart';
import '../models/Comentario.dart';
import '../repositories/PersonajeRepository.dart';
import 'AuthService.dart';

/// Servicio Mock para Personajes (simula respuestas sin backend)
/// Patrón: Mock Object Pattern + Repository Pattern + Persistence Pattern
class PersonajeServiceMock implements IPersonajeRepository {
  static final PersonajeServiceMock _instance = PersonajeServiceMock._internal();

  final Map<int, int> _likes = {};
  final Map<int, int> _dislikes = {};
  final Map<int, bool> _usuarioLikes = {};
  final Map<int, bool> _usuarioDislikes = {};
  final Map<int, List<Comentario>> _comentariosMap = {};
  int _comentarioIdCounter = 1;

  PersonajeServiceMock._internal() {
    _loadFromStorage();
  }

  factory PersonajeServiceMock() {
    return _instance;
  }

  /// Carga los datos desde SharedPreferences
  void _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mockData = prefs.getString('mockData');
      if (mockData != null) {
        final Map<String, dynamic> data = jsonDecode(mockData);

        if (data['likes'] != null) {
          (data['likes'] as Map<String, dynamic>).forEach((key, value) {
            _likes[int.parse(key)] = value as int;
          });
        }

        if (data['dislikes'] != null) {
          (data['dislikes'] as Map<String, dynamic>).forEach((key, value) {
            _dislikes[int.parse(key)] = value as int;
          });
        }

        if (data['usuarioLikes'] != null) {
          (data['usuarioLikes'] as Map<String, dynamic>).forEach((key, value) {
            _usuarioLikes[int.parse(key)] = value as bool;
          });
        }

        if (data['usuarioDislikes'] != null) {
          (data['usuarioDislikes'] as Map<String, dynamic>).forEach((key, value) {
            _usuarioDislikes[int.parse(key)] = value as bool;
          });
        }

        if (data['comentarios'] != null) {
          (data['comentarios'] as Map<String, dynamic>).forEach((key, value) {
            final comentariosList = (value as List<dynamic>)
                .map((c) => Comentario(
                      id: c['id'] as int,
                      contenido: c['contenido'] as String,
                      nombreUsuario: c['nombreUsuario'] as String,
                      fechaCreacion: DateTime.parse(c['fechaCreacion'] as String),
                      personajeId: c['personajeId'] as int,
                    ))
                .toList();
            _comentariosMap[int.parse(key)] = comentariosList;
          });
        }

        if (data['comentarioIdCounter'] != null) {
          _comentarioIdCounter = data['comentarioIdCounter'] as int;
        }

        print('✅ [MOCK] Datos cargados desde SharedPreferences');
      }
    } catch (e) {
      print('❌ [MOCK] Error al cargar datos: $e');
    }
  }

  /// Guarda los datos en SharedPreferences
  void _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'likes': _likes.map((key, value) => MapEntry(key.toString(), value)),
        'dislikes': _dislikes.map((key, value) => MapEntry(key.toString(), value)),
        'usuarioLikes': _usuarioLikes.map((key, value) => MapEntry(key.toString(), value)),
        'usuarioDislikes': _usuarioDislikes.map((key, value) => MapEntry(key.toString(), value)),
        'comentarios': _comentariosMap.map((key, comentarios) => MapEntry(
              key.toString(),
              comentarios
                  .map((c) => {
                        'id': c.id,
                        'contenido': c.contenido,
                        'nombreUsuario': c.nombreUsuario,
                        'fechaCreacion': c.fechaCreacion.toIso8601String(),
                        'personajeId': c.personajeId,
                      })
                  .toList(),
            )),
        'comentarioIdCounter': _comentarioIdCounter,
      };
      await prefs.setString('mockData', jsonEncode(data));
      print('💾 [MOCK] Datos guardados en SharedPreferences');
    } catch (e) {
      print('❌ [MOCK] Error al guardar datos: $e');
    }
  }

  @override
  Future<List<Personaje>> fetchPersonajes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Personaje(
        id: 1,
        nombre: 'Mario',
        descripcion: 'El fontanero más famoso del mundo',
        videojuego: 'Super Mario Bros',
        imagenUrl: 'https://upload.wikimedia.org/wikipedia/en/a/a9/MarioNSMBU.png',
        creadoPorNombre: 'Nintendo',
        likes: _likes[1] ?? 15,
        dislikes: _dislikes[1] ?? 2,
        usuarioHizoPlike: _usuarioLikes[1] ?? false,
        usuarioHizoDislike: _usuarioDislikes[1] ?? false,
        comentarios: _comentariosMap[1] ?? [],
      ),
      Personaje(
        id: 2,
        nombre: 'Donkey Kong',
        descripcion: 'El gorila más fuerte del reino',
        videojuego: 'Donkey Kong Country',
        imagenUrl: 'https://upload.wikimedia.org/wikipedia/en/8/8d/Donkey_Kong_artwork_%28HQ%29.png',
        creadoPorNombre: 'Rare',
        likes: _likes[2] ?? 12,
        dislikes: _dislikes[2] ?? 1,
        usuarioHizoPlike: _usuarioLikes[2] ?? false,
        usuarioHizoDislike: _usuarioDislikes[2] ?? false,
        comentarios: _comentariosMap[2] ?? [],
      ),
    ];
  }

  @override
  Future<Personaje> createPersonaje(
    String nombre,
    String descripcion,
    String videojuego,
    String imagenUrl,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('✅ [MOCK] Personaje creado: $nombre');
    return Personaje(
      id: DateTime.now().millisecondsSinceEpoch,
      nombre: nombre,
      descripcion: descripcion,
      videojuego: videojuego,
      imagenUrl: imagenUrl,
      creadoPorNombre: AuthService().token?.isNotEmpty == true ? 'Usuario' : 'Anónimo',
    );
  }

  @override
  Future<void> deletePersonaje(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('✅ [MOCK] Personaje eliminado: $id');
  }

  @override
  Future<Personaje> updatePersonaje(Personaje personaje) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('✅ [MOCK] Personaje actualizado: ${personaje.id}');
    return personaje;
  }

  @override
  Future<Personaje?> getPersonajeById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final personajes = await fetchPersonajes();
    return personajes.firstWhere((p) => p.id == id);
  }

  @override
  Future<List<Personaje>> searchByVideojuego(String videojuego) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final personajes = await fetchPersonajes();
    return personajes
        .where((p) => p.videojuego.toLowerCase().contains(videojuego.toLowerCase()))
        .toList();
  }

  @override
  Future<Personaje> likePersonaje(int personajeId) async {
    print('👍 [MOCK] Dando like al personaje: $personajeId');
    await Future.delayed(const Duration(milliseconds: 400));

    if (_usuarioDislikes[personajeId] == true) {
      _dislikes[personajeId] = (_dislikes[personajeId] ?? 1) - 1;
      _usuarioDislikes[personajeId] = false;
    }

    if (_usuarioLikes[personajeId] == true) {
      _likes[personajeId] = (_likes[personajeId] ?? 1) - 1;
      _usuarioLikes[personajeId] = false;
    } else {
      _likes[personajeId] = (_likes[personajeId] ?? 0) + 1;
      _usuarioLikes[personajeId] = true;
    }

    _saveToStorage();
    print('✅ [MOCK] Like actualizado para personaje $personajeId');
    return (await getPersonajeById(personajeId))!;
  }

  @override
  Future<Personaje> dislikePersonaje(int personajeId) async {
    print('👎 [MOCK] Dando dislike al personaje: $personajeId');
    await Future.delayed(const Duration(milliseconds: 400));

    if (_usuarioLikes[personajeId] == true) {
      _likes[personajeId] = (_likes[personajeId] ?? 1) - 1;
      _usuarioLikes[personajeId] = false;
    }

    if (_usuarioDislikes[personajeId] == true) {
      _dislikes[personajeId] = (_dislikes[personajeId] ?? 1) - 1;
      _usuarioDislikes[personajeId] = false;
    } else {
      _dislikes[personajeId] = (_dislikes[personajeId] ?? 0) + 1;
      _usuarioDislikes[personajeId] = true;
    }

    _saveToStorage();
    print('✅ [MOCK] Dislike actualizado para personaje $personajeId');
    return (await getPersonajeById(personajeId))!;
  }

  @override
  Future<Comentario> agregarComentario(int personajeId, String contenido) async {
    print('💬 [MOCK] Agregando comentario a personaje: $personajeId');
    await Future.delayed(const Duration(milliseconds: 300));

    final comentario = Comentario(
      id: _comentarioIdCounter++,
      contenido: contenido,
      nombreUsuario: 'brandonjuarez',
      fechaCreacion: DateTime.now(),
      personajeId: personajeId,
    );

    if (!_comentariosMap.containsKey(personajeId)) {
      _comentariosMap[personajeId] = [];
    }
    _comentariosMap[personajeId]!.add(comentario);

    _saveToStorage();
    print('✅ [MOCK] Comentario agregado: ${comentario.id}');
    return comentario;
  }

  @override
  Future<List<Comentario>> obtenerComentarios(int personajeId) async {
    print('📝 [MOCK] Obteniendo comentarios de personaje: $personajeId');
    await Future.delayed(const Duration(milliseconds: 300));
    return _comentariosMap[personajeId] ?? [];
  }

  @override
  Future<void> eliminarComentario(int comentarioId) async {
    print('🗑️ [MOCK] Eliminando comentario: $comentarioId');
    await Future.delayed(const Duration(milliseconds: 300));

    for (final comentarios in _comentariosMap.values) {
      comentarios.removeWhere((c) => c.id == comentarioId);
    }

    _saveToStorage();
    print('✅ [MOCK] Comentario eliminado');
  }

  @override
  void dispose() {
    print('🔌 [MOCK] Servicio Mock despachado');
  }
}