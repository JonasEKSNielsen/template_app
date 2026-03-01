import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template_app/pages/login/login_bloc.dart';
import 'package:template_app/pages/login/login_events_states.dart';
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
      create: (_) => LoginBloc(),
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) => DefaultScaffold(
          title: 'Login',
          showTitle: true,
          child: Builder(
            builder: (context) {
              final isSubmitting = state.isSubmitting;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () {
                              context.read<LoginBloc>().add(
                                ContinueWithGoogleEvent(
                                  context: context,
                                ),
                              );
                            },
                      child: const Text('Continue with Google'),
                    ),
                    if (isSubmitting) ...[
                      const SizedBox(height: 14),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    if ((state.errorMessage ?? '').isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
