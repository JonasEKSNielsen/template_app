import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template_app/classes/helpers/auth_service.dart';
import 'package:template_app/classes/helpers/general_util.dart';
import 'package:template_app/pages/login/login_events_states.dart';
import 'package:template_app/pages/map/map_page.dart';

class LoginBloc extends Bloc<LoginEvents, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<ContinueWithGoogleEvent>(_onContinueWithGoogle);
    on<ContinueWithGitHubEvent>(_onContinueWithGitHub);
  }

  void _onContinueWithGoogle(
    ContinueWithGoogleEvent event,
    Emitter<LoginState> emit,
  ) async {
    await _authenticate(event.context, emit, OAuthProvider.google);
  }

  void _onContinueWithGitHub(
    ContinueWithGitHubEvent event,
    Emitter<LoginState> emit,
  ) async {
    await _authenticate(event.context, emit, OAuthProvider.github);
  }

  Future<void> _authenticate(
    BuildContext context,
    Emitter<LoginState> emit,
    OAuthProvider provider,
  ) async {
    emit(const LoginState(isSubmitting: true));

    final result = await AuthService.loginWithProvider(provider);

    if (result.success) {
      if (!context.mounted) {
        return;
      }
      await GeneralUtil.goToPage(context, const MapPage());
      return;
    }

    emit(LoginState(errorMessage: result.errorMessage));
  }
}
