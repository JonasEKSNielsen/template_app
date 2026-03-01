import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:template_app/helpers/api.dart';
import 'package:template_app/helpers/auth_storage.dart';
import 'package:template_app/objects/api_path.dart';
import 'package:template_app/objects/auth_user.dart';
import 'package:template_app/objects/oauth_response.dart';
import 'package:template_app/objects/oauth_user.dart';
import 'package:template_app/classes/helpers/sso_helper.dart';

// TODO: ADD GITHUB
enum OAuthProvider { google }

class AuthResult {
  final bool success;
  final String? errorMessage;

  const AuthResult({required this.success, this.errorMessage});
}

abstract class AuthService {
  static Future<void> bootstrap() async {
    final hasValidSession = await AuthStorage.hasValidSession();
    if (!hasValidSession) {
      API.clearAuthHeader();
      await AuthStorage.clear();
      return;
    }

    final session = await AuthStorage.getSession();
    if (session != null && session.token.isNotEmpty) {
      API.setAuthHeader(session.token);
      return;
    }

    final accessToken = await AuthStorage.getAccessToken();
    if (accessToken.isNotEmpty) {
      API.setAuthHeader(accessToken);
    }
  }

  static Future<bool> hasSession() async {
    if (await AuthStorage.hasValidSession()) {
      return true;
    }
    final accessToken = await AuthStorage.getAccessToken();
    return accessToken.isNotEmpty;
  }

  static Future<AuthResult> loginWithProvider(OAuthProvider provider) {
    return _authenticate(provider);
  }

  static Future<AuthResult> _authenticate(
    OAuthProvider provider,
  ) async {
    return _authenticateWithGoogle();
  }

  static Future<AuthResult> _authenticateWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: GoogleConfig.webClientId,
        scopes: const ['email', 'profile'],
      );

      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        return const AuthResult(success: false, errorMessage: 'Google login cancelled.');
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if ((idToken == null || idToken.isEmpty) &&
          (accessToken == null || accessToken.isEmpty)) {
        return const AuthResult(
          success: false,
          errorMessage: 'Google did not return usable tokens.',
        );
      }

      final response = await API.postRequest(
        ApiPath.authOAuthLogin,
        {
          'provider': 'Google',
          'accessToken': accessToken ?? '',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AuthResult(
          success: false,
          errorMessage:
              'Google login failed on backend (${response.statusCode}) at /api/auth/oauth-login.',
        );
      }

      final session = _sessionFromGoogleResponse(response.body, accessToken);
      if (session == null) {
        return const AuthResult(
          success: false,
          errorMessage:
              'Google login failed: backend response format was unexpected.',
        );
      }

      await _persistSession(session);
      return const AuthResult(success: true);
    } catch (error) {
      return AuthResult(
        success: false,
        errorMessage: 'Google login failed: $error',
      );
    }
  }

  static OAuthResponse? _sessionFromGoogleResponse(
    String body,
    String? fallbackAccessToken,
  ) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      if (decoded.containsKey('token') &&
          decoded.containsKey('refreshToken') &&
          decoded.containsKey('expires') &&
          decoded.containsKey('user')) {
        return OAuthResponse.fromJson(decoded);
      }

      final token =
          (decoded['access_token'] ?? decoded['token'] ?? fallbackAccessToken)
              ?.toString() ??
          '';
      if (token.isEmpty) {
        return null;
      }

      final refreshToken = (decoded['refresh_token'] ?? '').toString();
      final expires = _parseExpiry(decoded['expires']?.toString());
      final user = _parseUser(
        decoded['user'] is String
            ? decoded['user'] as String
            : jsonEncode(decoded['user'] ?? {}),
      );

      return OAuthResponse(
        token: token,
        refreshToken: refreshToken,
        expires: expires,
        user: user,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> _persistSession(OAuthResponse session) async {
    await AuthStorage.saveSession(session);
    API.setAuthHeader(session.token);
  }

  static DateTime _parseExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.now().toUtc().add(const Duration(days: 7));
    }

    try {
      return DateTime.parse(value).toUtc();
    } catch (_) {
      return DateTime.now().toUtc().add(const Duration(days: 7));
    }
  }

  static OAuthUser _parseUser(String? rawUser) {
    if (rawUser == null || rawUser.isEmpty) {
      return OAuthUser(
        id: 0,
        username: '',
        email: '',
        role: '',
        createdAt: DateTime.now().toUtc(),
        picture: '',
      );
    }

    try {
      final decoded = jsonDecode(rawUser) as Map<String, dynamic>;
      return OAuthUser.fromJson(decoded);
    } catch (_) {
      return OAuthUser(
        id: 0,
        username: '',
        email: '',
        role: '',
        createdAt: DateTime.now().toUtc(),
        picture: '',
      );
    }
  }

  static Future<AuthUser?> getCurrentUser() async {
    final response = await API.getRequest(ApiPath.me);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthUser.fromJson(body);
  }

  static Future<void> logout() async {
    try {
      await API.postRequest(ApiPath.logout, null);
    } catch (_) {}

    API.clearAuthHeader();
    await AuthStorage.clear();
  }
}
