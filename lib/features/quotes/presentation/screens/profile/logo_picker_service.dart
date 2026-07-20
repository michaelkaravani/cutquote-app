import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class LogoPickerException implements Exception {
  final String message;
  const LogoPickerException(this.message);

  @override
  String toString() => message;
}

Future<String?> pickBusinessLogo() async {
  try {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['svg', 'png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.single.path == null) return null;

    final sourceFile = File(result.files.single.path!);
    final extension = result.files.single.extension?.toLowerCase();
    final size = result.files.single.size;

    if (size > 5 * 1024 * 1024) {
      throw const LogoPickerException('הקובץ גדול מדי. המגבלה היא 5MB.');
    }

    var isValid = false;
    if (extension == 'svg') {
      final svgContent = await sourceFile.readAsString();
      final svgRootPattern = RegExp(r'<svg(?:\s|>)', caseSensitive: false);
      isValid = svgRootPattern.hasMatch(svgContent) && svgContent.toLowerCase().contains('</svg>');
    } else if (extension == 'png' || extension == 'jpg' || extension == 'jpeg') {
      isValid = img.decodeImage(await sourceFile.readAsBytes()) != null;
    }

    if (!isValid) {
      throw const LogoPickerException('קובץ הלוגו פגום או אינו בפורמט נתמך.');
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'business_logo_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final savedPath = '${dir.path}/$fileName';

    await sourceFile.copy(savedPath);

    return savedPath;
  } on LogoPickerException {
    rethrow;
  } catch (e) {
    throw LogoPickerException('שגיאה בבחירת הלוגו: $e');
  }
}
