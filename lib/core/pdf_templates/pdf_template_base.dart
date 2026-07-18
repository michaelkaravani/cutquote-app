import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;

Map<String, dynamic> extractProfile(Map<String, dynamic>? profile) {
  return {
    'businessName': profile?['businessName'] as String? ?? 'העסק',
    'phone': profile?['phone'] as String? ?? '',
    'email': profile?['email'] as String? ?? '',
    'logoPath': profile?['logoPath'] as String?,
    'vatRate': (profile?['vatRate'] as num?)?.toDouble() ?? 0.17,
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

/// Processes a logo image to preserve PNG transparency in PDFs
/// 
/// Takes a file path to a PNG logo and re-encodes it to ensure
/// the alpha channel is properly preserved when rendered in PDF format.
/// 
/// Returns processed image bytes, or null if processing fails.
Future<Uint8List?> processLogoWithTransparency(String logoPath) async {
  try {
    final logoFile = File(logoPath);
    final originalBytes = await logoFile.readAsBytes();
    
    // Decode the PNG image
    final decodedImage = img.decodeImage(originalBytes);
    
    if (decodedImage == null) {
      // Fallback: return original bytes if decoding fails
      return originalBytes;
    }
    
    // Re-encode as PNG with explicit alpha channel preservation
    final processedBytes = img.encodePng(decodedImage);
    
    return Uint8List.fromList(processedBytes);
  } catch (e) {
    // Return null if any error occurs (template will handle missing logo gracefully)
    return null;
  }
}
