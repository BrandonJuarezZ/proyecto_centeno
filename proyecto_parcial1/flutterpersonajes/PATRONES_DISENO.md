# Refactorización del Proyecto Flutter - Patrones de Diseño

## 📋 Resumen de la Refactorización

Se ha refactorizado completamente el proyecto Flutter "Personajes Videojuegos" implementando múltiples patrones de diseño para mejorar la arquitectura, mantenibilidad y escalabilidad del código.

---

## 🏗️ Patrones de Diseño Implementados

### 1. **Singleton Pattern** ✅
**Archivos:** `AuthService.dart`, `PersonajeService.dart`, `NetworkClient.dart`, `AppStateManager.dart`

```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
}
```

**Beneficios:**
- Garantiza una única instancia en toda la aplicación
- Gestión centralizada de recursos (HTTP client, estado)
- Thread-safe en operaciones concurrentes

---

### 2. **Service Locator Pattern** ✅
**Archivo:** `core/service_locator.dart`

```dart
ServiceLocator().get<PersonajeService>('personajeService');
ServiceLocator().get<AuthService>('authService');
```

**Beneficios:**
- Inyección de dependencias sin frameworks externos
- Gestión centralizada de todas las dependencias
- Facilita testing y mockeo
- Desacoplamiento entre componentes

---

### 3. **Builder Pattern** ✅
**Archivo:** `builders/personaje_builder.dart`

```dart
PersonajeBuilder builder = PersonajeBuilder()
  .withNombre('Mario')
  .withVideojuego('Super Mario Bros')
  .withDescripcion('El héroe de Nintendo')
  .build();
```

**Beneficios:**
- Construcción segura de objetos complejos
- Validación en tiempo de compilación
- Código más legible y fluido
- Previene objetos incompletos

---

### 4. **Factory Method Pattern** ✅
**Archivos:** `PersonajeService.dart`, `Personaje.dart`, `PersonajeBuilder.dart`

```dart
// Factory Constructor
factory Personaje.fromJson(Map<String, dynamic> json) {
  return Personaje(
    id: json['id'] ?? 0,
    nombre: json['nombre'] ?? '',
    // ...
  );
}

// Factory Method
Personaje _createPersonajeFromJson(Map<String, dynamic> json) {
  return PersonajeBuilder.fromJson(json).build();
}
```

**Beneficios:**
- Encapsulación de la lógica de creación
- Flexibilidad para cambiar implementaciones
- Parsing consistente desde diferentes fuentes

---

### 5. **Repository Pattern** ✅
**Archivos:** `repositories/PersonajeRepository.dart`, `services/PersonajeService.dart`

```dart
abstract class IPersonajeRepository {
  Future<List<Personaje>> fetchPersonajes();
  Future<Personaje> createPersonaje(...);
  Future<void> deletePersonaje(int id);
  Future<Personaje> updatePersonaje(Personaje personaje);
  Future<Personaje?> getPersonajeById(int id);
  Future<List<Personaje>> searchByVideojuego(String videojuego);
}
```

**Beneficios:**
- Abstracción de la fuente de datos
- Interfaz consistente para operaciones
- Facilita testing con mocks
- Permite cambiar implementación sin afectar UI

---

### 6. **Custom Exception Pattern** ✅
**Archivos:** `AuthService.dart`, `PersonajeService.dart`

```dart
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

class PersonajeException implements Exception {
  final String message;
  PersonajeException(this.message);
}
```

**Beneficios:**
- Manejo de errores específico y controlado
- Stack traces claros para debugging
- Diferenciación entre tipos de error

---

### 7. **Observer Pattern** ✅
**Archivo:** `core/app_state.dart`

```dart
class AppStateManager {
  final List<Function(AppState)> _listeners = [];
  
  void addListener(Function(AppState) listener) {
    _listeners.add(listener);
  }
  
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_currentState);
    }
  }
}
```

**Beneficios:**
- Notificación automática de cambios de estado
- Componentes pueden reaccionar a eventos
- Bajo acoplamiento

---

### 8. **Template Method Pattern** ✅
**Archivo:** `PersonajeService.dart`

```dart
// Métodos con estructura similar
Future<Personaje> createPersonaje(...) { ... }
Future<Personaje> updatePersonaje(Personaje personaje) { ... }
```

**Beneficios:**
- Consistencia en operaciones similares
- Reutilización de lógica común
- Código más predecible

---

### 9. **Strategy Pattern** ✅
**Archivo:** `PersonajeService.dart`

```dart
List<Personaje> _parsePersonajeResponse(dynamic jsonData) {
  if (jsonData is Map && jsonData.containsKey('content')) {
    // Estrategia: respuesta paginada
    return PersonajeResponse.fromJson(jsonData).content;
  } else if (jsonData is List) {
    // Estrategia: lista directa
    return (jsonData as List).map(...).toList();
  }
  return [];
}
```

**Beneficios:**
- Adaptación a diferentes formatos de respuesta
- Flexible ante cambios en API
- Fácil de extender con nuevas estrategias

---

### 10. **Specification Pattern** ✅
**Archivo:** `PersonajeService.dart`

```dart
// Búsqueda por especificación (ID)
Future<Personaje?> getPersonajeById(int id) async { ... }

// Búsqueda por videojuego
Future<List<Personaje>> searchByVideojuego(String videojuego) async { ... }
```

