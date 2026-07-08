import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _customersKey = 'saved_customers';
  static const String _catalogKey = 'saved_catalog';
  static const String _quotesKey = 'saved_quotes';

  // --- שמירת נתונים ---

  static Future<void> saveCustomers(List<Map<String, String>> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(customers);
    await prefs.setString(_customersKey, jsonString);
  }

  static Future<void> saveCatalog(List<Map<String, dynamic>> catalog) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(catalog);
    await prefs.setString(_catalogKey, jsonString);
  }

  static Future<void> saveQuotes(List<Map<String, dynamic>> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(quotes);
    await prefs.setString(_quotesKey, jsonString);
  }

  // --- טעינת נתונים ---

  static Future<List<Map<String, String>>> loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_customersKey);
    if (jsonString == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => Map<String, String>.from(item)).toList();
  }

  static Future<List<Map<String, dynamic>>> loadCatalog() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_catalogKey);
    if (jsonString == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<List<Map<String, dynamic>>> loadQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_quotesKey);
    if (jsonString == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }
}
