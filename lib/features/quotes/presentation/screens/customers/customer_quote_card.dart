import 'package:flutter/material.dart';
import 'package:cutquote/features/quotes/presentation/screens/customers/quote_status_chip.dart';

class CustomerQuoteCard extends StatelessWidget {
  final Map<String, dynamic> quote;
  final bool isSelectionMode;
  final Set<String> selectedQuoteIds;
  final void Function(String? quoteId) onToggleSelection;
  final void Function(Map<String, dynamic> quote) onCallCustomer;
  final void Function(Map<String, dynamic> quote) onEditQuote;
  final void Function(Map<String, dynamic> quote) onShareQuote;
  final void Function(Map<String, dynamic> quote) onDeleteQuote;
  final Function(String quoteId, String newStatus)? onUpdateQuoteStatus;

  const CustomerQuoteCard({
    super.key,
    required this.quote,
    required this.isSelectionMode,
    required this.selectedQuoteIds,
    required this.onToggleSelection,
    required this.onCallCustomer,
    required this.onEditQuote,
    required this.onShareQuote,
    required this.onDeleteQuote,
    this.onUpdateQuoteStatus,
  });

  @override
  Widget build(BuildContext context) {
    final items = (quote['items'] as List?)?.cast<dynamic>() ?? [];

    return GestureDetector(
      onLongPress: () => onToggleSelection(quote['id']),
      onTap: isSelectionMode ? () => onToggleSelection(quote['id']) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            right: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isSelectionMode)
                  Checkbox(
                    value: selectedQuoteIds.contains(quote['id']),
                    onChanged: (_) => onToggleSelection(quote['id']),
                    activeColor: Theme.of(context).colorScheme.secondary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                Expanded(
                  child: Text(
                    quote['title']?.toString() ?? 'הצעת מחיר',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'סה״כ: ₪${(quote['total'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'תאריך: ${quote['date'] ?? '—'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QuoteStatusChip(
                        quote: quote,
                        onUpdateQuoteStatus: onUpdateQuoteStatus,
                        isSelectionMode: isSelectionMode,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${items.length} פריטים',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isSelectionMode)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (QuoteStatusChip.isQuoteOverdue(quote) &&
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
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        onPressed: () => onDeleteQuote(quote),
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
