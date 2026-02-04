// EVENTS
abstract class LoginEvents {
  const LoginEvents();
}

class LoadLoginEvent extends LoginEvents {
  const LoadLoginEvent();
}

// STATES
abstract class LoginState {
  const LoginState();
}

class LoadingLoginState extends LoginState {
  const LoadingLoginState();
}

class ShowLoginState extends LoginState {
  const ShowLoginState();
}
