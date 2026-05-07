import '../services/AuthService.dart';
import '../services/PersonajeService.dart';
import '../services/PersonajeServiceMock.dart';
import '../repositories/PersonajeRepository.dart';
import 'network_client.dart';

/// Service Locator - Patrón para inyección de dependencias
/// Permite gestionar instancias singleton de servicios
/// Patrón: Service Locator + Factory Method
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  final Map<String, dynamic> _services = {};

  ServiceLocator._internal() {
    _registerServices();
  }

  factory ServiceLocator() {
    return _instance;
  }

  /// Registra todos los servicios de la aplicación
  void _registerServices() {
    // Registrar NetworkClient como Singleton
    _services['networkClient'] = NetworkClient();

    // Registrar AuthService como Singleton
    _services['authService'] = AuthService();

    // Registrar PersonajeService como Singleton (Backend real)
    _services['personajeService'] = PersonajeService();
    // Para usar mock: _services['personajeService'] = PersonajeServiceMock();
  }

  /// Obtiene una instancia de un servicio registrado
  T get<T>([String? serviceName]) {
    final key = serviceName ?? 'default';
    
    // Si buscamos IPersonajeRepository o PersonajeService, devolvemos personajeService
    if (T.toString().contains('Repository') || T.toString().contains('PersonajeService') || serviceName == 'personajeService') {
      return _services['personajeService'] as T;
    }
    if (T.toString().contains('AuthService') || serviceName == 'AuthService') {
      return _services['authService'] as T;
    }
    if (T.toString().contains('NetworkClient') || serviceName == 'NetworkClient') {
      return _services['networkClient'] as T;
    }
    
    if (!_services.containsKey(key)) {
      throw Exception('Servicio "$key" (${T.toString()}) no registrado en ServiceLocator');
    }
    return _services[key] as T;
  }

  /// Registra un servicio manualmente
  void register<T>(String serviceName, T service) {
    _services[serviceName] = service;
  }

  /// Limpia todos los servicios
  void dispose() {
    for (final service in _services.values) {
      if (service is NetworkClient) {
        service.dispose();
      }
    }
    _services.clear();
  }
}