**Beneficios:**
- Consultas complejas encapsuladas
- Composable y reutilizable
- Claridad en la intención de búsqueda

---

### 11. **Value Object Pattern** ✅
**Archivo:** `models/Personaje.dart`

```dart
class Personaje {
  final int id;
  final String nombre;
  // ... todos immutables
  
  const Personaje({ ... });
  
  @override
  bool operator ==(Object other) => /* comparación */;
  
  @override
  int get hashCode => /* hash */;
  
  Personaje copyWith({ ... }) { ... }
}
```

**Beneficios:**
- Objetos inmutables y predecibles
- Comparación por valor
- Seguridad en programación funcional

---

### 12. **Composite Pattern** ✅
**Archivo:** `main.dart` - `_PersonajeCard`

```dart
class _PersonajeCard extends StatelessWidget {
  // Compone UI de un personaje
  // Reutilizable en listas
}
```

**Beneficios:**
- Composición de UI escalable
- Reutilización de componentes
- Separación de responsabilidades

---

### 13. **Validation Pattern** ✅
**Archivo:** `screens/SignupScreen.dart`

```dart
String? _validateForm() {
  if (_usernameController.text.isEmpty) {
    return 'Por favor completa todos los campos';
  }
  if (!_emailController.text.contains('@')) {
    return 'Por favor ingresa un email válido';
  }
  // ... más validaciones
  return null;
}
```

**Beneficios:**
- Lógica de validación centralizada
- Mensajes de error consistentes
- Fácil de mantener y extender

---

## 📂 Estructura de Carpetas

```
lib/
├── main.dart                      # Punto de entrada
├── core/
│   ├── network_client.dart        # Singleton - Cliente HTTP centralizado
│   ├── service_locator.dart       # Service Locator - Inyección de dependencias
│   ├── app_state.dart             # AppStateManager - Gestión de estado global
├── builders/
│   └── personaje_builder.dart     # Builder Pattern
├── models/
│   ├── Personaje.dart             # Value Object + Factory Method
│   ├── User.dart
│   ├── LoginRequest.dart
│   └── ...
├── repositories/
│   └── PersonajeRepository.dart   # Repository Pattern Interface
├── services/
│   ├── AuthService.dart           # Singleton + Exception Pattern
│   └── PersonajeService.dart      # Singleton + Repository + Factory + Strategy
├── screens/
│   ├── LoginScreen.dart           # Validación + Service Locator
│   └── SignupScreen.dart          # Validación + Service Locator
```

---

## 🔄 Flujo de Dependencias

```
main.dart
  ↓
ServiceLocator (inicializa)
  ├── NetworkClient (Singleton)
  ├── AuthService (Singleton)
  └── PersonajeService (Singleton)
       ↓
LoginScreen/SignupScreen → AuthService → NetworkClient
HomeScreen → PersonajeService → NetworkClient
```

---

## 💡 Beneficios de la Refactorización

✅ **Mantenibilidad:** Código modular y bien organizado  
✅ **Testabilidad:** Fácil de mockear y probar  
✅ **Escalabilidad:** Fácil agregar nuevas características  
✅ **Reusabilidad:** Componentes reutilizables  
✅ **Legibilidad:** Código autodocumentado  
✅ **Flexibilidad:** Fácil de cambiar implementaciones  
✅ **Desacoplamiento:** Componentes independientes  
✅ **Consistencia:** Patrones aplicados uniformemente  

---

## 🚀 Cómo Usar la Refactorización

### Agregar un nuevo servicio

```dart
// 1. Crear interfaz
abstract class INewRepository { ... }

// 2. Implementar con Singleton + Factory
class NewService implements INewRepository {
  static final NewService _instance = NewService._internal();
  factory NewService() => _instance;
  NewService._internal();
}

// 3. Registrar en ServiceLocator
_services['newService'] = NewService();

// 4. Usar en widgets
late NewService _service;
@override
void initState() {
  _service = ServiceLocator().get<NewService>('newService');
}
```

### Crear un nuevo modelo

```dart
// 1. Usar Value Object Pattern
class MyModel {
  final int id;
  final String name;
  
  const MyModel({ required this.id, required this.name });
  
  // Factory Method
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(id: json['id'], name: json['name']);
  }
  
  // Builder helper
  MyModel copyWith({ int? id, String? name }) {
    return MyModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

// 2. Usar Builder para construcción compleja
MyBuilder builder = MyBuilder()
  .withId(1)
  .withName('Test')
  .build();
```

---

## 📚 Referencias de Patrones

- **Singleton:** Garantiza una única instancia
- **Service Locator:** Inyección de dependencias
- **Builder:** Construcción de objetos complejos
- **Factory Method:** Creación de objetos
- **Repository:** Abstracción de datos
- **Observer:** Notificación de cambios
- **Strategy:** Diferentes algoritmos
- **Value Object:** Objetos inmutables

---

## ✨ Próximas Mejoras Posibles

- [ ] Implementar Provider para state management más avanzado
- [ ] Agregar Bloc Pattern para lógica de negocio
- [ ] Implementar Caching Strategy
- [ ] Agregar interceptores de requests
- [ ] Implementar Pagination Strategy
- [ ] Agregar Local Storage con Repository Pattern
- [ ] Implementar Error Boundary Pattern

---

**Fecha de Refactorización:** 24 de abril de 2026  
**Versión:** 1.0.0  
**Estado:** ✅ Completada
