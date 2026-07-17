import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'pdf_template_base.dart';

Future<Uint8List> buildNaturalCraftPdf({
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
                        if (logoBytes != null)
                          pw.Container(
                            margin: const pw.EdgeInsets.only(left: 14),
                            width: 48,
                            height: 48,
                            decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(8),
                            ),
                            child: pw.ClipOval(
                              child: pw.Image(
                                pw.MemoryImage(logoBytes),
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
                                metaRow('תאריך', todayFormatted(), textMuted, textDark),
                                pw.SizedBox(height: 4),
                                metaRow('תוקף', '30 יום', textMuted, textDark),
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
                                  pw.Text('₪${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: textDark)),
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
                                  pw.Text('₪${totalWithVat.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: brandOlive)),
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
                          buildSignatureLine('חתימת בית העסק', brandOlive, textMuted),
                          buildSignatureLine('חתימת הלקוח לאישור', brandOlive, textMuted),
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
