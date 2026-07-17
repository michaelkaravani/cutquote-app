import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'pdf_template_base.dart';

Future<Uint8List> buildPremiumDarkPdf({
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

  final p = extractProfile(profile);
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

  final vatAmount = total * vatRate;
  final totalWithVat = total + vatAmount;

  Uint8List? logoBytes;
  if (logoPath != null) {
    try {
      final logoFile = File(logoPath);
      logoBytes = await logoFile.readAsBytes();
    } catch (_) {}
  }

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
                        if (logoBytes != null)
                          pw.Container(
                            margin: const pw.EdgeInsets.only(left: 14),
                            padding: const pw.EdgeInsets.all(2),
                            decoration: const pw.BoxDecoration(
                              color: PdfColors.white,
                              shape: pw.BoxShape.circle,
                            ),
                            child: pw.ClipOval(
                              child: pw.Image(
                                pw.MemoryImage(logoBytes),
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
                          metaRow('תאריך', todayFormatted(), textMuted, brandDark),
                          pw.SizedBox(height: 4),
                          metaRow('תוקף הצעה', '30 יום', textMuted, brandDark),
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
                          pw.Text('₪${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: PdfColors.white)),
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
                          pw.Text('₪${totalWithVat.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: brandGold)),
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
                  buildSignatureLine('חתימת בית העסק', brandGold, textMuted),
                  buildSignatureLine('חתימת הלקוח לאישור', brandGold, textMuted),
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
