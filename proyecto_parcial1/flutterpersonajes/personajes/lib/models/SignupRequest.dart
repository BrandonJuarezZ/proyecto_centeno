class SignupRequest {
  final String username;
  final String email;
  final String password;
  final Set<String> role;

  SignupRequest({
    required this.username,
    required this.email,
    required this.password,
    this.role = const {'user'},
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'role': role.toList(),
    };
  }
}
