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
  final forestGreen = PdfColor.fromInt(0xFF1B4D3E);
  final lightAccent = PdfColor.fromInt(0xFFE5E5E5);
  final lightGray = PdfColor.fromInt(0xFFF3F3F3);
  final textDark = PdfColor.fromInt(0xFF222222);
  final textSecondary = PdfColor.fromInt(0xFF444444);
  final white = PdfColors.white;
  final borderLight = PdfColor.fromInt(0xFFDDDDDD);

  final pdf = pw.Document();
  final font = await PdfGoogleFonts.assistantRegular();
  final boldFont = await PdfGoogleFonts.assistantBold();

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

  const cp = 36.0;

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
            color: textDark,
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
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: pw.BoxDecoration(
        border: isLast
            ? pw.Border(
                bottom: pw.BorderSide(color: borderLight, width: 0.8),
              )
            : null,
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 5,
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                name,
                style: pw.TextStyle(fontSize: 9, color: textDark),
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
                style: pw.TextStyle(fontSize: 9, color: textSecondary),
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text(
                price,
                style: pw.TextStyle(fontSize: 9, color: textSecondary),
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                total,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: forestGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              pw.Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: pw.SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: pw.Polygon(
                    fillColor: forestGreen,
                    points: const [
                      PdfPoint(0, 0),
                      PdfPoint(0, 36),
                      PdfPoint(210, 36),
                      PdfPoint(210 * 0.35, 0),
                    ],
                  ),
                ),
              ),

              pw.Positioned(
                left: 0,
                top: 0,
                child: pw.SizedBox(
                  width: 180,
                  height: 110,
                  child: pw.Polygon(
                    fillColor: forestGreen,
                    points: const [
                      PdfPoint(0, 0),
                      PdfPoint(180, 0),
                      PdfPoint(0, 110),
                    ],
                  ),
                ),
              ),

              pw.Padding(
                padding: const pw.EdgeInsets.fromLTRB(cp, 40, cp, 60),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Stack(
                      children: [
                        pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Row(
                            mainAxisSize: pw.MainAxisSize.min,
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (logoBytes != null) ...[
                                pw.Container(
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
                                pw.SizedBox(width: 12),
                              ],
                              pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: pw.Text(
                                      businessName,
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                        fontWeight: pw.FontWeight.bold,
                                        color: textDark,
                                        letterSpacing: 0.5,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ),
                                  pw.SizedBox(height: 3),
                                  pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: pw.Text(
                                      '$phone   |   $email',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        color: textSecondary,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 40),

                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
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
                                    color: forestGreen,
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
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: textDark,
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
                                        color: textSecondary,
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
                                        color: textSecondary,
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
                                        color: textSecondary,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 24),
                        pw.Expanded(
                          flex: 5,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  'חשבונית',
                                  style: pw.TextStyle(
                                    fontSize: 30,
                                    fontWeight: pw.FontWeight.bold,
                                    color: forestGreen,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  'INVOICE',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    color: textSecondary,
                                    letterSpacing: 3,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  'מספר: $docNumber',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: textDark,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.SizedBox(height: 3),
                              pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(
                                  'תאריך: $issueDateStr',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    color: textSecondary,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 32),

                    pw.Container(
                      decoration: pw.BoxDecoration(
                        color: lightGray,
                        border: pw.Border(
                          top: pw.BorderSide(
                              color: forestGreen, width: 1.4),
                          bottom: pw.BorderSide(
                              color: forestGreen, width: 0.8),
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
                        price: '₪${price.toStringAsFixed(2)}',
                        total: '₪${itemTotal.toStringAsFixed(2)}',
                        isLast: isLast,
                      );
                    }),

                    pw.SizedBox(height: 28),

                    if (!vatExempt) ...[
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(
                                color: PdfColor.fromInt(0xFFDDDDDD),
                                width: 0.5),
                          ),
                        ),
                        padding:
                            const pw.EdgeInsets.symmetric(vertical: 8),
                        child: pw.Row(
                          mainAxisAlignment:
                              pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Align(
                              alignment: pw.Alignment.centerLeft,
                              child: pw.Text(
                                '₪${totalWithVat.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: textDark,
                                ),
                                textAlign: pw.TextAlign.left,
                              ),
                            ),
                            pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                'סיכום ביניים:   ₪${total.toStringAsFixed(2)}   |   מע"מ: ₪${vatAmount.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  color: textSecondary,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 6),
                    ],

                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(
                              color: PdfColor.fromInt(0xFFDDDDDD),
                              width: 0.5),
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 2,
                            child: pw.Container(
                              color: forestGreen,
                              padding: const pw.EdgeInsets.symmetric(
                                  vertical: 22, horizontal: 18),
                              child: pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Text(
                                  '₪${(vatExempt ? total : totalWithVat).toStringAsFixed(2)}',
                                  style: pw.TextStyle(
                                    fontSize: 22,
                                    fontWeight: pw.FontWeight.bold,
                                    color: white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Container(
                              color: lightAccent,
                              padding: const pw.EdgeInsets.symmetric(
                                  vertical: 22, horizontal: 18),
                              child: pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.end,
                                mainAxisSize: pw.MainAxisSize.min,
                                children: [
                                  pw.Text(
                                    'סה"כ לתשלום',
                                    style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      color: textDark,
                                      letterSpacing: 1,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                  pw.SizedBox(height: 3),
                                  pw.Text(
                                    'GRAND TOTAL',
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      color: textSecondary,
                                      letterSpacing: 2,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                  if (!vatExempt) ...[
                                    pw.SizedBox(height: 6),
                                    pw.Text(
                                      'כולל מע"מ (${(vatRate * 100).toStringAsFixed(0)}%)',
                                      style: pw.TextStyle(
                                        fontSize: 7,
                                        color: textSecondary,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ] else ...[
                                    pw.SizedBox(height: 6),
                                    pw.Text(
                                      'עוסק פטור',
                                      style: pw.TextStyle(
                                        fontSize: 7,
                                        color: textSecondary,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    pw.Spacer(),

                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 6,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (showNotes) ...[
                                pw.Align(
                                  alignment: pw.Alignment.centerRight,
                                  child: pw.Text(
                                    'הערות',
                                    style: pw.TextStyle(
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold,
                                      color: forestGreen,
                                      letterSpacing: 1,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Container(
                                  width: 3,
                                  height: 32,
                                  decoration: pw.BoxDecoration(
                                    color: lightAccent,
                                    borderRadius: const pw.BorderRadius.only(
                                      topRight: pw.Radius.circular(3),
                                      bottomRight: pw.Radius.circular(3),
                                    ),
                                  ),
                                ),
                                pw.SizedBox(height: 6),
                                if (cleanNotes.isNotEmpty)
                                  pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: pw.Text(
                                      cleanNotes,
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        color: textDark,
                                      ),
                                      textAlign: pw.TextAlign.right,
                                    ),
                                  ),
                                if (cleanNotes.isNotEmpty &&
                                    defaultTerms.isNotEmpty)
                                  pw.SizedBox(height: 4),
                                if (defaultTerms.isNotEmpty)
                                  pw.Align(
                                    alignment: pw.Alignment.centerRight,
                                    child: pw.Text(
                                      defaultTerms,
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        color: textDark,
                                      ),
                                      textAlign: pw.TextAlign.right,
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
                                      color: textSecondary,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 24),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Align(
                                alignment: pw.Alignment.centerLeft,
                                child: pw.Text(
                                  'חתימה',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                    color: forestGreen,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: pw.TextAlign.left,
                                ),
                              ),
                              pw.SizedBox(height: 6),
                              pw.Container(
                                height: 1,
                                color: borderLight,
                              ),
                              pw.SizedBox(height: 20),
                              pw.Container(height: 1, color: borderLight),
                            ],
                          ),
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 30),
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
