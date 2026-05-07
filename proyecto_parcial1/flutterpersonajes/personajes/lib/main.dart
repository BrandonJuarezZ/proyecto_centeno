import 'package:flutter/material.dart';
import 'core/service_locator.dart';
import 'core/app_state.dart';
import 'services/AuthService.dart';
import 'repositories/PersonajeRepository.dart';
import 'models/Personaje.dart';
import 'models/Comentario.dart';
import 'builders/personaje_builder.dart';
import 'screens/LoginScreen.dart';
import 'screens/SignupScreen.dart';

void main() {
  // Inicializar Service Locator
  ServiceLocator();
  runApp(const MyApp());
}

/// Componente principal de la aplicación
/// Patrón: Navigation Pattern + State Management
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppStateManager _appStateManager;
  bool _isLoggedIn = false;
  String _username = '';
  int _currentScreen = 0;

  @override
  void initState() {
    super.initState();
    _appStateManager = AppStateManager();
  }

  void _handleLoginSuccess(String username) {
    setState(() {
      _isLoggedIn = true;
      _username = username;
      _currentScreen = 2;
    });
    _appStateManager.setAuthenticated(username);
  }

  void _handleSignupSuccess() {
    setState(() {
      _currentScreen = 0;
    });
  }

  void _handleToSignup() {
    setState(() {
      _currentScreen = 1;
    });
  }

  void _handleBackToLogin() {
    setState(() {
      _currentScreen = 0;
    });
  }

  void _handleLogout() {
    AuthService().logout();
    setState(() {
      _isLoggedIn = false;
      _username = '';
      _currentScreen = 0;
    });
    _appStateManager.setUnauthenticated();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;

    if (_isLoggedIn) {
      currentScreen = MyHomePage(
        title: 'Personajes Videojuegos',
        username: _username,
        onLogout: _handleLogout,
      );
    } else if (_currentScreen == 1) {
      currentScreen = SignupScreen(
        onSignupSuccess: _handleSignupSuccess,
        onBackToLogin: _handleBackToLogin,
      );
    } else {
      currentScreen = LoginScreen(
        onLoginSuccess: _handleLoginSuccess,
        onToSignup: _handleToSignup,
      );
    }

    return MaterialApp(
      title: 'Personajes Videojuegos',
      theme: ThemeData.dark(),
      home: currentScreen,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.username,
    required this.onLogout,
  });

  final String title;
  final String username;
  final VoidCallback onLogout;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Clase para manejar la creación de personajes
/// Patrón: Builder Pattern
class _PersonajeFormController {
  final TextEditingController nombre = TextEditingController();
  final TextEditingController descripcion = TextEditingController();
  final TextEditingController videojuego = TextEditingController();
  final TextEditingController imagen = TextEditingController();

  bool validate() {
    return nombre.text.isNotEmpty && videojuego.text.isNotEmpty;
  }

  void clear() {
    nombre.clear();
    descripcion.clear();
    videojuego.clear();
    imagen.clear();
  }

