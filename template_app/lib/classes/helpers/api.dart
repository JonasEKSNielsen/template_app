import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:template_app/classes/helpers/auth_storage.dart';
import '../objects/api_path.dart';

class API {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL_HTTPS',
    defaultValue: 'https://localhost:7258',
  );

  static const String _baseUrl = '$apiBaseUrl/api/';

  static final Map<String, String> _headers = {};

  static Map<String, String> _jsonHeaders() {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ..._headers,
    };
  }

  static Future<void> _applyAuthHeader() async {
    final accessToken = await AuthStorage.getAccessToken();
    if (accessToken.isNotEmpty) {
      _headers['Authorization'] = 'Bearer $accessToken';
    }
  }

  static Future<http.Response> _attemptApiWithRefresh(
    Future<http.Response> Function() apiCall,
    Function(http.Response)? onSuccess, {
    bool skipRefresh = false,
  }) async {
    var response = await apiCall();

    if (!skipRefresh && response.statusCode == 401) {
      final refreshSuccess = await _tryToRefreshToken();
      if (refreshSuccess) {
        response = await apiCall();
      }
    }

    if (onSuccess != null) {
      onSuccess(response);
    }
    return response;
  }

  static Future<bool> _tryToRefreshToken() async {
    await AuthStorage.clear();
    _headers.remove('Authorization');
    return false;
  }

  static Uri buildUri(
    ApiPath action, {
    String? id,
    Map<String, String>? queryParameters,
  }) {
    final suffix = id == null ? action.value : '${action.value}/$id';

    final uri = Uri.parse('$_baseUrl$suffix');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: queryParameters);
  }

  // Get Request
  static Future<http.Response> getRequest(ApiPath action) async {
    await _applyAuthHeader();

    return _attemptApiWithRefresh(
      () => http.get(
        buildUri(action),
        headers: {'Accept': 'application/json', ..._headers},
      ),
      null,
    );
  }

  // Get Request
  static Future<http.Response> getRequestWithId(
    ApiPath action,
    String id,
  ) async {
    await _applyAuthHeader();

    return _attemptApiWithRefresh(
      () => http.get(
        buildUri(action, id: id),
        headers: {'Accept': 'application/json', ..._headers},
      ),
      null,
    );
  }

  // Post Request
  static Future<http.Response> postRequest(
    ApiPath action,
    Object? body, {
    bool? isRefresh,
  }) async {
    if (isRefresh ?? false) {
      _headers.remove('Authorization');
    } else {
      await _applyAuthHeader();
    }

    return _attemptApiWithRefresh(
      () => http.post(
        buildUri(action),
        headers: _jsonHeaders(),
        body: body == null ? null : jsonEncode(body),
      ),
      null,
    );
  }

  // Post Request
  static Future<http.Response> postRequestWithId(
    ApiPath action,
    String id,
    Object? body, {
    bool skipRefresh = false,
  }) async {
    await _applyAuthHeader();

    return _attemptApiWithRefresh(
      () => http.post(
        buildUri(action, id: id),
        headers: _jsonHeaders(),
        body: body == null ? null : jsonEncode(body),
      ),
      null,
      skipRefresh: skipRefresh,
    );
  }

  // Put Request
  static Future<http.Response> putRequest(ApiPath action, Object? body) async {
    await _applyAuthHeader();

    return _attemptApiWithRefresh(
      () => http.put(
        buildUri(action),
        headers: _jsonHeaders(),
        body: body == null ? null : jsonEncode(body),
      ),
      null,
    );
  }

  // Put Request
  static Future<http.Response> putRequestWithId(
    ApiPath action,
    String id,
    Object? body,
  ) async {
    await _applyAuthHeader();

    return _attemptApiWithRefresh(
      () => http.put(
        buildUri(action, id: id),
        headers: _jsonHeaders(),
        body: body == null ? null : jsonEncode(body),
      ),
      null,
    );
  }

  // Patch Request
  static Future<http.Response> patchRequest(
    ApiPath action,
    Object? body,
  ) async {
    await _applyAuthHeader();

    return _attemptApiWithRefresh(
      () => http.patch(
        buildUri(action),
        headers: _jsonHeaders(),
        body: body == null ? null : jsonEncode(body),
      ),
      null,
    );
  }

  // Patch Request
  static Future<http.Response> patchRequestWithId(
    ApiPath action,
    String id,
    Object? body, {
    bool skipRefresh = false,
  }) async {
    await _applyAuthHeader();

    return _attemptApiWithRefresh(
      () => http.patch(
        buildUri(action, id: id),
        headers: _jsonHeaders(),
        body: body == null ? null : jsonEncode(body),
      ),
      null,
      skipRefresh: skipRefresh,
    );
  }

  // Delete Request
  static Future<http.Response> deleteRequest(ApiPath action) async {
    await _applyAuthHeader();

    return _attemptApiWithRefresh(
      () => http.delete(
        buildUri(action),
        headers: {'Accept': 'application/json', ..._headers},
      ),
      null,
    );
  }

  // Delete Request
  static Future<http.Response> deleteRequestWithId(
    ApiPath action,
    String id,
  ) async {
    await _applyAuthHeader();

    return _attemptApiWithRefresh(
      () => http.delete(
        buildUri(action, id: id),
        headers: {'Accept': 'application/json', ..._headers},
      ),
      null,
    );
  }

  static void setAuthHeader(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthHeader() {
    _headers.remove('Authorization');
  }
}
