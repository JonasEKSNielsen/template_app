import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template_app/helpers/general_util.dart';
import 'package:template_app/objects/TEMPLATE.dart';
import 'package:template_app/pages/login/login_page.dart';
import 'package:template_app/pages/profile/profile_events_states.dart';

class ProfileBloc extends Bloc<ProfileEvents, ProfileState> {
  ProfileBloc() : super(const LoadingProfileState()) {
    on<LoadProfileEvent>(_onLoad);
    on<LogoutEvent>(_onLogout);
  }

  void _onLoad(LoadProfileEvent event, Emitter<ProfileState> emit) async {
    emit(const LoadingProfileState());
    // TODO: GET DATA
    await Future.delayed(const Duration(milliseconds: 200));
    emit(ShowProfileState(profile: TEMPLATE()));
  }

  void _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    // TODO: CLEAR ALL SECURE STORAGE SHIT AND LEAVE
    GeneralUtil.goToPage(event.context, const LoginPage(), goBack: true);
  }
}
