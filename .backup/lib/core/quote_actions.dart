import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cutquote/core/navigation.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/pdf_template_notifier.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder_screen.dart';

class QuoteActions {
  static void editQuote({
    required BuildContext context,
    required Map<String, dynamic> quote,
    required Map<String, dynamic>? profile,
    required List<Map<String, String>> customers,
    required List<Map<String, dynamic>> catalog,
    required void Function(Map<String, dynamic>) onAddToCatalog,
    required void Function(Map<String, dynamic>) onSaveQuote,
    required void Function(int) onDeleteFromCatalog,
    required void Function(Map<String, dynamic>) onUpdateQuote,
  }) {
    context.push(QuoteBuilderScreen(
      profile: profile,
      customers: customers,
      catalog: catalog,
      onAddToCatalog: onAddToCatalog,
      onSaveQuote: onSaveQuote,
      onDeleteFromCatalog: onDeleteFromCatalog,
      initialQuote: quote,
      onUpdateQuote: onUpdateQuote,
    ));
  }

  static Future<void> callCustomer(
    BuildContext context,
    Map<String, dynamic> quote,
  ) async {
    final phone = quote['customer']?['phone']?.toString();
    if (phone == null || phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('לא ניתן לחייג למספר $cleanPhone'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  static Future<void> shareQuote({
    required BuildContext context,
    required Map<String, dynamic> quote,
    required List<Map<String, dynamic>> allQuotes,
    required String businessName,
    required String uid,
    required Map<String, dynamic>? profile,
  }) async {
    final index = allQuotes.indexWhere((q) => q['id'] == quote['id']);
    final customerName = (quote['customer'] as Map?)?['name']?.toString() ?? 'לקוח';
    final quoteNumber = index + 1001;
    final quoteTitle = quote['title']?.toString() ?? 'הצעת מחיר';
    final total = (quote['total'] as num?)?.toDouble() ?? 0.0;
    final totalFormatted = total.toStringAsFixed(0);
    final senderName = businessName.isNotEmpty ? businessName : 'העסק';

    final message =
        'היי $customerName 👋 מצורפת הצעת מחיר מס\' $quoteNumber עבור \'$quoteTitle\' על סך $totalFormatted ₪. נשמח לאישורך כדי שנוכל להתקדם לייצור! תודה, $senderName.';

    await Clipboard.setData(ClipboardData(text: message));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('הודעת השיתוף הועתקה ללוח! הדבק אותה בוואטסאפ'),
        duration: Duration(seconds: 3),
      ),
    );

    final customer = Map<String, String>.from(quote['customer'] ?? {});
    final freshProfile = await FirestoreService.loadProfile(uid);
    if (!context.mounted) return;
    final effectiveProfile = freshProfile ?? profile;

    await PdfService.generateAndShareQuote(
      customer: customer,
      items: List<Map<String, dynamic>>.from(quote['items'] ?? []),
      total: (quote['total'] as num?)?.toDouble() ?? 0.0,
      filename: 'quote_${customer['name'] ?? 'general'}.pdf',
      notes: quote['notes'] as String?,
      profile: effectiveProfile,
      templateStyle: pdfTemplateNotifier.currentTemplate,
    );
  }

  static Future<void> updateQuoteStatus({
    required BuildContext context,
    required String uid,
    required Map<String, dynamic> quote,
    required String newStatus,
    required void Function(String quoteId, String newStatus) onUpdated,
  }) async {
    final docId = quote['id'] as String?;
    if (docId == null) return;

    try {
      await FirestoreService.updateQuote(uid, docId, {'status': newStatus});
      if (!context.mounted) return;
      onUpdated(docId, newStatus);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בעדכון סטטוס: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  static Future<void> deleteQuoteByIndex({
    required BuildContext context,
    required String uid,
    required List<Map<String, dynamic>> allQuotes,
    required int index,
    required void Function(int removedIndex) onRemoved,
    required void Function(int index, Map<String, dynamic> quote) onRollback,
  }) async {
    final quote = allQuotes[index];
    final docId = quote['id'];
    onRemoved(index);
    if (docId == null) return;
    try {
      await FirestoreService.deleteQuote(uid, docId);
    } catch (e) {
      if (!context.mounted) return;
      onRollback(index, quote);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה במחיקת הצעת המחיר: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  static void confirmDeleteQuote(
    BuildContext context,
    int index,
    void Function(int index) onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'מחיקת הצעת מחיר',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'האם אתה בטוח שברצונך למחוק את הצעת המחיר? הפעולה אינה הפיכה.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ביטול',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm(index);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('מחיקה'),
              ),
            ],
          ),
        );
      },
    );
  }
}
