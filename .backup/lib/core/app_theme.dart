import 'package:flutter/material.dart';

enum ThemeStyle {
  classic,
  ocean,
  forest,
  sunset,
  lavender,
  midnight,
  rose,
  desert,
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
      case ThemeStyle.sunset:
        return 'שקיעה';
      case ThemeStyle.lavender:
        return 'לבנדר';
      case ThemeStyle.midnight:
        return 'חצות';
      case ThemeStyle.rose:
        return 'ורד';
      case ThemeStyle.desert:
        return 'מדבר';
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
      case ThemeStyle.sunset:
        return Icons.wb_sunny;
      case ThemeStyle.lavender:
        return Icons.local_florist;
      case ThemeStyle.midnight:
        return Icons.nights_stay;
      case ThemeStyle.rose:
        return Icons.favorite;
      case ThemeStyle.desert:
        return Icons.terrain;
    }
  }
}

const Color _sunsetOrange = Color(0xFFFF6B6B);
const Color _sunsetCoral = Color(0xFFE85D4A);
const Color _sunsetPeach = Color(0xFFFFF0E0);

const Color _lavenderViolet = Color(0xFF7B68EE);
const Color _lavenderMuted = Color(0xFF4A3F6B);
const Color _lavenderLilac = Color(0xFFF5F0FF);

const Color _midnightIndigo = Color(0xFF2C3E7B);
const Color _midnightCyan = Color(0xFF00BCD4);
const Color _midnightSteel = Color(0xFFF0F4FF);

const Color _rosePink = Color(0xFFE84393);
const Color _roseBurgundy = Color(0xFF6B213F);
const Color _roseBlush = Color(0xFFFFF0F3);

const Color _desertTerracotta = Color(0xFFCC5A3A);
const Color _desertCamel = Color(0xFFB8864E);
const Color _desertSand = Color(0xFFFEF5E7);

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
    case ThemeStyle.sunset:
      return _buildSunsetLight();
    case ThemeStyle.lavender:
      return _buildLavenderLight();
    case ThemeStyle.midnight:
      return _buildMidnightLight();
    case ThemeStyle.rose:
      return _buildRoseLight();
    case ThemeStyle.desert:
      return _buildDesertLight();
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
    case ThemeStyle.sunset:
      return _buildSunsetDark();
    case ThemeStyle.lavender:
      return _buildLavenderDark();
    case ThemeStyle.midnight:
      return _buildMidnightDark();
    case ThemeStyle.rose:
      return _buildRoseDark();
    case ThemeStyle.desert:
      return _buildDesertDark();
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

ThemeData _buildSunsetLight() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _sunsetPeach,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _sunsetCoral,
      primary: _sunsetCoral,
      secondary: _sunsetOrange,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _sunsetCoral,
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
      selectedItemColor: _sunsetOrange,
      unselectedItemColor: _sunsetCoral,
    ),
  );
}

ThemeData _buildSunsetDark() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1E1010),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _sunsetOrange,
      primary: _sunsetOrange,
      secondary: _sunsetCoral,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E1515),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2E1515),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2E1515),
      selectedItemColor: _sunsetOrange,
      unselectedItemColor: Colors.white54,
    ),
  );
}

ThemeData _buildLavenderLight() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lavenderLilac,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lavenderViolet,
      primary: _lavenderViolet,
      secondary: _lavenderMuted,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _lavenderMuted,
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
      selectedItemColor: _lavenderViolet,
      unselectedItemColor: _lavenderMuted,
    ),
  );
}

ThemeData _buildLavenderDark() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1625),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lavenderViolet,
      primary: _lavenderViolet,
      secondary: const Color(0xFF9B8FCC),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF262132),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF262132),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF262132),
      selectedItemColor: _lavenderViolet,
      unselectedItemColor: Colors.white54,
    ),
  );
}

ThemeData _buildMidnightLight() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _midnightSteel,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _midnightIndigo,
      primary: _midnightIndigo,
      secondary: _midnightCyan,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _midnightIndigo,
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
      selectedItemColor: _midnightCyan,
      unselectedItemColor: _midnightIndigo,
    ),
  );
}

ThemeData _buildMidnightDark() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0D1A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _midnightCyan,
      primary: _midnightCyan,
      secondary: const Color(0xFF5C8FBF),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A2E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1A2E),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A2E),
      selectedItemColor: _midnightCyan,
      unselectedItemColor: Colors.white54,
    ),
  );
}

ThemeData _buildRoseLight() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _roseBlush,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _rosePink,
      primary: _rosePink,
      secondary: _roseBurgundy,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _roseBurgundy,
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
      selectedItemColor: _rosePink,
      unselectedItemColor: _roseBurgundy,
    ),
  );
}

ThemeData _buildRoseDark() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A0D14),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _rosePink,
      primary: _rosePink,
      secondary: const Color(0xFFC44A7A),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E1422),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2E1422),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2E1422),
      selectedItemColor: _rosePink,
      unselectedItemColor: Colors.white54,
    ),
  );
}

ThemeData _buildDesertLight() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _desertSand,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _desertTerracotta,
      primary: _desertTerracotta,
      secondary: _desertCamel,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _desertTerracotta,
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
      selectedItemColor: _desertCamel,
      unselectedItemColor: _desertTerracotta,
    ),
  );
}

ThemeData _buildDesertDark() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1C140E),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _desertCamel,
      primary: _desertCamel,
      secondary: _desertTerracotta,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2B2016),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2B2016),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2B2016),
      selectedItemColor: _desertCamel,
      unselectedItemColor: Colors.white54,
    ),
  );
}
