import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF000000);

  static const card = Color(0xFF001D0E);

  static const card2 = Color(0xFF002612);

  static const border = Color(0xF2E1335F);

  static const green = Color(0xFF16D365);

  static const greenDark = Color(0xFF063D21);

  static const text = Color(0xFFF5F7F6);

  static const muted = Color(0xFF8B9792);

  static const red = Color(0xFFFF4048);

  static const purple = Color(0xFF9B5DE5);

  static const pink = Color(0xFFE86AF2);

  static const blue = Color(0xFF4285F4);

  static const orange = Color(0xFFFFA000);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,

      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.green,
        secondary: AppColors.green,
        surface: AppColors.card,
      ),

      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,

        hintStyle: const TextStyle(
          color: AppColors.muted,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
          borderSide: const BorderSide(
            color: AppColors.green,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      dividerColor: Colors.transparent,
    );
  }
}