  void dispose() {
    nombre.dispose();
    descripcion.dispose();
    videojuego.dispose();
    imagen.dispose();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Personaje>> _future;
  bool _isLoading = false;
  late IPersonajeRepository _personajeService;
  late _PersonajeFormController _formController;

  @override
  void initState() {
    super.initState();
    // Patrón: Service Locator
    _personajeService = ServiceLocator().get<IPersonajeRepository>(
      'personajeService',
    );
    _formController = _PersonajeFormController();
    _load();
  }

  void _load() {
    setState(() {
      _future = _personajeService.fetchPersonajes();
    });
  }

  Future<void> _crearPersonaje() async {
    if (!_formController.validate()) {
      _showSnackBar('Por favor completa los campos requeridos', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _personajeService.createPersonaje(
        _formController.nombre.text,
        _formController.descripcion.text,
        _formController.videojuego.text,
        _formController.imagen.text,
      );
      _formController.clear();
      _load();
      if (mounted) {
        _showSnackBar('✅ Personaje creado exitosamente');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePersonaje(int id) async {
    setState(() => _isLoading = true);
    try {
      await _personajeService.deletePersonaje(id);
      _load();
      if (mounted) {
        _showSnackBar('🗑️ Personaje eliminado');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Personaje'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este personaje?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePersonaje(id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Personaje'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _formController.nombre,
                decoration: const InputDecoration(labelText: 'Nombre *'),
              ),
              TextField(
                controller: _formController.descripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              TextField(
                controller: _formController.videojuego,
                decoration: const InputDecoration(labelText: 'Videojuego *'),
              ),
              TextField(
                controller: _formController.imagen,
                decoration: const InputDecoration(labelText: 'URL de Imagen'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _crearPersonaje();
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Hola, ${widget.username}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: FutureBuilder<List<Personaje>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No hay personajes disponibles'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showCreateDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Personaje'),
                  ),
                ],
              ),
            );
          }

          final personajes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: personajes.length,
            itemBuilder: (context, index) {
              final personaje = personajes[index];
              return _PersonajeCard(
                personaje: personaje,
                onDelete: () => _showDeleteConfirmation(personaje.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        tooltip: 'Agregar Personaje',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget para mostrar un personaje con likes, dislikes y comentarios
/// Patrón: Composite Pattern + Observer Pattern
class _PersonajeCard extends StatefulWidget {
  final Personaje personaje;
  final VoidCallback onDelete;

  const _PersonajeCard({required this.personaje, required this.onDelete});

  @override
  State<_PersonajeCard> createState() => _PersonajeCardState();
}

class _PersonajeCardState extends State<_PersonajeCard> {
  late Personaje _personaje;
  late IPersonajeRepository _personajeService;
  List<Comentario> _comentarios = [];
  bool _expandirComentarios = false;
  final TextEditingController _comentarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _personaje = widget.personaje;
    _personajeService = ServiceLocator().get<IPersonajeRepository>(
      'personajeService',
    );
    _comentarios = _personaje.comentarios;
    _obtenerComentarios();
  }

  void _obtenerComentarios() async {
    try {
      final comentarios = await _personajeService.obtenerComentarios(
        _personaje.id,
      );
      setState(() {
        _comentarios = comentarios;
      });
    } catch (e) {
      print('Error al obtener comentarios: $e');
    }
  }

  void _darLike() async {
    try {
      final personajeActualizado = await _personajeService.likePersonaje(
        _personaje.id,
      );
      setState(() {
        _personaje = personajeActualizado;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al dar like: $e')));
    }
  }

  void _darDislike() async {
    try {
      final personajeActualizado = await _personajeService.dislikePersonaje(
        _personaje.id,
      );
      setState(() {
        _personaje = personajeActualizado;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al dar dislike: $e')));
    }
  }

  void _agregarComentario() async {
    if (_comentarioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El comentario no puede estar vacío')),
      );
      return;
    }

    try {
      final nuevoComentario = await _personajeService.agregarComentario(
        _personaje.id,
        _comentarioController.text,
      );
      setState(() {
        _comentarios.add(nuevoComentario);
        _comentarioController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar comentario: $e')),
      );
    }
  }

  void _eliminarComentario(int comentarioId) async {
    try {
      await _personajeService.eliminarComentario(comentarioId);
      setState(() {
        _comentarios.removeWhere((c) => c.id == comentarioId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comentario eliminado')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar comentario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con imagen y info básica
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_personaje.imagenUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _personaje.imagenUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  )
                else
                  const Icon(Icons.sports_esports, size: 80),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _personaje.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '🎮 ${_personaje.videojuego}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (_personaje.descripcion.isNotEmpty)
                        Text(
                          _personaje.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      Text(
                        'Creado por: ${_personaje.creadoPorNombre}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const Divider(height: 16),
            // Sección de Like/Dislike
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _darLike,
                    icon: Icon(
                      Icons.thumb_up,
                      color: _personaje.usuarioHizoPlike
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    label: Text('Like (${_personaje.likes})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _personaje.usuarioHizoPlike
                          ? Colors.blue[100]
                          : Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _darDislike,
                    icon: Icon(
                      Icons.thumb_down,
                      color: _personaje.usuarioHizoDislike
                          ? Colors.red
                          : Colors.grey,
                    ),
                    label: Text('Dislike (${_personaje.dislikes})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _personaje.usuarioHizoDislike
                          ? Colors.red[100]
                          : Colors.grey[200],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Sección de Comentarios
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandirComentarios = !_expandirComentarios;
                });
              },
              child: Row(
                children: [
                  const Icon(Icons.comment, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Comentarios (${_comentarios.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(
                    _expandirComentarios
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
                ],
              ),
            ),
            if (_expandirComentarios) ...[
              const SizedBox(height: 12),
              // Input para nuevo comentario
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _comentarioController,
                      decoration: InputDecoration(
                        hintText: 'Agregar comentario...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: 2,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _agregarComentario,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Lista de comentarios
              if (_comentarios.isEmpty)
                const Center(
                  child: Text(
                    'No hay comentarios aún',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _comentarios.length,
                  itemBuilder: (context, index) {
                    final comentario = _comentarios[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comentario.nombreUsuario,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comentario.contenido,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70, // 👈 agregar
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(comentario.fechaCreacion),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  _eliminarComentario(comentario.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }
}
