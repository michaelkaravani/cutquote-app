import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

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

  static Map<String, dynamic> _extractProfile(Map<String, dynamic>? profile) {
    return {
      'businessName': profile?['businessName'] as String? ?? 'מיכאל פרסיז\'ן ארט',
      'phone': profile?['phone'] as String? ?? '',
      'email': profile?['email'] as String? ?? '',
      'logoPath': profile?['logoPath'] as String?,
      'vatRate': (profile?['vatRate'] as num?)?.toDouble() ?? 0.18,
      'defaultPdfNotes': profile?['defaultPdfNotes'] as String? ?? '',
      'paymentTerms': profile?['paymentTerms'] as String? ?? '',
    };
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
  }) async {
    final brandDark = PdfColor.fromInt(0xFF1A1A2E);
    final brandGold = PdfColor.fromInt(0xFFC9A84C);
    final textDark = PdfColor.fromInt(0xFF2D2D2D);
    final textMuted = PdfColor.fromInt(0xFF888888);
    final bgCard = PdfColor.fromInt(0xFFFFFFFF);
    final rowAlt = PdfColor.fromInt(0xFFF8F7F4);
    final borderLight = PdfColor.fromInt(0xFFE8E5DD);

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.assistantRegular();
    final boldFont = await PdfGoogleFonts.assistantBold();

    final p = _extractProfile(profile);
    final businessName = p['businessName'] as String;
    final phone = p['phone'] as String;
    final email = p['email'] as String;
    final logoPath = p['logoPath'] as String?;
    final vatRate = p['vatRate'] as double;
    final defaultTerms = p['defaultPdfNotes'] as String;
    final paymentTerms = p['paymentTerms'] as String;
    final cleanNotes = (notes ?? '').trim();
    final showPaymentTerms = paymentTerms.isNotEmpty;
    final showNotes = cleanNotes.isNotEmpty || defaultTerms.isNotEmpty;

    final beforeVat = total / (1.0 + vatRate);
    final vatAmount = total - beforeVat;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.fromLTRB(24, 20, 24, 20),
                  decoration: pw.BoxDecoration(
                    color: brandDark,
                    borderRadius: const pw.BorderRadius.only(
                      bottomRight: pw.Radius.circular(16),
                    ),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          if (logoPath != null && File(logoPath).existsSync())
                            pw.Container(
                              margin: const pw.EdgeInsets.only(left: 14),
                              padding: const pw.EdgeInsets.all(2),
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                shape: pw.BoxShape.circle,
                              ),
                              child: pw.ClipOval(
                                child: pw.Image(
                                  pw.MemoryImage(File(logoPath).readAsBytesSync()),
                                  width: 44,
                                  height: 44,
                                ),
                              ),
                            ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                businessName,
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                '$phone  |  $email',
                                style: pw.TextStyle(
                                  fontSize: 7,
                                  color: PdfColor.fromInt(0xFFAAAAAA),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'הצעת מחיר',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: brandGold,
                            ),
                          ),
                          pw.Text(
                            'QUOTATION',
                            style: pw.TextStyle(
                              fontSize: 7,
                              color: brandGold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(height: 3, color: brandGold, width: 80),
                pw.SizedBox(height: 20),

                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: bgCard,
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: brandGold, width: 0.5),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'לכבוד',
                              style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: brandGold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              customer?['name'] ?? 'לקוח כללי',
                              style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: brandDark,
                              ),
                            ),
                            if (customer != null) ...[
                              if ((customer['hp'] ?? '').isNotEmpty)
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(top: 2),
                                  child: pw.Text(
                                    'ח.פ/ת.ז: ${customer['hp']}',
                                    style: pw.TextStyle(fontSize: 8, color: textMuted),
                                  ),
                                ),
                              if ((customer['address'] ?? '').isNotEmpty)
                                pw.Text(
                                  '${customer['address']}',
                                  style: pw.TextStyle(fontSize: 8, color: textMuted),
                                ),
                              if ((customer['phone'] ?? '').isNotEmpty)
                                pw.Text(
                                  '${customer['phone']}',
                                  style: pw.TextStyle(fontSize: 8, color: textMuted),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: bgCard,
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: borderLight, width: 0.5),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _metaRow('תאריך', _todayFormatted(), textMuted, brandDark),
                            pw.SizedBox(height: 4),
                            _metaRow('תוקף הצעה', '30 יום', textMuted, brandDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: brandDark,
                    borderRadius: const pw.BorderRadius.only(
                      topRight: pw.Radius.circular(8),
                      topLeft: pw.Radius.circular(8),
                    ),
                  ),
                  padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 5, child: pw.Text('תיאור הפריט / השירות', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9))),
                      pw.Expanded(flex: 1, child: pw.Text('כמות', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('מחיר יחידה', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('סה"כ', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                    ],
                  ),
                ),

                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final qty = double.tryParse(item['quantity']?.toString() ?? '1') ?? 1.0;
                  final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                  final itemTotal = qty * price;
                  final isEven = index % 2 == 0;
                  return pw.Container(
                    color: isEven ? PdfColors.white : rowAlt,
                    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 5, child: pw.Text(item['name']?.toString() ?? '', style: pw.TextStyle(fontSize: 9, color: textDark))),
                        pw.Expanded(flex: 1, child: pw.Text(qty.toStringAsFixed(0), style: pw.TextStyle(fontSize: 9, color: textDark), textAlign: pw.TextAlign.center)),
                        pw.Expanded(flex: 2, child: pw.Text('₪${price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: textDark), textAlign: pw.TextAlign.center)),
                        pw.Expanded(flex: 2, child: pw.Text('₪${itemTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandDark), textAlign: pw.TextAlign.center)),
                      ],
                    ),
                  );
                }),

                pw.Container(
                  height: 8,
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.only(
                      bottomRight: pw.Radius.circular(8),
                      bottomLeft: pw.Radius.circular(8),
                    ),
                  ),
                ),

                pw.SizedBox(height: 16),

                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(
                    width: 240,
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: brandDark,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('סה"כ לפני מע"מ:', style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFAAAAAA))),
                            pw.Text('₪${beforeVat.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('מע"מ (${(vatRate * 100).toStringAsFixed(0)}%):', style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFAAAAAA))),
                            pw.Text('₪${vatAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                          ],
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 6),
                          child: pw.Divider(color: brandGold, thickness: 0.5),
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('סה"כ לתשלום:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: brandGold)),
                            pw.Text('₪${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: brandGold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),

                if (showPaymentTerms) ...[
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: bgCard,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border(
                        right: pw.BorderSide(color: brandGold, width: 3),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('תנאי תשלום', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandDark)),
                        pw.SizedBox(height: 4),
                        pw.Text(paymentTerms, style: pw.TextStyle(fontSize: 8, color: textDark)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),
                ],

                if (showNotes) ...[
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: rowAlt,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('הערות', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textMuted)),
                        pw.SizedBox(height: 4),
                        if (cleanNotes.isNotEmpty)
                          pw.Text(cleanNotes, style: pw.TextStyle(fontSize: 8, color: textDark)),
                        if (cleanNotes.isNotEmpty && defaultTerms.isNotEmpty)
                          pw.SizedBox(height: 4),
                        if (defaultTerms.isNotEmpty)
                          pw.Text(defaultTerms, style: pw.TextStyle(fontSize: 8, color: textDark)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),
                ],

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSignatureLine('חתימת בית העסק', brandGold, textMuted),
                    _buildSignatureLine('חתימת הלקוח לאישור', brandGold, textMuted),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
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
  }) async {
    final brandTeal = PdfColor.fromInt(0xFF0D7377);
    final brandLight = PdfColor.fromInt(0xFFE8F4F4);
    final textDark = PdfColor.fromInt(0xFF1F2937);
    final textMuted = PdfColor.fromInt(0xFF6B7280);
    final borderLight = PdfColor.fromInt(0xFFE5E7EB);

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.assistantRegular();
    final boldFont = await PdfGoogleFonts.assistantBold();

    final p = _extractProfile(profile);
    final businessName = p['businessName'] as String;
    final phone = p['phone'] as String;
    final email = p['email'] as String;
    final logoPath = p['logoPath'] as String?;
    final vatRate = p['vatRate'] as double;
    final defaultTerms = p['defaultPdfNotes'] as String;
    final paymentTerms = p['paymentTerms'] as String;
    final cleanNotes = (notes ?? '').trim();
    final showPaymentTerms = paymentTerms.isNotEmpty;
    final showNotes = cleanNotes.isNotEmpty || defaultTerms.isNotEmpty;

    final beforeVat = total / (1.0 + vatRate);
    final vatAmount = total - beforeVat;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(height: 5, color: brandTeal, width: double.infinity),
                pw.SizedBox(height: 20),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        if (logoPath != null && File(logoPath).existsSync())
                          pw.Container(
                            margin: const pw.EdgeInsets.only(left: 12),
                            child: pw.Image(
                              pw.MemoryImage(File(logoPath).readAsBytesSync()),
                              width: 48,
                              height: 48,
                            ),
                          ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(businessName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: brandTeal)),
                            pw.Text('$phone  |  $email', style: pw.TextStyle(fontSize: 8, color: textMuted)),
                          ],
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('הצעת מחיר', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: brandTeal)),
                        pw.Text(
                          _todayFormatted(),
                          style: pw.TextStyle(fontSize: 8, color: textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(6),
                          border: pw.Border(
                            right: pw.BorderSide(color: brandTeal, width: 3),
                            top: pw.BorderSide(color: borderLight, width: 0.5),
                            bottom: pw.BorderSide(color: borderLight, width: 0.5),
                            left: pw.BorderSide(color: borderLight, width: 0.5),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('פרטי הלקוח', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brandTeal)),
                            pw.SizedBox(height: 6),
                            pw.Text(customer?['name'] ?? 'לקוח כללי', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: textDark)),
                            if (customer != null) ...[
                              if ((customer['hp'] ?? '').isNotEmpty)
                                pw.Text('ח.פ/ת.ז: ${customer['hp']}', style: pw.TextStyle(fontSize: 9, color: textDark)),
                              if ((customer['address'] ?? '').isNotEmpty)
                                pw.Text('${customer['address']}', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                              if ((customer['phone'] ?? '').isNotEmpty)
                                pw.Text('${customer['phone']}', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: brandLight,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('פרטי המסמך', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brandTeal)),
                            pw.SizedBox(height: 8),
                            _metaRow('תאריך', _todayFormatted(), textMuted, textDark),
                            pw.SizedBox(height: 4),
                            _metaRow('תוקף הצעה', '30 יום', textMuted, textDark),
                            pw.SizedBox(height: 4),
                            _metaRow('מס\' הצעה', '#${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}', textMuted, textDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: brandTeal,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 5, child: pw.Text('תיאור הפריט / השירות', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9))),
                      pw.Expanded(flex: 1, child: pw.Text('כמות', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('מחיר יחידה', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('סה"כ', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                    ],
                  ),
                ),

                ...items.map((item) {
                  final qty = double.tryParse(item['quantity']?.toString() ?? '1') ?? 1.0;
                  final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                  final itemTotal = qty * price;
                  return pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: borderLight, width: 0.5)),
                    ),
                    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 5, child: pw.Text(item['name']?.toString() ?? '', style: pw.TextStyle(fontSize: 9, color: textDark))),
                        pw.Expanded(flex: 1, child: pw.Text(qty.toStringAsFixed(0), style: pw.TextStyle(fontSize: 9, color: textDark), textAlign: pw.TextAlign.center)),
                        pw.Expanded(flex: 2, child: pw.Text('₪${price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: textDark), textAlign: pw.TextAlign.center)),
                        pw.Expanded(flex: 2, child: pw.Text('₪${itemTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandTeal), textAlign: pw.TextAlign.center)),
                      ],
                    ),
                  );
                }),
                pw.SizedBox(height: 16),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (showPaymentTerms) ...[
                            pw.Container(
                              padding: const pw.EdgeInsets.all(10),
                              decoration: pw.BoxDecoration(
                                color: brandLight,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('תנאי תשלום', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brandTeal)),
                                  pw.SizedBox(height: 4),
                                  pw.Text(paymentTerms, style: pw.TextStyle(fontSize: 8, color: textDark)),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 8),
                          ],
                          if (showNotes) ...[
                            pw.Container(
                              padding: const pw.EdgeInsets.all(10),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: borderLight, width: 0.5),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('הערות', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textMuted)),
                                  pw.SizedBox(height: 4),
                                  if (cleanNotes.isNotEmpty)
                                    pw.Text(cleanNotes, style: pw.TextStyle(fontSize: 8, color: textDark)),
                                  if (cleanNotes.isNotEmpty && defaultTerms.isNotEmpty)
                                    pw.SizedBox(height: 4),
                                  if (defaultTerms.isNotEmpty)
                                    pw.Text(defaultTerms, style: pw.TextStyle(fontSize: 8, color: textDark)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 24),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: brandTeal,
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('סיכום הצעת מחיר', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                            pw.SizedBox(height: 10),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('סה"כ לפני מע"מ:', style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFCCE8EA))),
                                pw.Text('₪${beforeVat.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('מע"מ (${(vatRate * 100).toStringAsFixed(0)}%):', style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFCCE8EA))),
                                pw.Text('₪${vatAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                              ],
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 6),
                              child: pw.Divider(color: PdfColor.fromInt(0x4DFFFFFF), thickness: 0.5),
                            ),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('סה"כ לתשלום:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                                pw.Text('₪${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                pw.Spacer(),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSignatureLine('חתימת בית העסק', brandTeal, textMuted),
                    _buildSignatureLine('חתימת הלקוח לאישור', brandTeal, textMuted),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
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
  }) async {
    final brandOlive = PdfColor.fromInt(0xFF5B7B4A);
    final bgCream = PdfColor.fromInt(0xFFFEFAF0);
    final textDark = PdfColor.fromInt(0xFF3D2E1E);
    final textMuted = PdfColor.fromInt(0xFF8B7D6B);
    final cardBorder = PdfColor.fromInt(0xFFE8E0D0);
    final rowAlt = PdfColor.fromInt(0xFFFCF8F0);

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.assistantRegular();
    final boldFont = await PdfGoogleFonts.assistantBold();

    final p = _extractProfile(profile);
    final businessName = p['businessName'] as String;
    final phone = p['phone'] as String;
    final email = p['email'] as String;
    final logoPath = p['logoPath'] as String?;
    final vatRate = p['vatRate'] as double;
    final defaultTerms = p['defaultPdfNotes'] as String;
    final paymentTerms = p['paymentTerms'] as String;
    final cleanNotes = (notes ?? '').trim();
    final showPaymentTerms = paymentTerms.isNotEmpty;
    final showNotes = cleanNotes.isNotEmpty || defaultTerms.isNotEmpty;

    final beforeVat = total / (1.0 + vatRate);
    final vatAmount = total - beforeVat;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    color: brandOlive,
                    borderRadius: const pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(32),
                    ),
                  ),
                  padding: const pw.EdgeInsets.fromLTRB(40, 24, 40, 24),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          if (logoPath != null && File(logoPath).existsSync())
                            pw.Container(
                              margin: const pw.EdgeInsets.only(left: 14),
                              width: 48,
                              height: 48,
                              decoration: pw.BoxDecoration(
                                borderRadius: pw.BorderRadius.circular(8),
                              ),
                              child: pw.ClipOval(
                                child: pw.Image(
                                  pw.MemoryImage(File(logoPath).readAsBytesSync()),
                                  width: 48,
                                  height: 48,
                                  fit: pw.BoxFit.cover,
                                ),
                              ),
                            ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(businessName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                              pw.Text('$phone  |  $email', style: pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFFC4D4B8))),
                            ],
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('הצעת מחיר', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                          pw.Text('QUOTATION', style: pw.TextStyle(fontSize: 7, color: PdfColor.fromInt(0xFFC4D4B8), letterSpacing: 1.5)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Container(height: 4, color: PdfColor.fromInt(0xFFD4C9A8), width: 120, margin: const pw.EdgeInsets.only(right: 40)),
                pw.SizedBox(height: 20),

                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 40),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(16),
                          decoration: pw.BoxDecoration(
                            color: bgCream,
                            borderRadius: pw.BorderRadius.circular(12),
                            border: pw.Border.all(color: cardBorder, width: 1),
                          ),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('הצעה עבור', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brandOlive)),
                                  pw.SizedBox(height: 4),
                                  pw.Text(customer?['name'] ?? 'לקוח כללי', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: textDark)),
                                  if (customer != null) ...[
                                    if ((customer['hp'] ?? '').isNotEmpty)
                                      pw.Text('ח.פ/ת.ז: ${customer['hp']}', style: pw.TextStyle(fontSize: 9, color: textDark)),
                                    if ((customer['address'] ?? '').isNotEmpty)
                                      pw.Text('${customer['address']}', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                                    if ((customer['phone'] ?? '').isNotEmpty)
                                      pw.Text('${customer['phone']}', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                                  ],
                                ],
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  _metaRow('תאריך', _todayFormatted(), textMuted, textDark),
                                  pw.SizedBox(height: 4),
                                  _metaRow('תוקף', '30 יום', textMuted, textDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 24),

                        pw.Container(
                          decoration: pw.BoxDecoration(
                            color: brandOlive,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                          ),
                          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          child: pw.Row(
                            children: [
                              pw.Expanded(flex: 5, child: pw.Text('תיאור הפריט / השירות', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9))),
                              pw.Expanded(flex: 1, child: pw.Text('כמות', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                              pw.Expanded(flex: 2, child: pw.Text('מחיר יחידה', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                              pw.Expanded(flex: 2, child: pw.Text('סה"כ', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                            ],
                          ),
                        ),

                        ...items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final qty = double.tryParse(item['quantity']?.toString() ?? '1') ?? 1.0;
                          final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                          final itemTotal = qty * price;
                          return pw.Container(
                            margin: const pw.EdgeInsets.only(top: 4),
                            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: pw.BoxDecoration(
                              color: index % 2 == 0 ? PdfColors.white : rowAlt,
                              borderRadius: pw.BorderRadius.circular(6),
                            ),
                            child: pw.Row(
                              children: [
                                pw.Expanded(flex: 5, child: pw.Text(item['name']?.toString() ?? '', style: pw.TextStyle(fontSize: 9, color: textDark))),
                                pw.Expanded(flex: 1, child: pw.Text(qty.toStringAsFixed(0), style: pw.TextStyle(fontSize: 9, color: textDark), textAlign: pw.TextAlign.center)),
                                pw.Expanded(flex: 2, child: pw.Text('₪${price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: textDark), textAlign: pw.TextAlign.center)),
                                pw.Expanded(flex: 2, child: pw.Text('₪${itemTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandOlive), textAlign: pw.TextAlign.center)),
                              ],
                            ),
                          );
                        }),
                        pw.SizedBox(height: 20),

                        pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Container(
                            width: 240,
                            padding: const pw.EdgeInsets.all(16),
                            decoration: pw.BoxDecoration(
                              color: bgCream,
                              borderRadius: pw.BorderRadius.circular(12),
                              border: pw.Border.all(color: cardBorder, width: 1),
                            ),
                            child: pw.Column(
                              children: [
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('סה"כ לפני מע"מ:', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                                    pw.Text('₪${beforeVat.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: textDark)),
                                  ],
                                ),
                                pw.SizedBox(height: 4),
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('מע"מ (${(vatRate * 100).toStringAsFixed(0)}%):', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                                    pw.Text('₪${vatAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: textDark)),
                                  ],
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                                  child: pw.Divider(color: cardBorder, thickness: 1),
                                ),
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text('סה"כ לתשלום:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: brandOlive)),
                                    pw.Text('₪${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: brandOlive)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        pw.Spacer(),

                        if (showPaymentTerms) ...[
                          pw.Container(
                            width: double.infinity,
                            padding: const pw.EdgeInsets.all(12),
                            decoration: pw.BoxDecoration(
                              color: bgCream,
                              borderRadius: pw.BorderRadius.circular(8),
                              border: pw.Border.all(color: cardBorder, width: 0.5),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('תנאי תשלום', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandOlive)),
                                pw.SizedBox(height: 4),
                                pw.Text(paymentTerms, style: pw.TextStyle(fontSize: 8, color: textDark)),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 8),
                        ],
                        if (showNotes) ...[
                          pw.Container(
                            width: double.infinity,
                            padding: const pw.EdgeInsets.all(12),
                            decoration: pw.BoxDecoration(
                              color: bgCream,
                              borderRadius: pw.BorderRadius.circular(8),
                              border: pw.Border.all(color: cardBorder, width: 0.5),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('הערות', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textMuted)),
                                pw.SizedBox(height: 4),
                                if (cleanNotes.isNotEmpty)
                                  pw.Text(cleanNotes, style: pw.TextStyle(fontSize: 8, color: textDark)),
                                if (cleanNotes.isNotEmpty && defaultTerms.isNotEmpty)
                                  pw.SizedBox(height: 4),
                                if (defaultTerms.isNotEmpty)
                                  pw.Text(defaultTerms, style: pw.TextStyle(fontSize: 8, color: textDark)),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 16),
                        ],

                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSignatureLine('חתימת בית העסק', brandOlive, textMuted),
                            _buildSignatureLine('חתימת הלקוח לאישור', brandOlive, textMuted),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
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
  }) async {
    final brandGrey = PdfColor.fromInt(0xFF4A4A4A);
    final brandTerracotta = PdfColor.fromInt(0xFFC4A484);
    final textDark = PdfColor.fromInt(0xFF2D2D2D);
    final textMuted = PdfColor.fromInt(0xFF999999);
    final borderLight = PdfColor.fromInt(0xFFE8E8E4);

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.assistantRegular();
    final boldFont = await PdfGoogleFonts.assistantBold();

    final p = _extractProfile(profile);
    final businessName = p['businessName'] as String;
    final phone = p['phone'] as String;
    final email = p['email'] as String;
    final logoPath = p['logoPath'] as String?;
    final vatRate = p['vatRate'] as double;
    final defaultTerms = p['defaultPdfNotes'] as String;
    final paymentTerms = p['paymentTerms'] as String;
    final cleanNotes = (notes ?? '').trim();
    final showPaymentTerms = paymentTerms.isNotEmpty;
    final showNotes = cleanNotes.isNotEmpty || defaultTerms.isNotEmpty;

    final beforeVat = total / (1.0 + vatRate);
    final vatAmount = total - beforeVat;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 32, 40, 32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(height: 3, color: brandTerracotta, width: 60),
                pw.SizedBox(height: 28),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(businessName, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: brandGrey, letterSpacing: 1)),
                        pw.SizedBox(height: 4),
                        pw.Text(phone, style: pw.TextStyle(fontSize: 8, color: textMuted)),
                        pw.Text(email, style: pw.TextStyle(fontSize: 8, color: textMuted)),
                      ],
                    ),
                    if (logoPath != null && File(logoPath).existsSync())
                      pw.Image(
                        pw.MemoryImage(File(logoPath).readAsBytesSync()),
                        width: 42,
                        height: 42,
                      ),
                  ],
                ),
                pw.SizedBox(height: 32),

                pw.Text('הצעת מחיר', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: brandGrey, letterSpacing: 1)),
                pw.SizedBox(height: 4),
                pw.Text(
                  _todayFormatted(),
                  style: pw.TextStyle(fontSize: 9, color: textMuted),
                ),
                pw.SizedBox(height: 32),

                pw.Text(customer?['name'] ?? 'לקוח כללי', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: textDark)),
                if (customer != null) ...[
                  if ((customer['hp'] ?? '').isNotEmpty)
                    pw.Text('ח.פ/ת.ז: ${customer['hp']}', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                  if ((customer['address'] ?? '').isNotEmpty)
                    pw.Text('${customer['address']}', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                  if ((customer['phone'] ?? '').isNotEmpty)
                    pw.Text('${customer['phone']}', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                ],
                pw.SizedBox(height: 28),

                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: brandGrey, width: 1.5)),
                  ),
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 5, child: pw.Text('תיאור הפריט / השירות', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brandGrey))),
                      pw.Expanded(flex: 1, child: pw.Text('כמות', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brandGrey), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('מחיר יחידה', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brandGrey), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('סה"כ', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brandGrey), textAlign: pw.TextAlign.center)),
                    ],
                  ),
                ),

                ...items.map((item) {
                  final qty = double.tryParse(item['quantity']?.toString() ?? '1') ?? 1.0;
                  final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                  final itemTotal = qty * price;
                  return pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: borderLight, width: 0.5)),
                    ),
                    padding: const pw.EdgeInsets.symmetric(vertical: 10),
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 5, child: pw.Text(item['name']?.toString() ?? '', style: pw.TextStyle(fontSize: 9, color: textDark))),
                        pw.Expanded(flex: 1, child: pw.Text(qty.toStringAsFixed(0), style: pw.TextStyle(fontSize: 9, color: textMuted), textAlign: pw.TextAlign.center)),
                        pw.Expanded(flex: 2, child: pw.Text('₪${price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: textMuted), textAlign: pw.TextAlign.center)),
                        pw.Expanded(flex: 2, child: pw.Text('₪${itemTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textDark), textAlign: pw.TextAlign.center)),
                      ],
                    ),
                  );
                }),
                pw.SizedBox(height: 24),

                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(
                    width: 220,
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('סה"כ לפני מע"מ:', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                            pw.Text('₪${beforeVat.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: textDark)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('מע"מ (${(vatRate * 100).toStringAsFixed(0)}%):', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                            pw.Text('₪${vatAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: textDark)),
                          ],
                        ),
                        pw.Container(height: 1, color: brandTerracotta, margin: const pw.EdgeInsets.symmetric(vertical: 8)),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('סה"כ לתשלום:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: brandGrey)),
                            pw.Text('₪${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: brandTerracotta)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),

                if (showPaymentTerms) ...[
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: borderLight, width: 0.5)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('תנאי תשלום', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brandGrey)),
                        pw.SizedBox(height: 4),
                        pw.Text(paymentTerms, style: pw.TextStyle(fontSize: 8, color: textDark)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 12),
                ],

                if (showNotes) ...[
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: borderLight, width: 0.5)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('הערות', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textMuted)),
                        pw.SizedBox(height: 4),
                        if (cleanNotes.isNotEmpty)
                          pw.Text(cleanNotes, style: pw.TextStyle(fontSize: 8, color: textDark)),
                        if (cleanNotes.isNotEmpty && defaultTerms.isNotEmpty)
                          pw.SizedBox(height: 4),
                        if (defaultTerms.isNotEmpty)
                          pw.Text(defaultTerms, style: pw.TextStyle(fontSize: 8, color: textDark)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),
                ],

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSignatureLine('חתימת בית העסק', brandTerracotta, textMuted),
                    _buildSignatureLine('חתימת הלקוח לאישור', brandTerracotta, textMuted),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
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
  }) async {
    final brandBordeaux = PdfColor.fromInt(0xFF722F37);
    final brandBlush = PdfColor.fromInt(0xFFF5E1E4);
    final brandGold = PdfColor.fromInt(0xFFD4AF37);
    final textDark = PdfColor.fromInt(0xFF2C1819);
    final textMuted = PdfColor.fromInt(0xFF8D6E6F);
    final borderLight = PdfColor.fromInt(0xFFE8D5D7);

    final pdf = pw.Document();
    final font = await PdfGoogleFonts.assistantRegular();
    final boldFont = await PdfGoogleFonts.assistantBold();

    final p = _extractProfile(profile);
    final businessName = p['businessName'] as String;
    final phone = p['phone'] as String;
    final email = p['email'] as String;
    final logoPath = p['logoPath'] as String?;
    final vatRate = p['vatRate'] as double;
    final defaultTerms = p['defaultPdfNotes'] as String;
    final paymentTerms = p['paymentTerms'] as String;
    final cleanNotes = (notes ?? '').trim();
    final showPaymentTerms = paymentTerms.isNotEmpty;
    final showNotes = cleanNotes.isNotEmpty || defaultTerms.isNotEmpty;

    final beforeVat = total / (1.0 + vatRate);
    final vatAmount = total - beforeVat;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.fromLTRB(24, 20, 24, 20),
                  decoration: pw.BoxDecoration(
                    color: brandBordeaux,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          if (logoPath != null && File(logoPath).existsSync())
                            pw.Container(
                              margin: const pw.EdgeInsets.only(left: 14),
                              padding: const pw.EdgeInsets.all(2),
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.white,
                                shape: pw.BoxShape.circle,
                              ),
                              child: pw.ClipOval(
                                child: pw.Image(
                                  pw.MemoryImage(File(logoPath).readAsBytesSync()),
                                  width: 44,
                                  height: 44,
                                ),
                              ),
                            ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(businessName, style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                '$phone  |  $email',
                                style: pw.TextStyle(
                                  fontSize: 7,
                                  color: PdfColor.fromInt(0xFFD4A0A5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('הצעת מחיר', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: brandGold)),
                          pw.Text('QUOTATION', style: pw.TextStyle(fontSize: 7, color: brandGold, letterSpacing: 2)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: brandBlush,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('לכבוד', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brandBordeaux)),
                            pw.SizedBox(height: 6),
                            pw.Text(customer?['name'] ?? 'לקוח כללי', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: textDark)),
                            if (customer != null) ...[
                              if ((customer['hp'] ?? '').isNotEmpty)
                                pw.Text('ח.פ/ת.ז: ${customer['hp']}', style: pw.TextStyle(fontSize: 9, color: textDark)),
                              if ((customer['address'] ?? '').isNotEmpty)
                                pw.Text('${customer['address']}', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                              if ((customer['phone'] ?? '').isNotEmpty)
                                pw.Text('${customer['phone']}', style: pw.TextStyle(fontSize: 9, color: textMuted)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: borderLight, width: 0.5),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('פרטי המסמך', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: brandBordeaux)),
                            pw.SizedBox(height: 8),
                            _metaRow('תאריך', _todayFormatted(), textMuted, textDark),
                            pw.SizedBox(height: 4),
                            _metaRow('תוקף הצעה', '30 יום', textMuted, textDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: brandBordeaux,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 5, child: pw.Text('תיאור הפריט / השירות', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9))),
                      pw.Expanded(flex: 1, child: pw.Text('כמות', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('מחיר יחידה', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 2, child: pw.Text('סה"כ', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.center)),
                    ],
                  ),
                ),

                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final qty = double.tryParse(item['quantity']?.toString() ?? '1') ?? 1.0;
                  final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                  final itemTotal = qty * price;
                  return pw.Container(
                    decoration: pw.BoxDecoration(
                      color: index % 2 == 0 ? PdfColors.white : brandBlush,
                      border: pw.Border(bottom: pw.BorderSide(color: borderLight, width: 0.5)),
                    ),
                    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 5, child: pw.Text(item['name']?.toString() ?? '', style: pw.TextStyle(fontSize: 9, color: textDark))),
                        pw.Expanded(flex: 1, child: pw.Text(qty.toStringAsFixed(0), style: pw.TextStyle(fontSize: 9, color: textDark), textAlign: pw.TextAlign.center)),
                        pw.Expanded(flex: 2, child: pw.Text('₪${price.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: textDark), textAlign: pw.TextAlign.center)),
                        pw.Expanded(flex: 2, child: pw.Text('₪${itemTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandBordeaux), textAlign: pw.TextAlign.center)),
                      ],
                    ),
                  );
                }),
                pw.SizedBox(height: 16),

                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(
                    width: 240,
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: brandBordeaux,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('סה"כ לפני מע"מ:', style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFD4A0A5))),
                            pw.Text('₪${beforeVat.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('מע"מ (${(vatRate * 100).toStringAsFixed(0)}%):', style: pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFFD4A0A5))),
                            pw.Text('₪${vatAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: PdfColors.white)),
                          ],
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 6),
                          child: pw.Divider(color: brandGold, thickness: 0.5),
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('סה"כ לתשלום:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: brandGold)),
                            pw.Text('₪${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: brandGold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),

                if (showPaymentTerms) ...[
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: brandBlush,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('תנאי תשלום', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandBordeaux)),
                        pw.SizedBox(height: 4),
                        pw.Text(paymentTerms, style: pw.TextStyle(fontSize: 8, color: textDark)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),
                ],

                if (showNotes) ...[
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: borderLight, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('הערות', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textMuted)),
                        pw.SizedBox(height: 4),
                        if (cleanNotes.isNotEmpty)
                          pw.Text(cleanNotes, style: pw.TextStyle(fontSize: 8, color: textDark)),
                        if (cleanNotes.isNotEmpty && defaultTerms.isNotEmpty)
                          pw.SizedBox(height: 4),
                        if (defaultTerms.isNotEmpty)
                          pw.Text(defaultTerms, style: pw.TextStyle(fontSize: 8, color: textDark)),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),
                ],

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSignatureLine('חתימת בית העסק', brandBordeaux, textMuted),
                    _buildSignatureLine('חתימת הלקוח לאישור', brandBordeaux, textMuted),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  // ==========================================
  // SHARED HELPERS
  // ==========================================
  static String _todayFormatted() {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    final y = now.year;
    return '$d/$m/$y';
  }

  static pw.Widget _buildSignatureLine(String label, PdfColor lineColor, PdfColor textColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 160,
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: lineColor, width: 1.5)),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(label, style: pw.TextStyle(fontSize: 8, color: textColor)),
      ],
    );
  }

  static pw.Widget _metaRow(String label, String value, PdfColor labelColor, PdfColor valueColor) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('$label:', style: pw.TextStyle(fontSize: 8, color: labelColor)),
        pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
