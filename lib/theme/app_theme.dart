import 'package:flutter/material.dart';

class AppColors {
<<<<<<< HEAD
  static const background = Color(0xFF000000);
=======
  static const background = Color(0xFF83114D);
>>>>>>> hetal1

  static const card = Color(0xFF27754C);

<<<<<<< HEAD
  static const card2 = Color(0xFF002612);

  static const border = Color(0xF210300A);
=======
  static const card2 = Color(0xFF752971);

  static const border = Color(0xFF0D3013);
>>>>>>> hetal1

  static const green = Color(0xFF16D365);

  static const greenDark = Color(0xFF319F67);

<<<<<<< HEAD
  static const text = Color(0xFF130D0D);
=======
  static const text = Color(0xF2120609);
>>>>>>> hetal1

  static const muted = Color(0xFF8B9792);

<<<<<<< HEAD
  static const red = Color(0xFFFF4048);
=======
  static const red = Color(0xFFCA1B1B);
>>>>>>> hetal1

  static const purple = Color(0xFF9B5DE5);

  static const pink = Color(0xFF83248A);

  static const blue = Color(0xFF183A71);

  static const orange = Color(0xFFBA7C1B);
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

      fontFamily: 'Arial, Helvetica, sans-serif',



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

      dividerColor: Colors.black,
    );
  }
}