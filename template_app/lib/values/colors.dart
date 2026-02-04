import 'package:flutter/material.dart';

class AppColors {
  static const Color accent = Color(0xFFFFD41D);
  static const Color primaryText = Color(0xFF0D0D0D);
  static const Color avatarPlaceholder = Color(0xFFD9D9D9);
   
  static const BoxShadow lightShadow = BoxShadow(
   color: Color.fromRGBO(0, 0, 0, 0.25),
    blurRadius: 4,
    offset: Offset(0, 4),
  );
  
  // Light mode
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightHeader = Color(0xFFFFFCF5);
  static const Color lightTile = Color(0xFFFFFCF5);
  static const Color lightCard = Color(0xFFFFFFFF);
  
  // Dark mode
  static const Color darkBackground = Color(0xFF111418);
  static const Color darkHeader = Color(0xFF1A1F26);
  static const Color darkTile = Color(0xFF1F2630);
  static const Color darkCard = Color(0xFF1F2630);
}
