import 'package:flutter/material.dart';
import 'package:cutquote/core/quote_actions.dart';
import 'package:cutquote/core/quote_status.dart';

class QuoteCard extends StatelessWidget {
  final Map<String, dynamic> quote;
  final List<Map<String, dynamic>> quotes;
  final bool Function(Map<String, dynamic> quote) isQuoteOverdue;
  final int Function(Map<String, dynamic> quote) overdueDays;
  final void Function(BuildContext context, Map<String, dynamic> quote) onShowStatusPicker;
  final void Function(Map<String, dynamic> quote) onCallCustomer;
  final void Function(Map<String, dynamic> quote) onEditQuote;
  final void Function(Map<String, dynamic> quote) onShareQuote;
  final void Function(int index) onConfirmDeleteQuote;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.quotes,
    required this.isQuoteOverdue,
    required this.overdueDays,
    required this.onShowStatusPicker,
    required this.onCallCustomer,
    required this.onEditQuote,
    required this.onShareQuote,
    required this.onConfirmDeleteQuote,
  });

  @override
  Widget build(BuildContext context) {
    final customerName = (quote['customer'] as Map?)?['name']?.toString() ?? 'לקוח כללי';

    double total = 0;
    if (quote['items'] != null) {
      for (var item in quote['items']) {
        total +=
            ((item['price'] as num?)?.toDouble() ?? 0) * ((item['quantity'] as num?)?.toDouble() ?? 1);
      }
    }

    return Card(
      key: ValueKey(quote['id']?.toString()),
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.description_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${quote['title'] ?? 'הצעת מחיר'} #${QuoteActions.displayNumber(quote, quotes)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'לקוח: $customerName',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(0)} ₪',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: GestureDetector(
                    onTap: () => onShowStatusPicker(context, quote),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isQuoteOverdue(quote)
                            ? Colors.red.shade50
                            : QuoteStatus.fromString(
                                quote['status'] as String?,
                              ).displayColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (isQuoteOverdue(quote)) ...[
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: Colors.red.shade800,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              isQuoteOverdue(quote)
                                  ? 'נדרש מענה (${overdueDays(quote)} ימים) ⏳'
                                  : QuoteStatus.fromString(
                                      quote['status'] as String?,
                                    ).label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isQuoteOverdue(quote)
                                    ? Colors.red.shade800
                                    : QuoteStatus.fromString(
                                        quote['status'] as String?,
                                      ).displayColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isQuoteOverdue(quote) &&
                        quote['customer']?['phone']?.toString() != null) ...[
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.phone, size: 18, color: Colors.green),
                        onPressed: () => onCallCustomer(quote),
                      ),
                      const SizedBox(width: 4),
                    ],
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      onPressed: () => onEditQuote(quote),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.share, size: 18, color: Colors.teal),
                      onPressed: () => onShareQuote(quote),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onPressed: () {
                        final idx = quotes.indexWhere((q) => q['id'] == quote['id']);
                        if (idx != -1) {
                          onConfirmDeleteQuote(idx);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
