import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Map<String, dynamic> extractProfile(Map<String, dynamic>? profile) {
  return {
    'businessName': profile?['businessName'] as String? ?? 'העסק',
    'phone': profile?['phone'] as String? ?? '',
    'email': profile?['email'] as String? ?? '',
    'logoPath': profile?['logoPath'] as String?,
    'vatRate': (profile?['vatRate'] as num?)?.toDouble() ?? 0.18,
    'vatExempt': profile?['vatExempt'] == true,
    'defaultPdfNotes': profile?['defaultPdfNotes'] as String? ?? '',
    'paymentTerms': profile?['paymentTerms'] as String? ?? '',
  };
}

String todayFormatted() {
  final now = DateTime.now();
  final d = now.day.toString().padLeft(2, '0');
  final m = now.month.toString().padLeft(2, '0');
  final y = now.year;
  return '$d/$m/$y';
}

pw.Widget buildSignatureLine(String label, PdfColor lineColor, PdfColor textColor) {
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

pw.Widget metaRow(String label, String value, PdfColor labelColor, PdfColor valueColor) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text('$label:', style: pw.TextStyle(fontSize: 8, color: labelColor)),
      pw.Text(value, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: valueColor)),
    ],
  );
}
