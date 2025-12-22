import 'package:flutter/material.dart';
import 'package:sintir_dashboard/constant.dart';

class AppTheme {
  // -----------------------------
  // LIGHT THEME
  // -----------------------------
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    fontFamily: "Cairo",
    primaryColor: KMainColor,
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
    colorScheme: const ColorScheme.light().copyWith(
      primary: KMainColor,
      secondary: KSecondaryColor,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: Colors.black,
      centerTitle: true,
    ),
    cardColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.black87),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.black54),
      titleMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade300),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: KMainColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  // -----------------------------
  // DARK THEME
  // -----------------------------
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: "Cairo",
    primaryColor: KMainColor,
    scaffoldBackgroundColor: const Color(0xFF151D2C),
    useMaterial3: true,

    colorScheme: const ColorScheme.dark().copyWith(
      primary: KMainColor,
      secondary: KSecondaryColor,
      surface: const Color(0xFF1C2637),
      onSurface: Colors.white,
    ),

    // APP BAR
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF151D2C),
      elevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),

    cardColor: const Color(0xFF1C2637),
    cardTheme: CardThemeData(
      color: const Color(0xFF1C2637),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withOpacity(0.05),
        ), // إطار خفيف جداً بدل الظل
      ),
    ),

    // INPUTS - لون داكن جداً للحقول
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F1520),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.03)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: KMainColor.withOpacity(0.5)),
      ),
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      labelStyle: const TextStyle(color: Colors.white60),
    ),

    // DIVIDERS
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.05),
      thickness: 0.8,
    ),

    // TEXTS
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(
        color: Color(0xFFB0B8C4),
      ), // لون رمادي مزرق للنصوص الثانوية
      bodySmall: TextStyle(color: Color(0xFF8E99A8)),
    ),

    // BOTTOM NAVIGATION
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF151D2C),
      selectedItemColor: KMainColor,
      unselectedItemColor: Colors.white30,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
