import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'pdf_template_base.dart';

Future<Uint8List> buildMinimalStonePdf({
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
                todayFormatted(),
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
                  buildSignatureLine('חתימת בית העסק', brandTerracotta, textMuted),
                  buildSignatureLine('חתימת הלקוח לאישור', brandTerracotta, textMuted),
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
