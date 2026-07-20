import 'package:flutter/material.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/pdf_template_notifier.dart';

Future<void> consolidateCustomerQuotesAsPdf({
  required BuildContext context,
  required Map<String, String> customer,
  required List<Map<String, dynamic>> allQuotes,
  required Future<void> Function() onEnsureAllQuotesLoaded,
  required Future<Map<String, dynamic>?> Function() onLoadProfile,
  required PdfTemplateNotifier pdfTemplateNotifier,
}) async {
  await onEnsureAllQuotesLoaded();
  if (!context.mounted) return;

  final customerQuotes = allQuotes
      .where(
        (quote) {
          final qc = quote['customer'] as Map?;
          if (qc == null) return false;
          return qc['name'] == customer['name'] &&
              qc['phone'] == customer['phone'];
        },
      )
      .toList();

  if (customerQuotes.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('לא נמצאו הצעות מחיר שמורות עבור לקוח זה'),
      ),
    );
    return;
  }

  final Map<String, Map<String, dynamic>> consolidatedItems = {};

  for (var quote in customerQuotes) {
    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      quote['items'] ?? [],
    );
    for (var item in items) {
      final String name = (item['name'] as String?) ?? '';
      final int quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      final double price = (item['price'] as num?)?.toDouble() ?? 0.0;

      if (consolidatedItems.containsKey(name)) {
        final existing = consolidatedItems[name]!;
        existing['quantity'] = ((existing['quantity'] as num?)?.toInt() ?? 0) + quantity;
      } else {
        consolidatedItems[name] = {
          'name': name,
          'quantity': quantity,
          'price': price,
        };
      }
    }
  }

  final List<Map<String, dynamic>> finalItems = consolidatedItems.values.toList();

  double finalTotal = 0;
  for (var item in finalItems) {
    finalTotal += ((item['price'] as num?)?.toDouble() ?? 0) * ((item['quantity'] as num?)?.toDouble() ?? 0);
  }

  final freshProfile = await onLoadProfile();
  if (!context.mounted) return;
  final profile = freshProfile;

  await PdfService.generateAndShareQuote(
    customer: customer,
    items: finalItems,
    total: finalTotal,
    filename: 'quote_${customer['name'] ?? 'general'}.pdf',
    notes: null,
    profile: profile,
    templateStyle: pdfTemplateNotifier.currentTemplate,
  );
}
