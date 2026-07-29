import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF971746);
  static const background = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1A1A1A);
  static const textMuted = Color(0xFF6B6B6B);
  static const border = Color(0xFFE0E0E0);
}

class AppDecorations {
  const AppDecorations._();

  static final BoxDecoration card = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(8),
  );
}

const String _fontFamily = 'Inter';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: _fontFamily,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(72),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.5),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    labelStyle: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
    bodyMedium: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w400),
  ),
);
