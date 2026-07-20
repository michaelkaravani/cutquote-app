import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final bool canLoadMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final bool hasUnloadedQuotes;
  final int filteredQuotesCount;

  const PaginationControls({
    super.key,
    this.canLoadMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.hasUnloadedQuotes = false,
    this.filteredQuotesCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (canLoadMore) ...[
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: isLoadingMore ? null : onLoadMore,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isLoadingMore
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : const Icon(Icons.expand_more),
              label: Text(
                isLoadingMore
                    ? 'טוען...'
                    : 'טען עוד הצעות',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],

        if (hasUnloadedQuotes) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              'מוצגות $filteredQuotesCount הצעות שנטענו עד כה',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
