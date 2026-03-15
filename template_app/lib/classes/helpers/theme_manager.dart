import 'package:flutter/material.dart';
import 'package:template_app/classes/values/colors.dart';

String _fontFamily = 'Rubik';
double _appbarFontSize = 24;
FontWeight _appbarFontWeight = FontWeight.w600;

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
