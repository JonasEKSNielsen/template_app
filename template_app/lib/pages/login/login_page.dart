import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template_app/helpers/general_util.dart';
import 'package:template_app/pages/login/login_bloc.dart';
import 'package:template_app/pages/login/login_events_states.dart';
import 'package:template_app/pages/profile/profile_page.dart';
import 'package:template_app/widgets/default_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => LoginBloc()..add(const LoadLoginEvent()),
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) => DefaultScaffold(
          title: 'Login',
          showTitle: true,
          child: Builder(
            builder: (context) {
              switch (state.runtimeType) {
                case const (ShowLoginState):
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          GeneralUtil.goToPage(context, const ProfilePage());
                        }, 
                        child: const Text('Min Profil'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          GeneralUtil.goToPage(context, const ProfilePage());
                        }, 
                        child: const Text('Login med Github'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          GeneralUtil.goToPage(context, const ProfilePage());
                        }, 
                        child: const Text('Login med Google'),
                      ),
                    ],
                  );

                default:
                  return const Text('Loading');
              }
            }
          ),
        ),
      ),
    );
  }
}
