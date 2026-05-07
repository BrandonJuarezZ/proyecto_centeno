import 'package:http/http.dart' as http;

/// Singleton para gestionar el cliente HTTP de la aplicación
/// Patrón: Singleton
class NetworkClient {
  static final NetworkClient _instance = NetworkClient._internal();
  late http.Client _client;

  NetworkClient._internal() {
    _client = http.Client();
  }

  factory NetworkClient() {
    return _instance;
  }

  http.Client get client => _client;

  /// Método para reiniciar el cliente si es necesario
  void reset() {
    _client.close();
    _client = http.Client();
  }

  /// Cierra la conexión del cliente
  void dispose() {
    _client.close();
  }
}
