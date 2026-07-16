import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'pdf_template_base.dart';

Future<Uint8List> buildCleanCorporatePdf({
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
                        todayFormatted(),
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
                          metaRow('תאריך', todayFormatted(), textMuted, textDark),
                          pw.SizedBox(height: 4),
                          metaRow('תוקף הצעה', '30 יום', textMuted, textDark),
                          pw.SizedBox(height: 4),
                          metaRow('מס\' הצעה', '#${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}', textMuted, textDark),
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
                  buildSignatureLine('חתימת בית העסק', brandTeal, textMuted),
                  buildSignatureLine('חתימת הלקוח לאישור', brandTeal, textMuted),
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
