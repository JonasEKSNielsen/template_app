import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

Future<Map<String, dynamic>?> loginWithGitHubPopup({
  required String clientId,
  required String redirectUri,
  required List<String> scopes,
}) async {
  final query = {
    'client_id': clientId,
    'redirect_uri': redirectUri,
    'scope': scopes.join(' '),
  };
  final authUrl = Uri.https('github.com', '/login/oauth/authorize', query);

  const width = 500;
  const height = 600;

  final screenLeft = html.window.screenLeft ?? 0;
  final screenTop = html.window.screenTop ?? 0;
  final outerWidth = html.window.outerWidth;
  final outerHeight = html.window.outerHeight;

  final left = screenLeft + ((outerWidth - width) / 2).round();
  final top = screenTop + ((outerHeight - height) / 2).round();

  final popupFeatures =
      'width=$width,height=$height,left=$left,top=$top,resizable=yes,scrollbars=yes';
  final popup = html.window.open(
    authUrl.toString(),
    'GitHub Login',
    popupFeatures,
  );

  final completer = Completer<Map<String, dynamic>?>();
  StreamSubscription<html.MessageEvent>? messageSubscription;
  Timer? closedPopupPoller;
  Timer? timeoutTimer;

  void cleanup() {
    timeoutTimer?.cancel();
    closedPopupPoller?.cancel();
    messageSubscription?.cancel();
  }

  messageSubscription = html.window.onMessage.listen((event) {
    final data = _toMap(event.data);
    if (data == null) {
      return;
    }

    final type = data['type']?.toString();
    if (type == 'github_oauth_success') {
      cleanup();
      popup.close();
      final authData = _toMap(data['data']);
      if (!completer.isCompleted) {
        completer.complete(authData);
      }
      return;
    }

    if (type == 'github_oauth_error') {
      cleanup();
      popup.close();
      final message = data['message']?.toString() ?? 'GitHub OAuth failed.';
      if (!completer.isCompleted) {
        completer.completeError(Exception(message));
      }
    }
  });

  closedPopupPoller = Timer.periodic(const Duration(milliseconds: 300), (_) {
    if (popup.closed == true && !completer.isCompleted) {
      cleanup();
      completer.complete(null);
    }
  });

  timeoutTimer = Timer(const Duration(minutes: 3), () {
    if (!completer.isCompleted) {
      cleanup();
      popup.close();
      completer.completeError(Exception('GitHub login timed out.'));
    }
  });

  return completer.future;
}

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, mapValue) => MapEntry('$key', mapValue));
  }

  if (value is String && value.isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, mapValue) => MapEntry('$key', mapValue));
      }
    } catch (_) {
      return null;
    }
  }

  return null;
}
