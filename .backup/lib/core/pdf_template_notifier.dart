import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final PdfTemplateNotifier pdfTemplateNotifier = PdfTemplateNotifier();

class PdfTemplateNotifier extends ChangeNotifier {
  static const _key = 'pdf_template_style';

  String _currentTemplate = 'premium_dark';

  String get currentTemplate => _currentTemplate;

  PdfTemplateNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentTemplate = prefs.getString(_key) ?? 'premium_dark';
    notifyListeners();
  }

  Future<void> setTemplate(String template) async {
    if (_currentTemplate == template) return;
    _currentTemplate = template;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, template);
  }
}
