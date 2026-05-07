import 'Personaje.dart';

class PersonajeResponse {
  final List<Personaje> content;

  PersonajeResponse({required this.content});

  factory PersonajeResponse.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];

    return PersonajeResponse(
      content: contentList
          .map((p) => Personaje.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}