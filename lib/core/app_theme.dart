import 'package:flutter/material.dart';

enum ThemeStyle {
  classic,
  ocean,
  forest,
}

extension ThemeStyleX on ThemeStyle {
  String get label {
    switch (this) {
      case ThemeStyle.classic:
        return 'קלאסי';
      case ThemeStyle.ocean:
        return 'אוקיינוס';
      case ThemeStyle.forest:
        return 'יער';
    }
  }

  IconData get icon {
    switch (this) {
      case ThemeStyle.classic:
        return Icons.palette;
      case ThemeStyle.ocean:
        return Icons.water_drop;
      case ThemeStyle.forest:
        return Icons.eco;
    }
  }
}

const Color _brown = Color(0xFF513222);
const Color _orange = Color(0xFFE88432);
const Color _cream = Color(0xFFFAF7F0);

const Color _navy = Color(0xFF1A3A5C);
const Color _teal = Color(0xFF4ECDC4);
const Color _ice = Color(0xFFF0F4F8);

const Color _forest = Color(0xFF2D5016);
const Color _gold = Color(0xFFD4A017);
const Color _ivory = Color(0xFFF5F7F0);

ThemeData buildLightTheme({ThemeStyle style = ThemeStyle.classic}) {
  switch (style) {
    case ThemeStyle.classic:
      return _buildClassicLight();
    case ThemeStyle.ocean:
      return _buildOceanLight();
    case ThemeStyle.forest:
      return _buildForestLight();
  }
}

ThemeData buildDarkTheme({ThemeStyle style = ThemeStyle.classic}) {
  switch (style) {
    case ThemeStyle.classic:
      return _buildClassicDark();
    case ThemeStyle.ocean:
      return _buildOceanDark();
    case ThemeStyle.forest:
      return _buildForestDark();
  }
}

ThemeData _buildClassicLight() {
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

ThemeData _buildClassicDark() {
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

ThemeData _buildOceanLight() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _ice,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _navy,
      primary: _navy,
      secondary: _teal,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _navy,
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
      selectedItemColor: _teal,
      unselectedItemColor: _navy,
    ),
  );
}

ThemeData _buildOceanDark() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D1B2A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _teal,
      primary: _teal,
      secondary: const Color(0xFF7FB3D8),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B2838),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1B2838),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1B2838),
      selectedItemColor: _teal,
      unselectedItemColor: Colors.white54,
    ),
  );
}

ThemeData _buildForestLight() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _ivory,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _forest,
      primary: _forest,
      secondary: _gold,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _forest,
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
      selectedItemColor: _gold,
      unselectedItemColor: _forest,
    ),
  );
}

ThemeData _buildForestDark() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1F0D),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6B8E23),
      primary: const Color(0xFF6B8E23),
      secondary: _gold,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF242B14),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF242B14),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF242B14),
      selectedItemColor: _gold,
      unselectedItemColor: Colors.white54,
    ),
  );
}
