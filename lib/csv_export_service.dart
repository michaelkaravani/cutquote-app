import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cutquote/core/quote_status.dart';

class CsvExportService {
  static Future<void> exportMonthlyRevenue({
    required List<Map<String, dynamic>> allQuotes,
    required int year,
    required int month,
    double vatRate = 0.18,
    bool vatExempt = false,
  }) async {
    final filteredQuotes = _filterQuotesByMonth(allQuotes, year, month);

    if (filteredQuotes.isEmpty) {
      throw Exception('לא נמצאו הצעות מחיר עבור חודש זה');
    }

    final rows = <List<dynamic>>[
      if (vatExempt)
        [
          'מס\' הצעה',
          'תאריך',
          'שם לקוח',
          'עסק/ח"פ',
          'תיאור הפרויקט',
          'סטטוס',
          'סה"כ לתשלום',
        ]
      else
        [
          'מס\' הצעה',
          'תאריך',
          'שם לקוח',
          'עסק/ח"פ',
          'תיאור הפרויקט',
          'סטטוס',
          'סכום נטו',
          'מע"מ 18%',
          'סה"כ לתשלום',
        ],
    ];

    int index = 1;
    for (final quote in filteredQuotes) {
      final customerName =
          quote['customer']?['name']?.toString() ?? 'לקוח כללי';
      final businessId = quote['customer']?['hp']?.toString() ?? '';
      final statusStr = quote['status'] as String?;
      final status = QuoteStatus.fromString(statusStr).label;
      final date = quote['date']?.toString() ?? '';

      final items = List<Map<String, dynamic>>.from(quote['items'] ?? []);
      final description =
          items.map((e) => e['name']?.toString() ?? '').join(', ');

      double netAmount = 0;
      for (final item in items) {
        final price = (item['price'] as num?)?.toDouble() ?? 0;
        final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
        netAmount += price * quantity;
      }
      final discount = (quote['discount'] as num?)?.toDouble() ?? 0;
      netAmount -= discount;
      final vatAmount = vatExempt ? 0 : netAmount * vatRate;
      final totalAmount = vatExempt ? netAmount : netAmount + vatAmount;

      final quoteNumber = 1000 + index;

      rows.add([
        quoteNumber.toString(),
        date,
        customerName,
        businessId,
        description,
        status,
        if (vatExempt)
          totalAmount.toStringAsFixed(2)
        else ...[
          netAmount.toStringAsFixed(2),
          vatAmount.toStringAsFixed(2),
          totalAmount.toStringAsFixed(2),
        ],
      ]);

      index++;
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final bom = '\uFEFF';
    final csvWithBom = bom + csvString;

    final tempDir = await getTemporaryDirectory();
    final monthName = _getMonthName(month);
    final fileName = 'revenue_${monthName}_$year.csv';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(csvWithBom, encoding: utf8);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'דוח הכנסות חודשי - $monthName $year'),
    );
  }

  static List<Map<String, dynamic>> _filterQuotesByMonth(
    List<Map<String, dynamic>> quotes,
    int year,
    int month,
  ) {
    final result = quotes.where((q) {
      final dateStr = q['date']?.toString() ?? '';
      final parts = dateStr.split('/');
      if (parts.length != 3) return false;
      final qYear = int.tryParse(parts[2]);
      final qMonth = int.tryParse(parts[1]);
      return qYear == year && qMonth == month;
    }).toList();

    result.sort((a, b) {
      final aDate = a['date']?.toString() ?? '';
      final bDate = b['date']?.toString() ?? '';
      return bDate.compareTo(aDate);
    });

    return result;
  }

  static String _getMonthName(int month) {
    const months = [
      '',
      'ינואר',
      'פברואר',
      'מרץ',
      'אפריל',
      'מאי',
      'יוני',
      'יולי',
      'אוגוסט',
      'ספטמבר',
      'אוקטובר',
      'נובמבר',
      'דצמבר',
    ];
    return month >= 1 && month <= 12 ? months[month] : '$month';
  }
}
