import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/add_item_dialog.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/customer_picker_sheet.dart';
import 'package:cutquote/features/quotes/presentation/screens/quote_builder/quote_summary_card.dart';

class QuoteBuilderScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  final List<Map<String, String>> customers;
  final List<Map<String, dynamic>> catalog;
  final Function(Map<String, dynamic>) onAddToCatalog;
  final Function(Map<String, dynamic>) onSaveQuote;
  final Function(int)? onDeleteFromCatalog;
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

  double calculateTotal() {
    double total = 0;
    for (var item in items) {
      total += item['price'] * item['quantity'];
    }
    return total - _discount;
  }

  void _editDiscount(BuildContext context) {
    final controller = TextEditingController(text: _discount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'הנחה',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'סכום ההנחה בשקלים',
              prefixIcon: const Icon(Icons.money_off, size: 20),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null && value >= 0) {
                  setState(() => _discount = value);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('אישור'),
            ),
          ],
        ),
      ),
    );
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
              Text(
                'לקוח',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: widget.customers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'יש להוסיף תחילה לקוחות במסך "לקוחות".',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          _showCustomerPicker(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedCustomer?['name'] ?? '-- בחר לקוח --',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              if (selectedCustomer != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'ח.פ: ${selectedCustomer!['hp']} | כתובת: ${selectedCustomer!['address']}',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
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

              InkWell(
                onTap: openAddItemDialog,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Theme.of(context).colorScheme.secondary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'הוסף שירות / פריט',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (items.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final double itemTotal = item['price'] * item['quantity'];
                    return Card(
                      surfaceTintColor: Colors.transparent,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          item['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          '${item['quantity']} יח\' X ₪${item['price'].toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₪${itemTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () =>
                                  setState(() => items.removeAt(index)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                onPressed: items.isEmpty || _isSaving
                    ? null
                    : () async {
                        final DateTime now = DateTime.now();
                        final String formattedDate =
                            "${now.day}/${now.month}/${now.year}";
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);

                        setState(() => _isSaving = true);

                        if (widget.initialQuote != null &&
                            widget.onUpdateQuote != null) {
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
                            const SnackBar(
                              content: Text(
                                'הצעת המחיר עודכנה בהצלחה!',
                              ),
                            ),
                          );
                          navigator.pop();
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
                            const SnackBar(
                              content: Text(
                                'הצעת המחיר נשמרה בהיסטוריה בהצלחה!',
                              ),
                            ),
                          );
                          setState(() {
                            _isSaving = false;
                            items.clear();
                            selectedCustomer = null;
                            titleController.clear();
                            notesController.clear();
                          });
                        }
                      },
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
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid == null) return;
                    final freshProfile =
                        await FirestoreService.loadProfile(uid);
                    final profile = freshProfile ?? widget.profile;

                    await PdfService.generateAndShareQuote(
                      customer: selectedCustomer,
                      items: items,
                      total: calculateTotal(),
                      filename:
                          'quote_${selectedCustomer?['name'] ?? 'general'}.pdf',
                      notes: notesController.text.trim(),
                      profile: profile,
                    );
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('שתף כ-PDF'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),

              // הצגת ניהול המועדפים ישירות בתחתית המסך כדי שיהיה קל למחוק פריטים ישנים מהקטלוג
              if (widget.catalog.isNotEmpty) ...[
                const SizedBox(height: 30),
                Text(
                  'ניהול פריטים שמורים (מועדפים)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.catalog.length,
                  itemBuilder: (context, index) {
                    final catItem = widget.catalog[index];
                    return Card(
                      surfaceTintColor: Colors.transparent,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          catItem['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("₪${catItem['price']}"),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                          ),
                          onPressed: () {
                            if (widget.onDeleteFromCatalog != null) {
                              widget.onDeleteFromCatalog!(index);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
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
