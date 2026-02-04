import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template_app/helpers/theme_manager.dart';
import 'package:template_app/pages/profile/profile_bloc.dart';
import 'package:template_app/pages/profile/profile_events_states.dart';
import 'package:template_app/values/colors.dart';
import 'package:template_app/widgets/profile_name.dart';
import 'package:template_app/widgets/profile_tile.dart';

class ShowProfileView extends StatelessWidget {
  const ShowProfileView({
    super.key,
    required this.context,
    required this.theme,
    required this.isLight,
  });

  final BuildContext context;
  final ThemeData theme;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Column(
          children: [
            // PROFILE CARD
            ProfileName(theme: theme, isLightMode: isLight),
            const SizedBox(height: 18),

            ProfileTile(
              context: context, 
              icon: Icons.article_outlined, 
              title: 'My Posts', 
              onTap: () {
                debugPrint('my posts');
              },
            ),

            const SizedBox(height: 12),
            ProfileTile(
              context: context, 
              icon: Icons.place_outlined, 
              title: 'My Visits',
              onTap: () {
                debugPrint('my visits');
              },
            ),
            const SizedBox(height: 12),
              
            ProfileTile(
              context: context, 
              icon: Icons.notifications_none, 
              title: 'Notifications',
              onTap: () {
                debugPrint('Notifications');
              },
            ),
            const SizedBox(height: 12),

            // ACCOUNT SETTINGS WITH THEME SWITCH
            ProfileTile(
              context: context, 
              icon: Icons.settings_outlined, 
              title: 'Account Settings',
              onTap: () {
                debugPrint('account settings');
              },
            ),

            // DARK/LIGHT MODE SWITCH
            themeSwitchWidget(),
            const SizedBox(height: 24),

            // LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.cardColor,
                  elevation: isLight ? 4 : 0,
                  shadowColor: isLight ? AppColors.lightShadow.color : null,
                ),
                onPressed: () {
                  context.read<ProfileBloc>().add(LogoutEvent(context: context));
                },
                child: Text(
                  'Log Out',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
