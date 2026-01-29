import 'package:flutter/material.dart';

class AppTheme {
  // -----------------------------
  // LIGHT THEME
  // -----------------------------
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    fontFamily: "Cairo",
    primaryColor: Color(0xff4169E2),
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
    colorScheme: const ColorScheme.light().copyWith(
      primary: Color(0xff4169E2),
      secondary: Color(0xffff8c1a),
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: WidgetStateProperty.all(6),
      radius: const Radius.circular(10),
      thumbColor: WidgetStateProperty.all(Color(0xff4169E2).withOpacity(0.3)),
      thumbVisibility: WidgetStateProperty.all(false),
      interactive: true,
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
      selectedItemColor: Color(0xff4169E2),
      unselectedItemColor: Colors.grey,
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: "Cairo",
    primaryColor: Color(0xff4169E2),

    // Background: Neutral Deep Charcoal (No blue tint)
    scaffoldBackgroundColor: const Color(0xFF0F0F12),
    scrollbarTheme: ScrollbarThemeData(
      thickness: WidgetStateProperty.all(6),
      radius: const Radius.circular(10),
      thumbColor: WidgetStateProperty.all(Color(0xff4169E2).withOpacity(0.3)),
      thumbVisibility: WidgetStateProperty.all(false),
      interactive: true,
    ),
    useMaterial3: true,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Color(0xff4169E2),
      secondary: Color(0xffff8c1a),
      // Surface: Slightly lighter charcoal for cards/modals
      surface: const Color(0xFF18181C),
      onSurface: Colors.white,
    ),

    // APP BAR
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F0F12),
      elevation: 0,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),

    // CARD THEME
    cardColor: const Color(0xFF18181C),
    cardTheme: CardThemeData(
      color: const Color(0xFF18181C),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Subtle border to define cards against the deep background
        side: BorderSide(color: Colors.white.withOpacity(0.04)),
      ),
    ),

    // INPUT DECORATION (Fields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      // Input fields should be the deepest color or slightly different
      fillColor: const Color(0xFF1F1F23),
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
        borderSide: BorderSide(color: Color(0xff4169E2).withOpacity(0.5)),
      ),
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      labelStyle: const TextStyle(color: Colors.white60),
    ),

    // DIVIDERS: Soft neutral lines
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.06),
      thickness: 0.8,
    ),

    // TEXTS: Using neutral greys instead of blue-greys
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFE0E0E0)), // Light Grey
      bodySmall: TextStyle(color: Color(0xFFA0A0A0)), // Muted Grey
    ),

    // BOTTOM NAVIGATION
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0F0F12),
      selectedItemColor: Color(0xff4169E2),
      unselectedItemColor: Colors.white30,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
