import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:template_app/classes/helpers/api.dart';
import 'package:template_app/classes/helpers/auth_storage.dart';
import 'package:template_app/classes/helpers/github_web_oauth.dart';
import 'package:template_app/classes/objects/api_path.dart';
import 'package:template_app/classes/objects/auth_user.dart';
import 'package:template_app/classes/objects/oauth_response.dart';
import 'package:template_app/classes/objects/oauth_user.dart';
import 'package:template_app/classes/helpers/sso_helper.dart';

enum OAuthProvider { google, github }

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

  static Future<AuthResult> loginWithProvider(OAuthProvider provider) async {
    switch (provider) {
      case OAuthProvider.google:
        return _authenticateWithGoogle();
      case OAuthProvider.github:
        return _authenticateWithGitHub();
    }
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
        return const AuthResult(
          success: false,
          errorMessage: 'google cancelled',
        );
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if ((idToken == null || idToken.isEmpty) &&
          (accessToken == null || accessToken.isEmpty)) {
        return const AuthResult(
          success: false,
          errorMessage: 'google no token',
        );
      }

      final response = await API.postRequest(ApiPath.authOAuthLogin, {
        'provider': 'Google',
        'accessToken': accessToken ?? '',
      });

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AuthResult(
          success: false,
          errorMessage: 'google backend failed ${response.statusCode}',
        );
      }

      final session = _sessionFromGoogleResponse(response.body, accessToken);
      if (session == null) {
        return const AuthResult(
          success: false,
          errorMessage: 'google bad response',
        );
      }

      await _persistSession(session);
      return const AuthResult(success: true);
    } catch (error) {
      return AuthResult(success: false, errorMessage: 'google failed $error');
    }
  }

  static Future<AuthResult> _authenticateWithGitHub() async {
    if (!GitHubConfig.isConfigured) {
      return const AuthResult(
        success: false,
        errorMessage: 'github not setup yet',
      );
    }

    if (kIsWeb) {
      return _authenticateWithGitHubWebPopup();
    }

    if (!GitHubConfig.backendExpectsAuthorizationCode) {
      return const AuthResult(
        success: false,
        errorMessage: 'github setup not done yet',
      );
    }

    try {
      final state = _generateOAuthState();
      final authUri = Uri.https('github.com', '/login/oauth/authorize', {
        'client_id': GitHubConfig.clientId,
        'redirect_uri': GitHubConfig.redirectUri,
        'scope': GitHubConfig.authorizeScopes.join(' '),
        'state': state,
      });

      final callbackUrl = await FlutterWebAuth2.authenticate(
        url: authUri.toString(),
        callbackUrlScheme: GitHubConfig.callbackScheme,
      );

      final callbackUri = Uri.parse(callbackUrl);
      final returnedState = callbackUri.queryParameters['state'] ?? '';
      if (returnedState != state) {
        return const AuthResult(
          success: false,
          errorMessage: 'github state not matching',
        );
      }

      final providerError = callbackUri.queryParameters['error'];
      if (providerError != null && providerError.isNotEmpty) {
        final providerErrorDescription =
            callbackUri.queryParameters['error_description'];
        return AuthResult(
          success: false,
          errorMessage:
              'github error ${providerErrorDescription ?? providerError}',
        );
      }

      final authorizationCode = callbackUri.queryParameters['code'] ?? '';
      if (authorizationCode.isEmpty) {
        return const AuthResult(success: false, errorMessage: 'github no code');
      }

      final response = await API.postRequest(ApiPath.authOAuthLogin, {
        'provider': 'GitHub',
        'accessToken': authorizationCode,
        'redirectUri': GitHubConfig.redirectUri,
      });

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AuthResult(
          success: false,
          errorMessage: 'github backend failed ${response.statusCode}',
        );
      }

      final session = _sessionFromGoogleResponse(response.body, null);
      if (session == null) {
        return const AuthResult(
          success: false,
          errorMessage: 'github bad response',
        );
      }

      await _persistSession(session);
      return const AuthResult(success: true);
    } catch (error) {
      return AuthResult(success: false, errorMessage: 'github failed $error');
    }
  }

  static Future<AuthResult> _authenticateWithGitHubWebPopup() async {
    try {
      final authData = await loginWithGitHubPopup(
        clientId: GitHubConfig.clientId,
        redirectUri: GitHubConfig.redirectUri,
        scopes: GitHubConfig.authorizeScopes,
      );

      if (authData == null) {
        return const AuthResult(
          success: false,
          errorMessage: 'github cancelled',
        );
      }

      final session = _sessionFromDecodedPayload(authData, null);
      if (session == null) {
        return const AuthResult(
          success: false,
          errorMessage: 'github callback bad response',
        );
      }

      await _persistSession(session);
      return const AuthResult(success: true);
    } catch (error) {
      return AuthResult(success: false, errorMessage: 'github failed $error');
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

      return _sessionFromDecodedPayload(decoded, fallbackAccessToken);
    } catch (_) {
      return null;
    }
  }

  static OAuthResponse? _sessionFromDecodedPayload(
    Map<String, dynamic> decoded,
    String? fallbackAccessToken,
  ) {
    try {
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
    } catch (exception) {
      return null;
    }
  }

  static Future<void> _persistSession(OAuthResponse session) async {
    await AuthStorage.saveSession(session);
    API.setAuthHeader(session.token);
  }

  static String _generateOAuthState([int length = 32]) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
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
