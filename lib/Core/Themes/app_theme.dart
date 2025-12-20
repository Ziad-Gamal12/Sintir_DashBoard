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
    scaffoldBackgroundColor: const Color(0xFF121212),
    useMaterial3: true,

    colorScheme: const ColorScheme.dark().copyWith(
      primary: KMainColor,
      secondary: KSecondaryColor,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),

    // APP BAR
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),

    // CARDS
    cardColor: const Color(0xFF1E1E1E),

    // ICONS
    iconTheme: const IconThemeData(color: Colors.white70, size: 22),

    // TEXTS
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white54),
      titleMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
    ),

    // INPUTS
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.white54),
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIconColor: Colors.white60,
      suffixIconColor: Colors.white60,
    ),

    // DIVIDERS
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.12),
      thickness: 1,
    ),

    // BUTTONS
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KMainColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: KMainColor),
    ),

    // BOTTOM NAVIGATION
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: KMainColor,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
    ),

    // FLOATING BUTTON
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: KMainColor,
      foregroundColor: Colors.white,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );
}
