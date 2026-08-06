import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF8F94FB);
  static const secondary = Color(0xFF666CEB);
  static const surface = Color(0xFFF7F7FF);
  static const ink = Color(0xFF25263A);
  static const muted = Color(0xFF77798D);
  static const success = Color(0xFF39B86B);
  static const missed = Color(0xFFE85A69);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: 'sans',
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyMedium: TextStyle(color: AppColors.muted),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 68,
        indicatorColor: Color(0x228F94FB),
        backgroundColor: Colors.white,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
