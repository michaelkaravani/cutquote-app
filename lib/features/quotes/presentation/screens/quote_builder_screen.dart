import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/firestore_service.dart';

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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool saveToCatalog = false;
  Map<String, String>? selectedCustomer;

  final Color accentOrange = const Color(0xFFE88432);

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
    }
  }

  double calculateTotal() {
    double total = 0;
    for (var item in items) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  void openAddItemDialog() {
    quantityController.text = "1";
    quantityController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: quantityController.text.length,
    );

    saveToCatalog = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'הוספת פריט להצעה',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.catalog.isNotEmpty) ...[
                        DropdownButtonFormField<Map<String, dynamic>>(
                          dropdownColor: Theme.of(context).colorScheme.surfaceContainerLow,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          alignment: Alignment.centerRight,
                          decoration: InputDecoration(
                            labelText: 'בחירה מהירה מהמועדפים שלך',
                            labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              fontWeight: FontWeight.bold,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: accentOrange),
                            ),
                          ),
                          items: widget.catalog.asMap().entries.map((entry) {
                            final item = entry.value;
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: item,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "${item['name']} (₪${item['price']})",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (selectedItem) {
                            if (selectedItem != null) {
                              dialogSetState(() {
                                nameController.text = selectedItem['name'];
                                priceController.text = selectedItem['price']
                                    .toString();
                                quantityController.text = "1";
                                quantityController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: quantityController.text.length,
                                );
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'או הקלדת פריט חדש',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                      ],
                      TextField(
                        controller: nameController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: 'שם הפריט / השירות',
                          labelStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: accentOrange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: priceController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'מחיר ליחידה',
                                labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: accentOrange),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: quantityController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              keyboardType: TextInputType.number,
                              onTap: () {
                                quantityController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: quantityController.text.length,
                                );
                              },
                              decoration: InputDecoration(
                                labelText: 'כמות',
                                labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: accentOrange),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Checkbox(
                            value: saveToCatalog,
                            activeColor: accentOrange,
                            onChanged: (val) {
                              dialogSetState(() {
                                saveToCatalog = val ?? false;
                              });
                            },
                          ),
                          Text(
                            'שמור מוצר זה למועדפים קבועים',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      nameController.clear();
                      priceController.clear();
                      quantityController.clear();
                      Navigator.pop(context);
                    },
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
                      if (nameController.text.isEmpty) return;

                      final double price =
                          double.tryParse(priceController.text) ?? 0.0;
                      final int quantity =
                          int.tryParse(quantityController.text) ?? 1;

                      if (saveToCatalog) {
                        widget.onAddToCatalog({
                          'name': nameController.text,
                          'price': price,
                        });
                      }

                      setState(() {
                        items.add({
                          'name': nameController.text,
                          'price': price,
                          'quantity': quantity,
                        });
                      });

                      nameController.clear();
                      priceController.clear();
                      quantityController.clear();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('שמירה'),
                  ),
                ],
              ),
            );
          },
        );
      },
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
          backgroundColor: const Color(0xFF513222),
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: accentOrange,
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
                    borderSide: BorderSide(color: accentOrange),
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
                            Icon(Icons.info_outline, color: accentOrange),
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
                      color: accentOrange.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: accentOrange, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'הוסף שירות / פריט',
                        style: TextStyle(
                          color: accentOrange,
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

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'סכום ביניים',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          '₪${calculateTotal().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'הנחה',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Text(
                            '₪ 0',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'סה"כ לתשלום',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '₪${calculateTotal().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentOrange,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'הערות ללקוח',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                maxLines: 3,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentOrange),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: items.isEmpty
                    ? null
                    : () {
                        final DateTime now = DateTime.now();
                        final String formattedDate =
                            "${now.day}/${now.month}/${now.year}";

                        if (widget.initialQuote != null &&
                            widget.onUpdateQuote != null) {
                          widget.onUpdateQuote!({
                            'customer': selectedCustomer,
                            'items': List<Map<String, dynamic>>.from(items),
                            'total': calculateTotal(),
                            'date': widget.initialQuote!['date'] ?? formattedDate,
                            'title': titleController.text.trim(),
                            'notes': notesController.text.trim(),
                            'id': widget.initialQuote!['id'],
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'הצעת המחיר עודכנה בהצלחה!',
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          widget.onSaveQuote({
                            'customer': selectedCustomer,
                            'items': List<Map<String, dynamic>>.from(items),
                            'total': calculateTotal(),
                            'date': formattedDate,
                            'title': titleController.text.trim(),
                            'notes': notesController.text.trim(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'הצעת המחיר נשמרה בהיסטוריה בהצלחה!',
                              ),
                            ),
                          );
                          setState(() {
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
                child: const Text(
                  'שמירת הצעה',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),

              if (items.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    final freshProfile =
                        await FirestoreService.loadProfile(
                      FirebaseAuth.instance.currentUser!.uid,
                    );
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
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'בחר לקוח מהרשימה',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.customers.length,
                itemBuilder: (context, index) {
                  final customer = widget.customers[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE88432),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(customer['name']!),
                    onTap: () {
                      setState(() {
                        selectedCustomer = customer;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
