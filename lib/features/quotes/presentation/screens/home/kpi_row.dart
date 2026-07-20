import 'package:flutter/material.dart';
import 'package:cutquote/core/quote_status.dart';

class KpiRow extends StatelessWidget {
  final List<Map<String, dynamic>> quotes;
  final bool hasUnloadedQuotes;
  final String? selectedCustomerFilter;
  final bool showOnlyPending;
  final VoidCallback? onClearFilter;
  final VoidCallback? onShowCustomerFilter;
  final VoidCallback? onTogglePendingFilter;

  const KpiRow({
    super.key,
    required this.quotes,
    this.hasUnloadedQuotes = false,
    this.selectedCustomerFilter,
    this.showOnlyPending = false,
    this.onClearFilter,
    this.onShowCustomerFilter,
    this.onTogglePendingFilter,
  });

  String _formatCurrency(double amount) {
    final whole = amount.floor();
    final str = whole.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
      count++;
    }
    return '₪${buffer.toString().split('').reversed.join()}';
  }

  @override
  Widget build(BuildContext context) {
    final totalQuotes = quotes.length;

    final uniqueCustomers = quotes
        .where(
          (q) {
            final c = q['customer'] as Map?;
            return c != null && c['name'] != null && c['name'].toString().trim().isNotEmpty;
          },
        )
        .map((q) => ((q['customer'] as Map?)?['name'] as String?) ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .length;

    double pendingTotal = 0;
    for (final q in quotes) {
      final status = q['status'] as String?;
      if (status != QuoteStatus.paid.dbValue) {
        pendingTotal += (q['total'] as num?)?.toDouble() ?? 0;
      }
    }

    final formattedPending = _formatCurrency(pendingTotal);

    Widget kpiCard(
      IconData icon,
      String value,
      String label, {
      VoidCallback? onTap,
      bool isActive = false,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: Theme.of(context).colorScheme.secondary, width: 1.5)
                : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 22),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: kpiCard(
            Icons.description_outlined,
            hasUnloadedQuotes ? '$totalQuotes+' : '$totalQuotes',
            'הצעות',
            onTap: onClearFilter,
            isActive: selectedCustomerFilter == null && !showOnlyPending,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: kpiCard(
            Icons.people_outline,
            '$uniqueCustomers',
            'לקוחות',
            onTap: onShowCustomerFilter,
            isActive: selectedCustomerFilter != null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: kpiCard(
            Icons.trending_up,
            formattedPending,
            'סה"כ פתוח',
            onTap: onTogglePendingFilter,
            isActive: showOnlyPending,
          ),
        ),
      ],
    );
  }
}
