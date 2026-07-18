import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'pdf_template_base.dart';

/// Hebrew POC — Professional Blue Background Overlay template.
///
/// Loads `assets/PDF-desings/blue-desing.pdf` as a full-page background via
/// `Printing.raster()`, then overlays dynamic RTL Hebrew invoice
/// fields using a transparent `pw.Stack`.  All Hebrew text is forced
/// to the right edge using `pw.Align(alignment: pw.Alignment.centerRight)`.
Future<Uint8List> buildHebrewPocPdf({
  required Map<String, String>? customer,
  required List<Map<String, dynamic>> items,
  required double total,
  String? notes,
  Map<String, dynamic>? profile,
}) async {
  // ------------------------------------------------------------------
  // PALETTE — matching the blue-desing.pdf asset
  // ------------------------------------------------------------------
  final primaryDarkBlue = PdfColor.fromInt(0xFF0A2540);
  final accentCyan = PdfColor.fromInt(0xFF00D4B2);
  final bodyText = PdfColor.fromInt(0xFF333333);
  final white = PdfColors.white;
  final borderFaint = PdfColor.fromInt(0xFFEEEEEE);
  final rowAlt = PdfColor.fromInt(0xFFF0F9F8);

  final pdf = pw.Document();
  final font = await PdfGoogleFonts.assistantRegular();
  final boldFont = await PdfGoogleFonts.assistantBold();

  // ------------------------------------------------------------------
  // BACKGROUND PDF — render first page to PNG via platform channels
  // ------------------------------------------------------------------
  Uint8List? bgImageBytes;
  try {
    final bgData = await rootBundle.load('assets/PDF-desings/blue-desing.pdf');
    await for (final page
        in Printing.raster(bgData.buffer.asUint8List(), dpi: 300)) {
      bgImageBytes = await page.toPng();
      break;
    }
  } catch (_) {
    // Background unavailable — proceed without it
  }

  // ------------------------------------------------------------------
  // DATA
  // ------------------------------------------------------------------
  final p = extractProfile(profile);
  final businessName = p['businessName'] as String;
  final phone = p['phone'] as String;
  final email = p['email'] as String;
  final logoPath = p['logoPath'] as String?;
  final vatRate = p['vatRate'] as double;
  final vatExempt = p['vatExempt'] as bool;
  final defaultTerms = p['defaultPdfNotes'] as String;
  final paymentTerms = p['paymentTerms'] as String;
  final cleanNotes = (notes ?? '').trim();
  final showPaymentTerms = paymentTerms.isNotEmpty;
  final showNotes = cleanNotes.isNotEmpty || defaultTerms.isNotEmpty;

  final vatAmount = total * vatRate;
  final totalWithVat = vatExempt ? total : total + vatAmount;

  final issueDateStr = todayFormatted();
  final now = DateTime.now();
  final docNumber =
      'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-'
      '${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';

  Uint8List? logoBytes;
  if (logoPath != null) {
    try {
      logoBytes = await File(logoPath).readAsBytes();
    } catch (_) {}
  }

  const margin = 44.0;

  // ------------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------------

  pw.Widget headerCell(
    String text, {
    pw.Alignment alignment = pw.Alignment.center,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: pw.Align(
        alignment: alignment,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: primaryDarkBlue,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  pw.Widget tableRow({
    required String name,
    required String qty,
    required String price,
    required String total,
    bool isLast = false,
    PdfColor? rowColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: pw.BoxDecoration(
        color: rowColor,
        border: pw.Border(
          bottom: pw.BorderSide(color: borderFaint, width: 0.5),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                name,
                style: pw.TextStyle(fontSize: 9, color: bodyText),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text(
                qty,
                style: pw.TextStyle(fontSize: 9, color: bodyText),
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(price,
                      style: pw.TextStyle(
                          fontSize: 10, color: bodyText)),
                  pw.SizedBox(width: 2),
                  pw.Text('₪',
                      style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: bodyText)),
                ],
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(total,
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryDarkBlue)),
                  pw.SizedBox(width: 2),
                  pw.Text('₪',
                      style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryDarkBlue)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------
  // DOCUMENT
  // ------------------------------------------------------------------
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      theme: pw.ThemeData.withFont(base: font, bold: boldFont),
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Stack(
            children: [
              // Background PDF layer
              if (bgImageBytes != null)
                pw.Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: pw.Image(pw.MemoryImage(bgImageBytes),
                      fit: pw.BoxFit.fill),
                ),

              // Overlay content
              pw.Padding(
                padding: pw.EdgeInsets.all(margin),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // HEADER: business name + logo
                    // ==========================================
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                businessName,
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryDarkBlue,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                '$phone   |   $email',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  color: bodyText,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        if (logoBytes != null)
                          pw.Image(
                            pw.MemoryImage(logoBytes),
                            width: 180,
                          ),
                      ],
                    ),

                    pw.SizedBox(height: 36),

                    // ==========================================
                    // INVOICE TITLE + META
                    // ==========================================
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Client info -> left in RTL
                        pw.Expanded(
                          flex: 5,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  'לכבוד',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                    color: accentCyan,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.SizedBox(height: 6),
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  customer?['name'] ?? 'לקוח כללי',
                                  style: pw.TextStyle(
                                    fontSize: 13,
                                    fontWeight: pw.FontWeight.bold,
                                    color: primaryDarkBlue,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              if (customer != null) ...[
                                if ((customer['hp'] ?? '').isNotEmpty) ...[
                                  pw.SizedBox(height: 3),
                                  pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: pw.Text(
                                      'ח.פ/ת.ז: ${customer['hp']}',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        color: bodyText,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ),
                                ],
                                if ((customer['address'] ?? '').isNotEmpty)
                                  pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: pw.Text(
                                      customer['address']!,
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        color: bodyText,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ),
                                if ((customer['phone'] ?? '').isNotEmpty)
                                  pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: pw.Text(
                                      customer['phone']!,
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        color: bodyText,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 24),
                        // Invoice meta -> right in RTL
                        pw.Expanded(
                          flex: 5,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  'הצעת מחיר',
                                  style: pw.TextStyle(
                                    fontSize: 28,
                                    fontWeight: pw.FontWeight.bold,
                                    color: primaryDarkBlue,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  'QUOTE',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    color: bodyText,
                                    letterSpacing: 3,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  'מס:  $docNumber',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: primaryDarkBlue,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.SizedBox(height: 3),
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  'תאריך:  $issueDateStr',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    color: bodyText,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 30),

                    // ==========================================
                    // TABLE HEADER — transparent, thin bottom
                    // border in primaryDarkBlue
                    // ==========================================
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                              color: primaryDarkBlue, width: 0.8),
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: headerCell('תיאור',
                                alignment: pw.Alignment.centerRight),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: headerCell('כמות'),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: headerCell('מחיר יחידה'),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: headerCell('סה"כ',
                                alignment: pw.Alignment.centerLeft),
                          ),
                        ],
                      ),
                    ),

                    // ==========================================
                    // TABLE ROWS — faint gray row lines
                    // ==========================================
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final qty = double.tryParse(
                              item['quantity']?.toString() ?? '1') ??
                          1.0;
                      final price = double.tryParse(
                              item['price']?.toString() ?? '0') ??
                          0.0;
                      final itemTotal = qty * price;
                      final isLast = index == items.length - 1;
                      return tableRow(
                        name: item['name']?.toString() ?? '',
                        qty: qty.toStringAsFixed(0),
                        price: price.toStringAsFixed(2),
                        total: itemTotal.toStringAsFixed(2),
                        isLast: isLast,
                        rowColor: index % 2 == 1 ? rowAlt : null,
                      );
                    }),

                    pw.SizedBox(height: 24),

                    // ==========================================
                    // SUBTOTAL & VAT
                    // ==========================================
                    if (!vatExempt) ...[
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        child: pw.Row(
                          mainAxisAlignment:
                              pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              '₪${totalWithVat.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryDarkBlue,
                              ),
                            ),
                            pw.Text(
                              'סיכום ביניים:   ₪${total.toStringAsFixed(2)}   |   מע"מ: ₪${vatAmount.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 8,
                                color: bodyText,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 4),
                    ],

                    // ==========================================
                    // GRAND TOTAL — primaryDarkBlue label +
                    // bold amount, aligned bottom-right white
                    // space on the background
                    // ==========================================
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          vertical: 14, horizontal: 18),
                      decoration: pw.BoxDecoration(
                        color: primaryDarkBlue,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment:
                            pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                'סה"כ לתשלום',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                  color: white,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'GRAND TOTAL',
                                style: pw.TextStyle(
                                  fontSize: 7,
                                  color: PdfColor.fromInt(0xFFAABBCC),
                                  letterSpacing: 2,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ],
                          ),
                          pw.Row(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                (vatExempt ? total : totalWithVat)
                                    .toStringAsFixed(2),
                                style: pw.TextStyle(
                                  fontSize: 22,
                                  fontWeight: pw.FontWeight.bold,
                                  color: white,
                                ),
                              ),
                              pw.SizedBox(width: 2),
                              pw.Text('₪',
                                  style: pw.TextStyle(
                                      fontSize: 28,
                                      fontWeight: pw.FontWeight.bold,
                                      color: white)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.Spacer(),

                    // ==========================================
                    // NOTES + PAYMENT TERMS
                    // ==========================================
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 6,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (showNotes) ...[
                                pw.Container(
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                        color: primaryDarkBlue, width: 0.8),
                                    borderRadius: const pw.BorderRadius.all(
                                        pw.Radius.circular(6)),
                                  ),
                                  padding: const pw.EdgeInsets.all(12),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.end,
                                    children: [
                                      pw.Align(
                                        alignment:
                                            pw.Alignment.centerRight,
                                        child: pw.Text(
                                          'הערות',
                                          style: pw.TextStyle(
                                            fontSize: 9,
                                            fontWeight: pw.FontWeight.bold,
                                            color: primaryDarkBlue,
                                            letterSpacing: 1,
                                          ),
                                          textAlign: pw.TextAlign.right,
                                        ),
                                      ),
                                      pw.SizedBox(height: 4),
                                      if (cleanNotes.isNotEmpty)
                                        pw.Align(
                                          alignment:
                                              pw.Alignment.centerRight,
                                          child: pw.Text(
                                            cleanNotes,
                                            style: pw.TextStyle(
                                              fontSize: 8,
                                              color: bodyText,
                                            ),
                                            textAlign: pw.TextAlign.right,
                                          ),
                                        ),
                                      if (cleanNotes.isNotEmpty &&
                                          defaultTerms.isNotEmpty)
                                        pw.SizedBox(height: 4),
                                      if (defaultTerms.isNotEmpty)
                                        pw.Align(
                                          alignment:
                                              pw.Alignment.centerRight,
                                          child: pw.Text(
                                            defaultTerms,
                                            style: pw.TextStyle(
                                              fontSize: 8,
                                              color: bodyText,
                                            ),
                                            textAlign: pw.TextAlign.right,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                              if (showPaymentTerms) ...[
                                pw.SizedBox(height: 10),
                                pw.Align(
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    'תנאי תשלום: $paymentTerms',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      color: bodyText,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                              if (!showNotes && !showPaymentTerms)
                                pw.SizedBox(height: 40),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 24),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              pw.Container(
                                  height: 1.2,
                                  color: primaryDarkBlue),
                              pw.SizedBox(height: 6),
                              pw.Text(
                                'חתימה',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: accentCyan,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 20),
                  ],
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
