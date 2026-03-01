import 'package:flutter/material.dart';
import 'package:template_app/helpers/auth_service.dart';
import 'package:template_app/helpers/theme_manager.dart';
import 'package:template_app/pages/login/login_page.dart';
import 'package:template_app/pages/map/map_page.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.bootstrap();
  final hasSession = await AuthService.hasSession();
  runApp(MyApp(hasSession: hasSession));
}

class MyApp extends StatelessWidget {
  final bool hasSession;

  const MyApp({super.key, required this.hasSession});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: mode,
          home: hasSession ? const MapPage() : const LoginPage(),
        );
      },
    );
  }
}
