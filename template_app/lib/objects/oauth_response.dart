import 'oauth_user.dart';

class OAuthResponse {
  final String token;
  final String refreshToken;
  final DateTime expires;
  final OAuthUser user;

  OAuthResponse({
    required this.token,
    required this.refreshToken,
    required this.expires,
    required this.user,
  });

  factory OAuthResponse.fromJson(Map<String, dynamic> json) {
    return OAuthResponse(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      expires: DateTime.parse(json['expires'] as String),
      user: OAuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'expires': expires.toIso8601String(),
      'user': user.toJson(),
    };
  }
}
