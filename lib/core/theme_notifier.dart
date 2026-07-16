import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ThemeNotifier themeNotifier = ThemeNotifier();

class ThemeNotifier extends ChangeNotifier {
  static const _key = 'theme_mode';

  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
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
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
