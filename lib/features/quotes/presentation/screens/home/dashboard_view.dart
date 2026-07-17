import 'package:flutter/material.dart';
import 'package:cutquote/core/quote_status.dart';

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
  });

  final List<Map<String, dynamic>> quotes;
  final List<Map<String, dynamic>> filteredQuotes;
  final String businessName;
  final String? selectedCustomerFilter;
  final bool showOnlyPending;
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

  Widget _buildKpiRow(BuildContext context) {
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
            '$totalQuotes',
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

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildActionButton(
                    title: 'הצעת מחיר חדשה',
                    icon: Icons.calculate_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                    onTap: onNavigateToNewQuote,
                  ),
                  _buildActionButton(
                    title: 'ניהול לקוחות',
                    icon: Icons.people_alt_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    onTap: onNavigateToCustomers,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildKpiRow(context),
              const SizedBox(height: 24),

              Row(
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
              ),
              const SizedBox(height: 12),
              quotes.isEmpty
                  ? Card(
                      surfaceTintColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'אין עדיין הצעות מחיר שמורות. לחץ על הצעת מחיר חדשה כדי להתחיל.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    )
                  : filteredQuotes.isEmpty
                  ? Card(
                      surfaceTintColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'לא נמצאו הצעות מחיר העונות לסינון זה',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredQuotes.length > 5
                          ? 5
                          : filteredQuotes.length,
                      itemBuilder: (context, index) {
                        final quote = filteredQuotes[index];
                        final customerName = (quote['customer'] as Map?)?['name']?.toString() ?? 'לקוח כללי';

                        double total = 0;
                        if (quote['items'] != null) {
                          for (var item in quote['items']) {
                            total +=
                                ((item['price'] as num?)?.toDouble() ?? 0) * ((item['quantity'] as num?)?.toDouble() ?? 1);
                          }
                        }

                        return Card(
                          key: ValueKey(quote['id']?.toString() ?? index.toString()),
                          surfaceTintColor: Colors.transparent,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.secondary
                                          .withValues(alpha: 0.15),
                                      child: Icon(
                                        Icons.description_rounded,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${quote['title'] ?? 'הצעת מחיר'} #${quote['id'] != null ? quotes.indexWhere((q) => q['id'] == quote['id']) + 1001 : 1000}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                          Text(
                                            'לקוח: $customerName',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '₪ ${total.toStringAsFixed(0)}',
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: GestureDetector(
                                        onTap: () =>
                                            onShowStatusPicker(context, quote),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isQuoteOverdue(quote)
                                                ? Colors.red.shade50
                                                : QuoteStatus.fromString(
                                                    quote['status']
                                                        as String?,
                                                  ).displayColor.withValues(
                                                    alpha: 0.15,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                                          quote['status']
                                                              as String?,
                                                        ).label,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        isQuoteOverdue(quote)
                                                        ? Colors.red.shade800
                                                        : QuoteStatus.fromString(
                                                            quote['status']
                                                                as String?,
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
                                            quote['customer']?['phone']
                                                    ?.toString() !=
                                                null) ...[
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.phone,
                                              size: 18,
                                              color: Colors.green,
                                            ),
                                            onPressed: () =>
                                                onCallCustomer(quote),
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                          onPressed: () => onEditQuote(quote),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(
                                            Icons.share,
                                            size: 18,
                                            color: Colors.teal,
                                          ),
                                          onPressed: () => onShareQuote(quote),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.4),
                                          ),
                                          onPressed: () {
                                            final idx = quotes.indexWhere(
                                              (q) => q['id'] == quote['id'],
                                            );
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
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
