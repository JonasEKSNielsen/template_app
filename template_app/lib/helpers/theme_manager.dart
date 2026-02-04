import 'package:flutter/material.dart';
import 'package:template_app/values/colors.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

String _fontFamily = 'Rubik';
double _appbarFontSize = 24;
FontWeight _appbarFontWeight = FontWeight.w600;

void toggleTheme() {
  themeNotifier.value = themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    fontFamily: _fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightHeader,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.primaryText,
        fontSize: _appbarFontSize,
        fontWeight: _appbarFontWeight,
      ),
    ),
    cardColor: AppColors.lightCard,
    listTileTheme: const ListTileThemeData(
      tileColor: AppColors.lightTile,
      iconColor: AppColors.primaryText,
      textColor: AppColors.primaryText,
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: _fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkHeader,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: _appbarFontSize,
        fontWeight: _appbarFontWeight,
      ),
    ),
    cardColor: AppColors.darkCard,
    listTileTheme: const ListTileThemeData(
      tileColor: AppColors.darkTile,
      iconColor: Colors.white,
      textColor: Colors.white,
    ),
  );
}

Widget themeSwitchWidget() {
  return ValueListenableBuilder<ThemeMode>(
    valueListenable: themeNotifier,
    builder: (context, mode, _) {
      final isDark = mode == ThemeMode.dark;
      return Switch(
        value: isDark,
        onChanged: (_) => toggleTheme(),
      );
    },
  );
}

