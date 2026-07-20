import 'package:flutter/material.dart';
import 'customer_quote_card.dart';

class CustomerExpansionCard extends StatelessWidget {
  final Map<String, String> customer;
  final List<Map<String, dynamic>> quotes;
  final int index;
  final bool isSelectionMode;
  final Set<String> selectedQuoteIds;
  final void Function(String? quoteId) onToggleSelection;
  final void Function(Map<String, dynamic> quote) onCallCustomer;
  final void Function(Map<String, dynamic> quote) onEditQuote;
  final void Function(Map<String, dynamic> quote) onShareQuote;
  final void Function(Map<String, dynamic> quote) onDeleteQuote;
  final Function(String quoteId, String newStatus)? onUpdateQuoteStatus;
  final void Function(Map<String, String> customer) onGenerateSummary;
  final void Function(int index, String customerName) onConfirmDeleteCustomer;
  final void Function(Map<String, String> customer) onEditCustomer;

  const CustomerExpansionCard({
    super.key,
    required this.customer,
    required this.quotes,
    required this.index,
    required this.isSelectionMode,
    required this.selectedQuoteIds,
    required this.onToggleSelection,
    required this.onCallCustomer,
    required this.onEditQuote,
    required this.onShareQuote,
    required this.onDeleteQuote,
    this.onUpdateQuoteStatus,
    required this.onGenerateSummary,
    required this.onConfirmDeleteCustomer,
    required this.onEditCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        iconColor: Theme.of(context).colorScheme.secondary,
        collapsedIconColor: Theme.of(context).colorScheme.onSurface,
        title: Text(
          customer['name'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'ח.פ: ${customer['hp'] ?? '—'} | טלפון: ${customer['phone'] ?? '—'}',
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'כתובת: ${customer['address'] ?? ''}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          if (quotes.isNotEmpty) ...[
            Text(
              'הצעות מחיר',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: quotes.map((quote) {
                return CustomerQuoteCard(
                  quote: quote,
                  isSelectionMode: isSelectionMode,
                  selectedQuoteIds: selectedQuoteIds,
                  onToggleSelection: onToggleSelection,
                  onCallCustomer: onCallCustomer,
                  onEditQuote: onEditQuote,
                  onShareQuote: onShareQuote,
                  onDeleteQuote: onDeleteQuote,
                  onUpdateQuoteStatus: onUpdateQuoteStatus,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'הצעות מחיר במערכת: ${quotes.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
              if (quotes.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () =>
                      onGenerateSummary(customer),
                  icon: const Icon(
                    Icons.picture_as_pdf,
                    size: 16,
                  ),
                  label: const Text('ריכוז חודשי (PDF)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () => onEditCustomer(customer),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('ערוך לקוח'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueGrey,
                  ),
                ),
                TextButton(
                  onPressed: () => onConfirmDeleteCustomer(
                    index,
                    customer['name'] ?? '',
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'מחק לקוח',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      );
  }
}
