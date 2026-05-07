/// Enum para los diferentes estados de la aplicación
/// Patrón: State Pattern
enum AppState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Clase para manejar el estado global de la aplicación
/// Patrón: Observer Pattern (observable)
class AppStateManager {
  static final AppStateManager _instance = AppStateManager._internal();
  
  AppState _currentState = AppState.initial;
  String _username = '';
  String? _errorMessage;
  
  final List<Function(AppState)> _listeners = [];

  AppStateManager._internal();

  factory AppStateManager() {
    return _instance;
  }

  // Getters
  AppState get currentState => _currentState;
  String get username => _username;
  String? get errorMessage => _errorMessage;

  // Setters con notificación
  void setAuthenticated(String username) {
    _currentState = AppState.authenticated;
    _username = username;
    _errorMessage = null;
    _notifyListeners();
  }

  void setUnauthenticated() {
    _currentState = AppState.unauthenticated;
    _username = '';
    _errorMessage = null;
    _notifyListeners();
  }

  void setLoading() {
    _currentState = AppState.loading;
    _errorMessage = null;
    _notifyListeners();
  }

  void setError(String message) {
    _currentState = AppState.error;
    _errorMessage = message;
    _notifyListeners();
  }

  /// Suscribirse a cambios de estado
  void addListener(Function(AppState) listener) {
    _listeners.add(listener);
  }

  /// Desuscribirse de cambios de estado
  void removeListener(Function(AppState) listener) {
    _listeners.remove(listener);
  }

  /// Notifica a todos los listeners sobre el cambio de estado
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_currentState);
    }
  }

  /// Reinicia el estado
  void reset() {
    _currentState = AppState.initial;
    _username = '';
    _errorMessage = null;
    _listeners.clear();
  }
}
