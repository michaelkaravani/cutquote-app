import 'package:flutter/material.dart';

const Color _brown = Color(0xFF513222);
const Color _orange = Color(0xFFE88432);
const Color _cream = Color(0xFFFAF7F0);

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brown,
      primary: _brown,
      secondary: _orange,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _brown,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _orange,
      unselectedItemColor: Color(0xFF513222),
    ),
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _orange,
      primary: _orange,
      secondary: const Color(0xFF8B6B4A),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: _orange,
      unselectedItemColor: Colors.white54,
    ),
  );
}
