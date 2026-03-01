import 'package:flutter/cupertino.dart';

// EVENTS
abstract class LoginEvents {
  const LoginEvents();
}

class ContinueWithGoogleEvent extends LoginEvents {
  final BuildContext context;

  const ContinueWithGoogleEvent({required this.context});
}

class LoginState {
  final bool isSubmitting;
  final String? errorMessage;

  const LoginState({
    this.isSubmitting = false,
    this.errorMessage,
  });
}
