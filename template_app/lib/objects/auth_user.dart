class AuthUser {
  final String id;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String provider;

  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.provider,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final name = json['displayName']?.toString() ?? json['name']?.toString() ?? '';
    final avatar =
        json['avatarUrl']?.toString() ?? json['base64Pfp']?.toString() ?? '';

    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: name,
      avatarUrl: avatar,
      provider: json['provider']?.toString() ?? 'local',
    );
  }
}
