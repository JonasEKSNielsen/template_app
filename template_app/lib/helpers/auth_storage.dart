import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:template_app/objects/oauth_response.dart';

abstract class AuthStorage {
  static const _storage = FlutterSecureStorage();
  static const _oauthSessionKey = 'oauth_session';
  static const _accessTokenKey = 'oauth_access_token';

  static Future<void> saveSession(OAuthResponse session) async {
    await _storage.write(
      key: _oauthSessionKey,
      value: jsonEncode(session.toJson()),
    );
    await _storage.write(key: _accessTokenKey, value: session.token);
  }

  static Future<OAuthResponse?> getSession() async {
    final raw = await _storage.read(key: _oauthSessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      return OAuthResponse.fromJson(payload);
    } catch (_) {
      await clear();
      return null;
    }
  }

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<String> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey) ?? '';
  }

  static Future<bool> hasValidSession() async {
    final session = await getSession();
    if (session == null) {
      return false;
    }
    return session.expires.isAfter(DateTime.now().toUtc());
  }

  static Future<void> clear() async {
    await _storage.delete(key: _oauthSessionKey);
    await _storage.delete(key: _accessTokenKey);
  }
}
