import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/pdf_template_notifier.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:cutquote/features/quotes/presentation/screens/customers/customer_expansion_card.dart';
import 'package:cutquote/features/quotes/presentation/screens/customers/add_customer_dialog.dart';

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
      final id = widget.quotes[i]['id'];
      if (id != null) quoteNumbers[id] = i + 1001;
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

  void _confirmDeleteCustomer(int index, String customerName) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'מחיקת לקוח',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'האם אתה בטוח שברצונך למחוק את "$customerName"? הפעולה אינה הפיכה.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ביטול',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onCustomerDeleted(index);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('מחיקה'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteQuote(Map<String, dynamic> quote) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'מחיקת הצעה',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'האם אתה בטוח שברצונך למחוק הצעה זו מתאריך ${quote['date'] ?? '—'}?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'ביטול',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDeleteQuote(quote);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('מחק'),
              ),
            ],
          ),
        );
      },
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
    final selected = widget.quotes
        .where((q) => _selectedQuoteIds.contains(q['id']))
        .toList();
    if (selected.isEmpty) return;

    final totalAmount = selected.fold<double>(
      0,
      (prev, q) => prev + ((q['total'] as num?)?.toDouble() ?? 0),
    );
    final senderName =
        widget.businessName.isNotEmpty ? widget.businessName : 'העסק';
    final message =
        'שיתוף ${selected.length} הצעות מחיר מסך כולל של ₪${totalAmount.toStringAsFixed(0)}. תודה, $senderName.';

    await Clipboard.setData(ClipboardData(text: message));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('הודעת השיתוף הועתקה ללוח! הדבק אותה בוואטסאפ'),
          duration: Duration(seconds: 3),
        ),
      );
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final freshProfile =
          await FirestoreService.loadProfile(uid);
      if (!mounted) return;
      final profile = freshProfile ?? widget.profile;

      final files = <XFile>[];
      final tempDir = await getTemporaryDirectory();

      for (int i = 0; i < selected.length; i++) {
        final q = selected[i];
        final bytes = await PdfService.generateQuotePdfBytes(
          customer: q['customer'] is Map
              ? Map<String, String>.from(q['customer'] as Map)
              : null,
          items: List<Map<String, dynamic>>.from(q['items'] ?? []),
          total: (q['total'] as num?)?.toDouble() ?? 0.0,
          notes: q['notes'] as String?,
          profile: profile,
          templateStyle: pdfTemplateNotifier.currentTemplate,
        );

        final title = q['title']?.toString() ?? 'הצעת מחיר';
        final safeName = title.replaceAll(
          RegExp(r'[^\u0590-\u05FF\w\s\-]'),
          '',
        ).trim();
        final file = File('${tempDir.path}/${safeName}_$i.pdf');
        await file.writeAsBytes(bytes);
        files.add(XFile(file.path));
      }

      await SharePlus.instance.share(ShareParams(files: files));
      if (!mounted) return;

      for (final f in files) {
        final file = File(f.path);
        Future.delayed(const Duration(seconds: 10), () async {
          try {
            if (await file.exists()) await file.delete();
          } catch (_) {}
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשיתוף ההצעות: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    _exitSelectionMode();
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
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'חיפוש לקוח...',
        hintStyle: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.4),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.6),
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                  FocusScope.of(context).unfocus();
                },
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
        ),
      ),
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
                    onPressed: () { _shareSelectedQuotes(); },
                    backgroundColor: Theme.of(context).colorScheme.secondary,
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
