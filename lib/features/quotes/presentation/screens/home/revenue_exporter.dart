import 'package:flutter/material.dart';
import 'package:cutquote/month_picker_dialog.dart';
import 'package:cutquote/csv_export_service.dart';

Future<void> exportMonthlyRevenue({
  required BuildContext context,
  required Future<void> Function() onEnsureAllQuotesLoaded,
  required List<Map<String, dynamic>> allQuotes,
  required double defaultVatRate,
  required bool vatExempt,
}) async {
  final result = await showMonthPickerDialog(context);
  if (result == null) return;

  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    ),
  );

  try {
    await onEnsureAllQuotesLoaded();
    if (!context.mounted) return;

    final vatRate = vatExempt ? 0.0 : defaultVatRate;
    await CsvExportService.exportMonthlyRevenue(
      allQuotes: allQuotes,
      year: result.year,
      month: result.month,
      vatRate: vatRate,
      vatExempt: vatExempt,
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.redAccent,
      ),
    );
  } finally {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
