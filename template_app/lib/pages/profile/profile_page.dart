import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template_app/pages/profile/profile_bloc.dart';
import 'package:template_app/pages/profile/profile_events_states.dart';
import 'package:template_app/pages/profile/views/show_profile_view.dart';
import 'package:template_app/widgets/default_scaffold.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => ProfileBloc()..add(const LoadProfileEvent()),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) => DefaultScaffold(
          title: 'Profile',
          showTitle: true,
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final isLight = theme.brightness == Brightness.light;


              switch (state.runtimeType) {
                case const (ShowProfileState):
                  return ShowProfileView(context: context, theme: theme, isLight: isLight);

                default:
                  return ShowProfileView(context: context, theme: theme, isLight: isLight);
              }
            }
          ),
        ),
      ),
    );
  }
}
