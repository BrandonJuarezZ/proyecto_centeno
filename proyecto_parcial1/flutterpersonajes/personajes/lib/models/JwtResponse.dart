class JwtResponse {
  final String token;
  final String type;
  final int id;
  final String username;
  final String email;
  final List<String> roles;

  JwtResponse({
    required this.token,
    required this.type,
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
  });

  factory JwtResponse.fromJson(Map<String, dynamic> json) {
    return JwtResponse(
      token: json['accessToken'] ?? json['token'] ?? '',
      type: json['tokenType'] ?? json['type'] ?? 'Bearer',
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
      'id': id,
      'username': username,
      'email': email,
      'roles': roles,
    };
  }
}
