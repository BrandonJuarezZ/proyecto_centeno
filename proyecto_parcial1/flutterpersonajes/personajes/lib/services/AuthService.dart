import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/LoginRequest.dart';
import '../models/SignupRequest.dart';
import '../models/JwtResponse.dart';
import '../core/network_client.dart';

/// Servicio de Autenticación
/// Patrón: Singleton mejorado con encapsulación
class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  static const String baseUrl = 'https://personajes-api-likes.onrender.com/api';
  static const Duration requestTimeout = Duration(seconds: 10);
  
  String? _token;
  late http.Client _httpClient;

  AuthService._internal() {
    _httpClient = NetworkClient().client;
  }

  factory AuthService() {
    return _instance;
  }

  // Getters
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  /// Inicia sesión con usuario y contraseña
  /// Patrón: Factory Method (crea JwtResponse)
  Future<JwtResponse> login(String username, String password) async {
    print('🔐 Iniciando login para: $username');
    try {
      final loginRequest = LoginRequest(username: username, password: password);
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginRequest.toJson()),
      ).timeout(requestTimeout);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jwtResponse = JwtResponse.fromJson(jsonDecode(response.body));
        _token = jwtResponse.token;
        print('✅ Login exitoso. Token: ${_token?.substring(0, 20)}...');
        return jwtResponse;
      } else {
        throw AuthException('Login failed: Status ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      print('❌ Error de conexión en login: $e');
      throw AuthException('Conexión fallida: $e');
    } catch (e) {
      print('❌ Error en login: $e');
      throw AuthException('Login Failed: $e');
    }
  }

  /// Registra un nuevo usuario
  /// Patrón: Template Method (estructura consistente con login)
  Future<void> signup(String username, String email, String password) async {
    print('📝 Iniciando signup para: $username');
    try {
      final signupRequest = SignupRequest(username: username, email: email, password: password);
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(signupRequest.toJson()),
      ).timeout(requestTimeout);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AuthException('Signup failed: ${response.body}');
      }
      print('✅ Signup exitoso');
    } on http.ClientException catch (e) {
      print('❌ Error de conexión en signup: $e');
      throw AuthException('Conexión fallida: $e');
    } catch (e) {
      print('❌ Error en signup: $e');
      throw AuthException('Signup Failed: $e');
    }
  }

  /// Cierra la sesión del usuario
  void logout() {
    _token = null;
    print('🚪 Logout exitoso');
  }

  /// Obtiene los headers con autenticación
  Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}

/// Excepción personalizada para errores de autenticación
/// Patrón: Custom Exception
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
