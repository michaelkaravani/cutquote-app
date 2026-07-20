import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/pdf_template_notifier.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/add_item_dialog.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/add_item_button.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/customer_picker_sheet.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/customer_picker_tile.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/quote_summary_card.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/edit_discount_dialog.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/edit_catalog_item_dialog.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/item_list.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/catalog_management_list.dart';

class QuoteBuilderScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  final List<Map<String, String>> customers;
  final List<Map<String, dynamic>> catalog;
  final Function(Map<String, dynamic>) onAddToCatalog;
  final Function(Map<String, dynamic>) onSaveQuote;
  final Function(int)? onDeleteFromCatalog;
  final Function(int, Map<String, dynamic>)? onEditCatalogItem;
  final Map<String, dynamic>? initialQuote;
  final Function(Map<String, dynamic>)? onUpdateQuote;

  const QuoteBuilderScreen({
    super.key,
    this.profile,
    required this.customers,
    required this.catalog,
    required this.onAddToCatalog,
    required this.onSaveQuote,
    this.onDeleteFromCatalog,
    this.onEditCatalogItem,
    this.initialQuote,
    this.onUpdateQuote,
  });

  @override
  State<QuoteBuilderScreen> createState() => _QuoteBuilderScreenState();
}

class _QuoteBuilderScreenState extends State<QuoteBuilderScreen> {
  final List<Map<String, dynamic>> items = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  double _discount = 0.0;
  bool _isSaving = false;
  Map<String, String>? selectedCustomer;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuote != null) {
      final quote = widget.initialQuote!;
      if (quote['customer'] != null) {
        selectedCustomer =
            Map<String, String>.from(quote['customer'] as Map);
      }
      if (quote['items'] != null) {
        for (final e in quote['items'] as List) {
          items.add(Map<String, dynamic>.from(e));
        }
      }
      titleController.text = quote['title']?.toString() ?? '';
      notesController.text = quote['notes']?.toString() ?? '';
      _discount = (quote['discount'] as num?)?.toDouble() ?? 0.0;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  double calculateTotal() {
    double total = 0;
    for (var item in items) {
      total += ((item['price'] as num?)?.toDouble() ?? 0) * ((item['quantity'] as num?)?.toDouble() ?? 0);
    }
    return (total - _discount).clamp(0, double.infinity);
  }

  void _editDiscount(BuildContext context) {
    showEditDiscountDialog(
      context: context,
      currentDiscount: _discount,
      itemsTotal: calculateTotal() + _discount,
      onDiscountSet: (value) => setState(() => _discount = value),
    );
  }

  Future<void> _handleSave() async {
    final DateTime now = DateTime.now();
    final String formattedDate = "${now.day}/${now.month}/${now.year}";
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSaving = true);

    if (widget.initialQuote != null && widget.onUpdateQuote != null) {
      try {
        await widget.onUpdateQuote!({
          'customer': selectedCustomer,
          'items': List<Map<String, dynamic>>.from(items),
          'total': calculateTotal(),
          'date': widget.initialQuote!['date'] ?? formattedDate,
          'title': titleController.text.trim(),
          'notes': notesController.text.trim(),
          'id': widget.initialQuote!['id'],
          'discount': _discount,
        });
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('הצעת המחיר עודכנה בהצלחה!')),
        );
        navigator.pop();
      } catch (_) {
        if (!mounted) return;
        setState(() => _isSaving = false);
      }
    } else {
      await widget.onSaveQuote({
        'customer': selectedCustomer,
        'items': List<Map<String, dynamic>>.from(items),
        'total': calculateTotal(),
        'date': formattedDate,
        'title': titleController.text.trim(),
        'notes': notesController.text.trim(),
        'discount': _discount,
      });
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('הצעת המחיר נשמרה בהיסטוריה בהצלחה!')),
      );
      setState(() {
        _isSaving = false;
        _discount = 0.0;
        items.clear();
        selectedCustomer = null;
        titleController.clear();
        notesController.clear();
      });
    }
  }

  void openAddItemDialog() {
    showDialog(
      context: context,
      builder: (_) => AddItemDialog(
        catalog: widget.catalog,
        onAddToCatalog: widget.onAddToCatalog,
        onItemAdded: (item) {
          setState(() {
            items.add(item);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.initialQuote != null ? 'עריכת הצעת מחיר' : 'הצעה חדשה',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          actions: [
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              TextField(
                controller: titleController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'נושא/כותרת ההצעה',
                  hintText: 'לדוגמה: חיתוך שלטים, כרטיסי אלומיניום',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomerPickerTile(
                customers: widget.customers,
                selectedCustomer: selectedCustomer,
                onTap: () => _showCustomerPicker(context),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'פריטים בהצעה',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${items.length}',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AddItemButton(onPressed: openAddItemDialog),
              const SizedBox(height: 10),

              if (items.isNotEmpty)
                ItemList(
                  items: items,
                  onDeleteItem: (index) => setState(() => items.removeAt(index)),
                ),
              const SizedBox(height: 20),

              QuoteSummaryCard(
                total: calculateTotal(),
                discount: _discount,
                onEditDiscount: () => _editDiscount(context),
                notesController: notesController,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: items.isEmpty || _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  disabledBackgroundColor: Colors.black12,
                  disabledForegroundColor: Colors.black26,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'שמירת הצעה',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 10),

              if (items.isNotEmpty)
                TextButton.icon(
                  onPressed: _handleSharePdf,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('שתף כ-PDF'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),

              if (widget.catalog.isNotEmpty)
                CatalogManagementList(
                  catalog: widget.catalog,
                  onEditItem: _editCatalogItem,
                  onDeleteItem: (index) {
                    if (widget.onDeleteFromCatalog != null) {
                      widget.onDeleteFromCatalog!(index);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _editCatalogItem(int index, Map<String, dynamic> item) {
    showEditCatalogItemDialog(
      context: context,
      item: item,
      onSave: (updated) => widget.onEditCatalogItem!(index, updated),
    );
  }

  Future<void> _handleSharePdf() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final freshProfile = await FirestoreService.loadProfile(uid);
    if (!mounted) return;
    final profile = freshProfile ?? widget.profile;

    await PdfService.generateAndShareQuote(
      customer: selectedCustomer,
      items: items,
      total: calculateTotal(),
      filename: 'quote_${selectedCustomer?['name'] ?? 'general'}.pdf',
      notes: notesController.text.trim(),
      profile: profile,
      templateStyle: pdfTemplateNotifier.currentTemplate,
    );
  }

  void _showCustomerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerPickerSheet(
        customers: widget.customers,
        onCustomerSelected: (customer) {
          setState(() {
            selectedCustomer = customer;
          });
        },
      ),
    );
  }
}
