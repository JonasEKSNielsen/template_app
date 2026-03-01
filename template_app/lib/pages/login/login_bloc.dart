import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template_app/helpers/auth_service.dart';
import 'package:template_app/helpers/general_util.dart';
import 'package:template_app/pages/login/login_events_states.dart';
import 'package:template_app/pages/map/map_page.dart';

class LoginBloc extends Bloc<LoginEvents, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<ContinueWithGoogleEvent>(_onContinueWithGoogle);
  }

  void _onContinueWithGoogle(
    ContinueWithGoogleEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginState(isSubmitting: true));

    final result = await AuthService.loginWithProvider(OAuthProvider.google);

    if (result.success) {
      if (!event.context.mounted) {
        return;
      }
      await GeneralUtil.goToPage(event.context, const MapPage());
      return;
    }

    emit(LoginState(errorMessage: result.errorMessage));
  }
}
