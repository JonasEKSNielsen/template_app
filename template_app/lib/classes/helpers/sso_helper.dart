import 'package:template_app/classes/helpers/api.dart';

class GoogleConfig {
  static const String webClientId =
      '651368027146-3afigsduknudq3b8vpm1gvja3dq3qabc.apps.googleusercontent.com';
}

class GitHubConfig {
  static const String clientId = 'Ov23linxO6LUkaNaBIh9';

  static String get apiBaseUrl => API.apiBaseUrl;

  static String get redirectUri => '$apiBaseUrl/api/auth/github/callback';

  static const String callbackScheme = 'templateapp';

  static const List<String> authorizeScopes = ['user:email'];

  static const bool backendExpectsAuthorizationCode = true;

  static bool get isConfigured =>
      clientId.isNotEmpty &&
      callbackScheme.isNotEmpty &&
      redirectUri.isNotEmpty;
}
