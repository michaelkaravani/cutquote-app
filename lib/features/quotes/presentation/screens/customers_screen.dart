import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cutquote/core/pdf_template_notifier.dart';
import 'package:cutquote/features/quotes/presentation/screens/customers/customer_expansion_card.dart';
import 'package:cutquote/features/quotes/presentation/screens/customers/add_customer_dialog.dart';
import 'package:cutquote/features/quotes/presentation/screens/customers/delete_confirm_dialogs.dart';
import 'package:cutquote/features/quotes/presentation/screens/customers/share_selected_quotes.dart';
import 'package:cutquote/features/quotes/presentation/screens/customers/customer_search_bar.dart';

class CustomersScreen extends StatefulWidget {
  final String businessName;
  final Map<String, dynamic>? profile;
  final List<Map<String, String>> customers;
  final List<Map<String, dynamic>> quotes;
  final Future<void> Function(Map<String, String>) onCustomerAdded;
  final Function(int) onCustomerDeleted;
  final Function(Map<String, String>) onCustomerUpdated;
  final Function(Map<String, String>) onGenerateSummary;
  final Function(Map<String, dynamic>) onEditQuote;
  final Function(Map<String, dynamic>) onShareQuote;
  final Function(Map<String, dynamic>) onDeleteQuote;
  final Function(String quoteId, String newStatus)? onUpdateQuoteStatus;

  const CustomersScreen({
    super.key,
    required this.businessName,
    this.profile,
    required this.customers,
    required this.quotes,
    required this.onCustomerAdded,
    required this.onCustomerDeleted,
    required this.onCustomerUpdated,
    required this.onGenerateSummary,
    required this.onEditQuote,
    required this.onShareQuote,
    required this.onDeleteQuote,
    this.onUpdateQuoteStatus,
  });

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, String>> get _filteredCustomers {
    if (_searchQuery.isEmpty) return widget.customers;

    final query = _searchQuery.trim().toLowerCase();

    final quoteNumbers = <String, int>{};
    for (int i = 0; i < widget.quotes.length; i++) {
      final q = widget.quotes[i];
      final id = q['id'];
      if (id != null) quoteNumbers[id] = q['quoteNumber'] as int? ?? (i + 1001);
    }

    return widget.customers.where((customer) {
      if ((customer['name'] ?? '').toLowerCase().contains(query)) return true;
      if ((customer['phone'] ?? '').contains(query)) return true;

      for (final quote in widget.quotes) {
        final quoteCustomer = quote['customer'] as Map?;
        if (quoteCustomer == null) continue;
        if (quoteCustomer['name'] != customer['name']) continue;

        final title = (quote['title']?.toString() ?? '').toLowerCase();
        if (title.contains(query)) return true;

        final number = quoteNumbers[quote['id']];
        if (number != null && number.toString().contains(query)) return true;
      }

      return false;
    }).toList();
  }

  final Set<String> _selectedQuoteIds = {};
  bool _isSelectionMode = false;
  bool _isSharingMultiple = false;

  void _confirmDeleteCustomer(int index, String customerName) {
    showDeleteCustomerDialog(
      context: context,
      customerName: customerName,
      onConfirm: () => widget.onCustomerDeleted(index),
    );
  }

  void _confirmDeleteQuote(Map<String, dynamic> quote) {
    showDeleteQuoteDialog(
      context: context,
      quoteDate: quote['date'] ?? '—',
      onConfirm: () => widget.onDeleteQuote(quote),
    );
  }

  void _toggleSelection(String? quoteId) {
    if (quoteId == null) return;
    setState(() {
      if (_selectedQuoteIds.contains(quoteId)) {
        _selectedQuoteIds.remove(quoteId);
        if (_selectedQuoteIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedQuoteIds.add(quoteId);
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    if (!mounted) return;
    setState(() {
      _selectedQuoteIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _callCustomer(Map<String, dynamic> quote) async {
    final phone = quote['customer']?['phone']?.toString();
    if (phone == null || phone.isEmpty) return;
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('לא ניתן לחייג למספר $cleanPhone'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _shareSelectedQuotes() async {
    if (_isSharingMultiple) return;
    setState(() {
      _isSharingMultiple = true;
    });
    await shareSelectedQuotes(
      context: context,
      allQuotes: widget.quotes,
      selectedQuoteIds: _selectedQuoteIds,
      businessName: widget.businessName,
      profile: widget.profile,
      pdfTemplateNotifier: pdfTemplateNotifier,
      onProgress: () => setState(() {}),
      onExitSelection: () {
        setState(() {
          _isSharingMultiple = false;
        });
        _exitSelectionMode();
      },
    );
  }

  void _openAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (_) => AddCustomerDialog(
        onCustomerAdded: widget.onCustomerAdded,
      ),
    );
  }

  void _openEditCustomerDialog(Map<String, String> customer) {
    showDialog(
      context: context,
      builder: (_) => AddCustomerDialog(
        existingCustomer: customer,
        onCustomerAdded: (updated) async {
          final withId = Map<String, String>.from(updated)
            ..['id'] = customer['id'] ?? '';
          final navigator = Navigator.of(context);
          await widget.onCustomerUpdated(withId);
          if (!context.mounted) return;
          navigator.pop();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return CustomerSearchBar(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildBodyContent() {
    if (widget.customers.isEmpty) {
      return const Center(
        child: Text(
          'אין עדיין לקוחות רשומים.\nלחץ על כפתור ה- "+" להוספת לקוח.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    if (_filteredCustomers.isEmpty) {
      return const Center(
        child: Text(
          'לא נמצאו לקוחות המתאימים לחיפוש זה',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];

        final customerQuotes = widget.quotes.where((quote) {
          final qc = quote['customer'] as Map?;
          if (qc == null) return false;
          return (qc['name'] ?? '') == (customer['name'] ?? '');
        }).toList();

        return CustomerExpansionCard(
          key: ValueKey(customer['name'] ?? index),
          customer: customer,
          quotes: customerQuotes,
          index: index,
          isSelectionMode: _isSelectionMode,
          selectedQuoteIds: _selectedQuoteIds,
          onToggleSelection: _toggleSelection,
          onCallCustomer: _callCustomer,
          onEditQuote: widget.onEditQuote,
          onShareQuote: widget.onShareQuote,
          onDeleteQuote: _confirmDeleteQuote,
          onUpdateQuoteStatus: widget.onUpdateQuoteStatus,
          onGenerateSummary: widget.onGenerateSummary,
          onConfirmDeleteCustomer: _confirmDeleteCustomer,
          onEditCustomer: _openEditCustomerDialog,
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isSelectionMode
                ? '${_selectedQuoteIds.length} נבחרו'
                : 'ניהול לקוחות',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          actions: [
            if (_isSelectionMode)
              TextButton(
                onPressed: _exitSelectionMode,
                child: const Text(
                  'ביטול',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: const Text(
                    'CQ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            if (widget.customers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildSearchBar(),
              ),
            Expanded(
              child: _buildBodyContent(),
            ),
          ],
        ),
        floatingActionButton: _isSelectionMode
            ? (_selectedQuoteIds.isNotEmpty
                ? FloatingActionButton.extended(
                    onPressed: _isSharingMultiple ? null : _shareSelectedQuotes,
                    backgroundColor: _isSharingMultiple
                        ? Colors.grey
                        : Theme.of(context).colorScheme.secondary,
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: Text(
                      'שתף ${_selectedQuoteIds.length} הצעות',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink())
            : FloatingActionButton(
                onPressed: _openAddCustomerDialog,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 2,
                child: const Icon(Icons.add, color: Colors.white),
              ),
      ),
    );
  }
}
