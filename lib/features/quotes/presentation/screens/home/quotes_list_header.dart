import 'package:flutter/material.dart';

class QuotesListHeader extends StatelessWidget {
  final String? selectedCustomerFilter;
  final bool showOnlyPending;
  final VoidCallback onClearFilter;

  const QuotesListHeader({
    super.key,
    this.selectedCustomerFilter,
    required this.showOnlyPending,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'הצעות מחיר אחרונות',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (selectedCustomerFilter != null || showOnlyPending)
          TextButton.icon(
            onPressed: onClearFilter,
            icon: Icon(
              Icons.close,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: Text(
              'נקה סינון',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
