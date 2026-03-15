// Name all paths
enum ApiPath {
  authOAuthLogin,
  me,
  logout,
}

// Specify the string needed for each path. Avoids accidental misspellings and ensures consistency
extension PathExtension on ApiPath {
  String get value => switch (this) {
    ApiPath.authOAuthLogin => 'auth/oauth-login',
    ApiPath.me => 'auth/me',
    ApiPath.logout => 'auth/logout',
  };
}
