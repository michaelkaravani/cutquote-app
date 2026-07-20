import 'package:cutquote/core/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const defaultPdfTemplate = 'premium_dark';
const supportedPdfTemplates = <String>{
  'premium_dark',
  'clean_corporate',
  'natural_craft',
  'minimal_stone',
  'modern_bordeaux',
};

final PdfTemplateNotifier pdfTemplateNotifier = PdfTemplateNotifier();

typedef PdfTemplateLoader = Future<String?> Function(String uid);
typedef PdfTemplateSaver = Future<void> Function(String uid, String template);

class PdfTemplateNotifier extends ChangeNotifier {
  static const _legacyKey = 'pdf_template_style';

  PdfTemplateNotifier({
    PdfTemplateLoader? loadRemoteTemplate,
    PdfTemplateSaver? saveRemoteTemplate,
  }) : _loadRemoteTemplate =
           loadRemoteTemplate ??
           ((uid) async {
             final profile = await FirestoreService.loadProfile(uid);
             return profile?['pdfTemplateStyle'] as String?;
           }),
       _saveRemoteTemplate =
           saveRemoteTemplate ??
           ((uid, template) => FirestoreService.saveProfile(uid, {
             'pdfTemplateStyle': template,
           }));

  final PdfTemplateLoader _loadRemoteTemplate;
  final PdfTemplateSaver _saveRemoteTemplate;

  String _currentTemplate = defaultPdfTemplate;
  String? _uid;
  SharedPreferences? _preferences;
  int _loadGeneration = 0;

  String get currentTemplate => _currentTemplate;
  bool get isInitialized => _uid != null && _preferences != null;

  static bool isSupported(String? template) =>
      template != null && supportedPdfTemplates.contains(template);

  static String _cacheKey(String uid) => '${_legacyKey}_$uid';

  Future<void> initialize(String uid) async {
    if (isInitialized && _uid == uid) return;

    final generation = ++_loadGeneration;
    _uid = uid;
    final preferences = await SharedPreferences.getInstance();
    if (generation != _loadGeneration || _uid != uid) return;

    _preferences = preferences;
    final cached = preferences.getString(_cacheKey(uid));
    final legacy = preferences.getString(_legacyKey);
    var selected = isSupported(cached)
        ? cached!
        : isSupported(legacy)
        ? legacy!
        : defaultPdfTemplate;

    try {
      final remote = await _loadRemoteTemplate(uid);
      if (generation != _loadGeneration || _uid != uid) return;
      if (isSupported(remote)) {
        selected = remote!;
      } else if (isSupported(cached) || isSupported(legacy)) {
        await _saveRemoteTemplate(uid, selected);
      }
    } catch (_) {
      if (generation != _loadGeneration || _uid != uid) return;
    }

    await preferences.setString(_cacheKey(uid), selected);
    if (legacy != null) await preferences.remove(_legacyKey);
    if (generation != _loadGeneration || _uid != uid) return;

    _currentTemplate = selected;
    notifyListeners();
  }

  Future<void> setTemplate(String template) async {
    if (!isSupported(template)) {
      throw ArgumentError.value(template, 'template', 'Unsupported template');
    }

    final uid = _uid;
    final preferences = _preferences;
    if (uid == null || preferences == null) {
      throw StateError('PDF template preferences are not initialized');
    }
    if (_currentTemplate == template) return;

    await _saveRemoteTemplate(uid, template);
    await preferences.setString(_cacheKey(uid), template);
    _currentTemplate = template;
    notifyListeners();
  }
}
