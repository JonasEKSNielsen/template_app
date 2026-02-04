import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template_app/pages/login/login_events_states.dart';

class LoginBloc extends Bloc<LoginEvents, LoginState> {
  LoginBloc() : super(const LoadingLoginState()) {
    on<LoadLoginEvent>(_onLoad);
  }

  void _onLoad(LoadLoginEvent event, Emitter<LoginState> emit) async {
    emit(const LoadingLoginState());
    await Future.delayed(const Duration(milliseconds: 200));
    emit(const ShowLoginState());
  }
}
