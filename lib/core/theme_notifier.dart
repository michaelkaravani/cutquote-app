import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

final ThemeNotifier themeNotifier = ThemeNotifier();

class ThemeNotifier extends ChangeNotifier {
  static const _key = 'theme_mode';
  static const _styleKey = 'theme_style';

  late ThemeMode _themeMode;
  late ThemeStyle _themeStyle;

  ThemeMode get themeMode => _themeMode;
  ThemeStyle get themeStyle => _themeStyle;

  ThemeNotifier() {
    _themeMode = ThemeMode.system;
    _themeStyle = ThemeStyle.classic;
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    switch (value) {
      case 'light':
        _themeMode = ThemeMode.light;
      case 'dark':
        _themeMode = ThemeMode.dark;
      default:
        _themeMode = ThemeMode.system;
    }
    final styleValue = prefs.getString(_styleKey);
    if (styleValue != null) {
      _themeStyle = ThemeStyle.values.firstWhere(
        (s) => s.name == styleValue,
        orElse: () => ThemeStyle.classic,
      );
    } else {
      _themeStyle = ThemeStyle.classic;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  Future<void> setThemeStyle(ThemeStyle style) async {
    if (_themeStyle == style) return;
    _themeStyle = style;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_styleKey, style.name);
  }
}
