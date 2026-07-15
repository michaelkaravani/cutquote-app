import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<Uint8List> generateQuotePdfBytes({
    required Map<String, String>? customer,
    required List<Map<String, dynamic>> items,
    required double total,
    String? notes,
    Map<String, dynamic>? profile,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.assistantRegular();
    final boldFont = await PdfGoogleFonts.assistantBold();

    final businessName = profile?['businessName'] as String? ??
        'מיכאל פרסיז\'ן ארט';
    final phone = profile?['phone'] as String? ?? '';
    final email =
        profile?['email'] as String? ?? 'michaelprecisionart@gmail.com';
    final logoPath = profile?['logoPath'] as String?;
    final cleanQuoteNotes = (notes ?? '').trim();
    final defaultTerms = profile?['defaultPdfNotes'] as String? ?? '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        if (logoPath != null && File(logoPath).existsSync())
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 10),
                            child: pw.Image(
                              pw.MemoryImage(
                                File(logoPath).readAsBytesSync(),
                              ),
                              width: 80,
                              height: 80,
                            ),
                          ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              businessName,
                              style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900,
                              ),
                            ),
                            pw.Text(
                              [phone, email]
                                  .where((s) => s.isNotEmpty)
                                  .join(' | '),
                              style: const pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.Text(
                      'הצעת מחיר',
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey900,
                      ),
                    ),
                  ],
                ),
                pw.Divider(thickness: 2, color: PdfColors.blue900),
                pw.SizedBox(height: 20),

                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'לכבוד:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'שם הלקוח / העסק: ${customer?['name'] ?? 'לקוח כללי'}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (customer != null) ...[
                        pw.Text(
                          'ח.פ / ת.ז: ${customer['hp']}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'כתובת: ${customer['address']}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'טלפון: ${customer['phone']}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue100,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'תיאור הפריט / השירות',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'כמות',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'מחיר יחידה',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'סה"כ',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ...items.map((item) {
                      final double itemTotal =
                          item['price'] * item['quantity'];
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(item['name']),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${item['quantity']}',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '₪${item['price'].toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '₪${itemTotal.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 30),

                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    child: pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          'סה"כ לתשלום: ',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '₪${total.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (cleanQuoteNotes.isNotEmpty) ...[
                  pw.SizedBox(height: 15),
                  pw.Directionality(
                    textDirection: pw.TextDirection.rtl,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.grey300,
                          width: 1,
                        ),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'הערות:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(cleanQuoteNotes),
                        ],
                      ),
                    ),
                  ),
                ],
                if (defaultTerms.isNotEmpty) ...[
                  pw.SizedBox(height: 12),
                  pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                  pw.SizedBox(height: 8),
                  pw.Directionality(
                    textDirection: pw.TextDirection.rtl,
                    child: pw.Text(
                      defaultTerms,
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
                pw.SizedBox(height: 20),
                pw.Directionality(
                  textDirection: pw.TextDirection.rtl,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Column(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Divider(
                              thickness: 1,
                              color: PdfColors.grey400,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'חתימת בית העסק',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Container(
                            width: 120,
                            child: pw.Divider(
                              thickness: 1,
                              color: PdfColors.grey400,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'חתימת הלקוח לאישור',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
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

  static Future<void> generateAndShareQuote({
    required Map<String, String>? customer,
    required List<Map<String, dynamic>> items,
    required double total,
    required String filename,
    String? notes,
    Map<String, dynamic>? profile,
  }) async {
    final bytes = await generateQuotePdfBytes(
      customer: customer,
      items: items,
      total: total,
      notes: notes,
      profile: profile,
    );
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
