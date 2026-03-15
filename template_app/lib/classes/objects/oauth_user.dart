class OAuthUser {
  final int id;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;
  final String picture;

  OAuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.picture,
  });

  factory OAuthUser.fromJson(Map<dynamic, dynamic> json) {
    return OAuthUser(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      picture: json['picture'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'picture': picture,
    };
  }
}
