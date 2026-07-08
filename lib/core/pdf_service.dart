import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateAndShareQuote({
    required Map<String, String>? customer,
    required List<Map<String, dynamic>> items,
    required double total,
  }) async {
    final pdf = pw.Document();

    // טעינת פונט שתומך בעברית בצורה מלאה מהמערכת
    final font = await PdfGoogleFonts.assistantRegular();
    final boldFont = await PdfGoogleFonts.assistantBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl, // הופך את כל הדף לעברית
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start, // 🔥 תוקן: נוספו נקודתיים
              children: [
                // כותרת העסק שלך
                pw.Row(
                  mainAxisAlignment: pw
                      .MainAxisAlignment
                      .spaceBetween, // 🔥 תוקן: נוספו נקודתיים
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw
                          .CrossAxisAlignment
                          .start, // 🔥 תוקן: נוספו נקודתיים
                      children: [
                        pw.Text(
                          'מיכאל פרסיז\'ן ארט',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          'Kfar Yona | michaelprecisionart@gmail.com',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
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

                // פרטי הלקוח המשויך
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start, // 🔥 תוקן: נוספו נקודתיים
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

                // טבלת הפריטים
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 0.5,
                  ),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4), // שם הפריט
                    1: const pw.FlexColumnWidth(1), // כמות
                    2: const pw.FlexColumnWidth(1.5), // מחיר יחידה
                    3: const pw.FlexColumnWidth(1.5), // סה"כ שורה
                  },
                  children: [
                    // שורת כותרת הטבלה
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue100,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'תיאור הפריט / השירות',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'כמות',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'מחיר יחידה',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'סה"כ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    // שורות הנתונים
                    ...items.map((item) {
                      final double itemTotal = item['price'] * item['quantity'];
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
                    }), // 🔥 תוקן: הורדנו את ה-toList() המיותר שהציק באזהרות
                  ],
                ),
                pw.SizedBox(height: 30),

                // סה"כ סופי לתשלום לתחתית הדף
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
              ],
            ),
          );
        },
      ),
    );

    // פתיחת חלונית שיתוף והדפסה של מערכת ההפעלה (וואטסאפ, מייל וכד')
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'quote_${customer?['name'] ?? 'general'}.pdf',
    );
  }
}
