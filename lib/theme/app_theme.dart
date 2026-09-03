import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFFFFFF);

  static const card = Color(0xFF319F67);

  static const card2 = Color(0xFF8F1989);

  static const border = Color(0xF2469C36);

  static const green = Color(0xF2E1335F);

  static const greenDark = Color(0xFF183A71);

  static const text = Color(0xFF130D0D);

  static const muted = Color(0xFF8B9792);

  static const red = Color(0xFF4E070A);

  static const purple = Color(0xFF351A55);

  static const pink = Color(0xFFB81AC5);

  static const blue = Color(0xFFEC7FB8);

  static const orange = Color(0xFFB37A1A);
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