import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cutquote/core/quote_status.dart';

class QuoteFilter {
  static List<Map<String, dynamic>> apply({
    required List<Map<String, dynamic>> quotes,
    required bool showOnlyPending,
    String? selectedCustomerFilter,
    String searchQuery = '',
  }) {
    var result = quotes.toList()
      ..sort((a, b) {
        final aDate = a['createdAt'] as Timestamp?;
        final bDate = b['createdAt'] as Timestamp?;
        if (aDate != null && bDate != null) return bDate.compareTo(aDate);
        return 0;
      });

    if (showOnlyPending) {
      result = result
          .where((q) => (q['status'] as String?) != QuoteStatus.paid.dbValue)
          .toList();
    }

    if (selectedCustomerFilter != null) {
      result = result
          .where(
            (q) {
              final c = q['customer'] as Map?;
              if (c == null) return false;
              final name = c['name']?.toString() ?? '';
              final phone = c['phone']?.toString() ?? '';
              return '$name|$phone' == selectedCustomerFilter;
            },
          )
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      result = result.where((q) {
        final title = (q['title']?.toString() ?? '').toLowerCase();
        final c = q['customer'] as Map?;
        final customerName = (c?['name']?.toString() ?? '').toLowerCase();
        return title.contains(query) || customerName.contains(query);
      }).toList();
    }

    return result;
  }

  static bool canLoadMore({
    required bool hasMore,
    required String searchQuery,
    required bool showOnlyPending,
    String? selectedCustomerFilter,
  }) {
    return hasMore &&
        searchQuery.trim().isEmpty &&
        !showOnlyPending &&
        selectedCustomerFilter == null;
  }
}
