import 'dart:io';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'pdf_templates/premium_dark_template.dart';
import 'pdf_templates/clean_corporate_template.dart';
import 'pdf_templates/natural_craft_template.dart';
import 'pdf_templates/minimal_stone_template.dart';
import 'pdf_templates/modern_bordeaux_template.dart';

class PdfService {
  static Future<Uint8List> generateQuotePdfBytes({
    required Map<String, String>? customer,
    required List<Map<String, dynamic>> items,
    required double total,
    String? notes,
    Map<String, dynamic>? profile,
    String templateStyle = 'premium_dark',
  }) async {
    switch (templateStyle) {
      case 'premium_dark':
        return _buildPremiumDarkPdf(
          customer: customer,
          items: items,
          total: total,
          notes: notes,
          profile: profile,
        );
      case 'clean_corporate':
        return _buildCleanCorporatePdf(
          customer: customer,
          items: items,
          total: total,
          notes: notes,
          profile: profile,
        );
      case 'natural_craft':
        return _buildNaturalCraftPdf(
          customer: customer,
          items: items,
          total: total,
          notes: notes,
          profile: profile,
        );
      case 'minimal_stone':
        return _buildMinimalStonePdf(
          customer: customer,
          items: items,
          total: total,
          notes: notes,
          profile: profile,
        );
      case 'modern_bordeaux':
      default:
        return _buildModernBordeauxPdf(
          customer: customer,
          items: items,
          total: total,
          notes: notes,
          profile: profile,
        );
    }
  }

  static Future<Uint8List> generatePreviewPdfBytes({
    required Map<String, String>? customer,
    required List<Map<String, dynamic>> items,
    required double total,
    String? notes,
    Map<String, dynamic>? profile,
    String templateStyle = 'premium_dark',
  }) async {
    return generateQuotePdfBytes(
      customer: customer,
      items: items,
      total: total,
      notes: notes,
      profile: profile,
      templateStyle: templateStyle,
    );
  }

  static Future<void> generateAndShareQuote({
    required Map<String, String>? customer,
    required List<Map<String, dynamic>> items,
    required double total,
    String? notes,
    Map<String, dynamic>? profile,
    required String filename,
    String templateStyle = 'premium_dark',
  }) async {
    final pdfBytes = await generateQuotePdfBytes(
      customer: customer,
      items: items,
      total: total,
      notes: notes,
      profile: profile,
      templateStyle: templateStyle,
    );
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$filename');
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles([XFile(file.path)], text: 'הצעת מחיר ממיכאל פרסיז\'ן ארט');
  }

  // ==========================================
  // TEMPLATE 1: PREMIUM DARK (יוקרתי כהה)
  // ==========================================
  static Future<Uint8List> _buildPremiumDarkPdf({
    required Map<String, String>? customer,
    required List<Map<String, dynamic>> items,
    required double total,
    String? notes,
    Map<String, dynamic>? profile,
  }) {
    return buildPremiumDarkPdf(
      customer: customer,
      items: items,
      total: total,
      notes: notes,
      profile: profile,
    );
  }

  // ==========================================
  // TEMPLATE 2: CLEAN CORPORATE (תאגידי נקי)
  // ==========================================
  static Future<Uint8List> _buildCleanCorporatePdf({
    required Map<String, String>? customer,
    required List<Map<String, dynamic>> items,
    required double total,
    String? notes,
    Map<String, dynamic>? profile,
  }) {
    return buildCleanCorporatePdf(
      customer: customer,
      items: items,
      total: total,
      notes: notes,
      profile: profile,
    );
  }

  // ==========================================
  // TEMPLATE 3: NATURAL CRAFT (קראפטי טבעי)
  // ==========================================
  static Future<Uint8List> _buildNaturalCraftPdf({
    required Map<String, String>? customer,
    required List<Map<String, dynamic>> items,
    required double total,
    String? notes,
    Map<String, dynamic>? profile,
  }) {
    return buildNaturalCraftPdf(
      customer: customer,
      items: items,
      total: total,
      notes: notes,
      profile: profile,
    );
  }

  // ==========================================
  // TEMPLATE 4: MINIMAL STONE (מינימל אבן)
  // ==========================================
  static Future<Uint8List> _buildMinimalStonePdf({
    required Map<String, String>? customer,
    required List<Map<String, dynamic>> items,
    required double total,
    String? notes,
    Map<String, dynamic>? profile,
  }) {
    return buildMinimalStonePdf(
      customer: customer,
      items: items,
      total: total,
      notes: notes,
      profile: profile,
    );
  }

  // ==========================================
  // TEMPLATE 5: MODERN BORDEAUX (מודרני בורדו)
  // ==========================================
  static Future<Uint8List> _buildModernBordeauxPdf({
    required Map<String, String>? customer,
    required List<Map<String, dynamic>> items,
    required double total,
    String? notes,
    Map<String, dynamic>? profile,
  }) {
    return buildModernBordeauxPdf(
      customer: customer,
      items: items,
      total: total,
      notes: notes,
      profile: profile,
    );
  }

}
