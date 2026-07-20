import 'package:flutter/material.dart';
import 'quote_card.dart';
import 'kpi_row.dart';
import 'pagination_controls.dart';
import 'quick_actions_grid.dart';
import 'dashboard_empty_states.dart';
import 'quotes_list_header.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({
    super.key,
    required this.quotes,
    required this.filteredQuotes,
    required this.businessName,
    this.selectedCustomerFilter,
    required this.showOnlyPending,
    required this.onShowCustomerFilter,
    required this.onExportMonthlyRevenue,
    required this.onProfileTap,
    required this.onClearFilter,
    required this.onTogglePendingFilter,
    required this.onNavigateToNewQuote,
    required this.onNavigateToCustomers,
    required this.onShowStatusPicker,
    required this.isQuoteOverdue,
    required this.overdueDays,
    required this.onCallCustomer,
    required this.onEditQuote,
    required this.onShareQuote,
    required this.onConfirmDeleteQuote,
    this.dashboardSearchController,
    this.canLoadMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.totalFilteredCount = 0,
    this.hasUnloadedQuotes = false,
  });

  final List<Map<String, dynamic>> quotes;
  final List<Map<String, dynamic>> filteredQuotes;
  final String businessName;
  final String? selectedCustomerFilter;
  final bool showOnlyPending;
  final TextEditingController? dashboardSearchController;
  final VoidCallback onShowCustomerFilter;
  final VoidCallback onExportMonthlyRevenue;
  final VoidCallback onProfileTap;
  final VoidCallback onClearFilter;
  final VoidCallback onTogglePendingFilter;
  final VoidCallback onNavigateToNewQuote;
  final VoidCallback onNavigateToCustomers;
  final void Function(BuildContext context, Map<String, dynamic> quote)
      onShowStatusPicker;
  final bool Function(Map<String, dynamic> quote) isQuoteOverdue;
  final int Function(Map<String, dynamic> quote) overdueDays;
  final void Function(Map<String, dynamic> quote) onCallCustomer;
  final void Function(Map<String, dynamic> quote) onEditQuote;
  final void Function(Map<String, dynamic> quote) onShareQuote;
  final void Function(int index) onConfirmDeleteQuote;
  // Pagination
  final bool canLoadMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final int totalFilteredCount;
  final bool hasUnloadedQuotes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CutQuote Pro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(
                Icons.account_circle_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: onProfileTap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: IconButton(
              icon: const Icon(
                Icons.file_download,
                color: Colors.white,
                size: 24,
              ),
              tooltip: 'ייצוא דוח חודשי',
              onPressed: onExportMonthlyRevenue,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                businessName.isEmpty ? 'שלום,' : 'שלום $businessName,',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ניהול הצעות מחיר וחישובי ייצור בזמן אמת',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'פעולות מהירות',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              QuickActionsGrid(
                onNavigateToNewQuote: onNavigateToNewQuote,
                onNavigateToCustomers: onNavigateToCustomers,
              ),
              const SizedBox(height: 24),

              KpiRow(
                quotes: quotes,
                hasUnloadedQuotes: hasUnloadedQuotes,
                selectedCustomerFilter: selectedCustomerFilter,
                showOnlyPending: showOnlyPending,
                onClearFilter: onClearFilter,
                onShowCustomerFilter: onShowCustomerFilter,
                onTogglePendingFilter: onTogglePendingFilter,
              ),
              const SizedBox(height: 24),

              QuotesListHeader(
                selectedCustomerFilter: selectedCustomerFilter,
                showOnlyPending: showOnlyPending,
                onClearFilter: onClearFilter,
              ),
              const SizedBox(height: 12),
              if (quotes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: dashboardSearchController,
                    decoration: InputDecoration(
                      hintText: 'חיפוש הצעות מחיר...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              quotes.isEmpty
                  ? const DashboardEmptyState()
                  : filteredQuotes.isEmpty
                  ? const DashboardFilterEmptyState()
                  : Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredQuotes.length,
                          itemBuilder: (context, index) {
                            final quote = filteredQuotes[index];
                            return QuoteCard(
                              quote: quote,
                              quotes: quotes,
                              isQuoteOverdue: isQuoteOverdue,
                              overdueDays: overdueDays,
                              onShowStatusPicker: onShowStatusPicker,
                              onCallCustomer: onCallCustomer,
                              onEditQuote: onEditQuote,
                              onShareQuote: onShareQuote,
                              onConfirmDeleteQuote: onConfirmDeleteQuote,
                            );
                          },
                        ),

                    PaginationControls(
                      canLoadMore: canLoadMore,
                      isLoadingMore: isLoadingMore,
                      onLoadMore: onLoadMore,
                      hasUnloadedQuotes: hasUnloadedQuotes,
                      filteredQuotesCount: filteredQuotes.length,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
