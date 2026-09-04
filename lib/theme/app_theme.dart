import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF5F6FA);
  static const Color primary = Color(0xFF3D5AFE);
  static const Color primaryDark = Color(0xFF2743D6);
  static const Color gold = Color(0xFFF5A623);
  static const Color flame = Color(0xFFFF6B4A);
  static const Color cardTeal = Color(0xFF1D7A8C);
  static const Color cardTealDark = Color(0xFF14515E);
  static const Color cardPurple = Color(0xFF3B2A6B);
  static const Color cardPurpleDark = Color(0xFF1F1640);
  static const Color cardGreen = Color(0xFF3E8E5A);
  static const Color cardGreenDark = Color(0xFF255C39);
  static const Color textDark = Color(0xFF1B1D28);
  static const Color textMuted = Color(0xFF8A8D9B);
  static const Color danger = Color(0xFFE4574C);
  static const Color success = Color(0xFF3EAE6A);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(primary: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      foregroundColor: AppColors.textDark,
      surfaceTintColor: Colors.transparent,
    ),
    splashFactory: InkRipple.splashFactory,
  );
}

ThemeData buildAppDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  );
  const darkBg = Color(0xFF14161F);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(primary: AppColors.primary),
    scaffoldBackgroundColor: darkBg,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    splashFactory: InkRipple.splashFactory,
  );
}
