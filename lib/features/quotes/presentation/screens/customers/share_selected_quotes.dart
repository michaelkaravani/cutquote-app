import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/pdf_template_notifier.dart';
import 'package:cutquote/core/firestore_service.dart';

Future<void> shareSelectedQuotes({
  required BuildContext context,
  required List<Map<String, dynamic>> allQuotes,
  required Set<String> selectedQuoteIds,
  required String businessName,
  required Map<String, dynamic>? profile,
  required PdfTemplateNotifier pdfTemplateNotifier,
  required VoidCallback onProgress,
  required VoidCallback onExitSelection,
}) async {
  final selected = allQuotes
      .where((q) => selectedQuoteIds.contains(q['id']))
      .toList();
  if (selected.isEmpty) return;

  var sharingProgress = 0;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'מכין קבצים... ($sharingProgress/${selected.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  try {
    final totalAmount = selected.fold<double>(
      0,
      (prev, q) => prev + ((q['total'] as num?)?.toDouble() ?? 0),
    );
    final senderName =
        businessName.isNotEmpty ? businessName : 'העסק';
    final message =
        'שיתוף ${selected.length} הצעות מחיר מסך כולל של ₪${totalAmount.toStringAsFixed(0)}. תודה, $senderName.';

    await Clipboard.setData(ClipboardData(text: message));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('הודעת השיתוף הועתקה ללוח! הדבק אותה בוואטסאפ'),
          duration: Duration(seconds: 3),
        ),
      );
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    final freshProfile = await FirestoreService.loadProfile(uid);
    final effectiveProfile = freshProfile ?? profile;

    final files = <XFile>[];
    final tempDir = await getTemporaryDirectory();

    for (int i = 0; i < selected.length; i++) {
      final q = selected[i];
      final bytes = await PdfService.generateQuotePdfBytes(
        customer: q['customer'] is Map
            ? Map<String, String>.from(q['customer'] as Map)
            : null,
        items: List<Map<String, dynamic>>.from(q['items'] ?? []),
        total: (q['total'] as num?)?.toDouble() ?? 0.0,
        notes: q['notes'] as String?,
        profile: effectiveProfile,
        templateStyle: pdfTemplateNotifier.currentTemplate,
      );

      final title = q['title']?.toString() ?? 'הצעת מחיר';
      final safeName = title.replaceAll(
        RegExp(r'[^\u0590-\u05FF\w\s\-]'),
        '',
      ).trim();
      final file = File('${tempDir.path}/${safeName}_$i.pdf');
      await file.writeAsBytes(bytes);
      files.add(XFile(file.path));

      sharingProgress = i + 1;
      if (context.mounted) {
        (context as Element).markNeedsBuild();
      }
    }

    if (!context.mounted) return;
    Navigator.of(context).pop(); 

    await SharePlus.instance.share(ShareParams(files: files));

    for (final f in files) {
      final file = File(f.path);
      Future.delayed(const Duration(seconds: 10), () async {
        try {
          if (await file.exists()) await file.delete();
        } catch (_) {}
      });
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשיתוף ההצעות: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  } finally {
    if (context.mounted) {
      onExitSelection();
    }
  }
}
