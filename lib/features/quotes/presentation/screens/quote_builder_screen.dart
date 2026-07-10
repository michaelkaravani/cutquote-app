import 'package:flutter/material.dart';
import 'package:cutquote/core/pdf_service.dart';

class QuoteBuilderScreen extends StatefulWidget {
  final List<Map<String, String>> customers;
  final List<Map<String, dynamic>> catalog;
  final Function(Map<String, dynamic>) onAddToCatalog;
  final Function(Map<String, dynamic>) onSaveQuote;

  const QuoteBuilderScreen({
    super.key,
    required this.customers,
    required this.catalog,
    required this.onAddToCatalog,
    required this.onSaveQuote,
  });

  @override
  State<QuoteBuilderScreen> createState() => _QuoteBuilderScreenState();
}

class _QuoteBuilderScreenState extends State<QuoteBuilderScreen> {
  final List<Map<String, dynamic>> items = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool saveToCatalog = false;
  Map<String, String>? selectedCustomer;

  final Color backgroundColor = const Color(0xFFFAF7F0);
  final Color primaryDark = const Color(0xFF513222);
  final Color accentOrange = const Color(0xFFE88432);
  final Color cardColor = Colors.white;
  final Color buttonColor = const Color(0xFFA6968C);

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
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'הוספת פריט להצעה',
                  style: TextStyle(
                    color: primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.catalog.isNotEmpty) ...[
                        DropdownButtonFormField<Map<String, dynamic>>(
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          alignment: Alignment.centerRight,
                          decoration: InputDecoration(
                            labelText: 'בחירה מהירה מהקטלוג',
                            labelStyle: const TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryDark.withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: accentOrange),
                            ),
                          ),
                          items: widget.catalog.map((item) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: item,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(color: Colors.black),
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
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Colors.black12)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'או הקלדה ידנית',
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.black12)),
                          ],
                        ),
                      ],
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'שם הפריט / השירות',
                          labelStyle: const TextStyle(color: Colors.black54),
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
                              style: const TextStyle(color: Colors.black),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'מחיר ליחידה',
                                labelStyle: const TextStyle(
                                  color: Colors.black54,
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
                              style: const TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                              onTap: () {
                                quantityController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: quantityController.text.length,
                                );
                              },
                              decoration: InputDecoration(
                                labelText: 'כמות',
                                labelStyle: const TextStyle(
                                  color: Colors.black54,
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
                          const Text(
                            'שמור מוצר זה לקטלוג (מועדפים)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
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
                    child: const Text(
                      'ביטול',
                      style: TextStyle(color: Colors.grey),
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
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'הצעה חדשה',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: primaryDark,
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
              const Text(
                'לקוח',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
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
                            const Expanded(
                              child: Text(
                                'יש להוסיף תחילה לקוחות במסך "לקוחות".',
                                style: TextStyle(
                                  color: Colors.black54,
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
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: primaryDark,
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
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'פריטים',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${items.length}',
                    style: const TextStyle(color: Colors.black45),
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
                      color: cardColor,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      child: ListTile(
                        title: Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          '${item['quantity']} יח\' X ₪${item['price'].toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.black45),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₪${itemTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
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
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'סכום ביניים',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          '₪${calculateTotal().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Colors.black12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'הנחה',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Container(
                          width: 80,
                          height: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: const Text(
                            '₪ 0',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Colors.black12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'סה"כ לתשלום',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryDark,
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

              const Text(
                'הערות ללקוח',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                maxLines: 3,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  fillColor: cardColor,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
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

                        widget.onSaveQuote({
                          'customer': selectedCustomer,
                          'items': List<Map<String, dynamic>>.from(items),
                          'total': calculateTotal(),
                          'date': formattedDate,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('הצעת המחיר נשמרה בהיסטוריה בהצלחה!'),
                          ),
                        );

                        setState(() {
                          items.clear();
                          selectedCustomer = null;
                          notesController.clear();
                        });
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
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
                    await PdfService.generateAndShareQuote(
                      customer: selectedCustomer,
                      items: items,
                      total: calculateTotal(),
                    );
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('שתף כ-PDF'),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryDark,
                    minimumSize: const Size.fromHeight(40),
                  ),
                ),
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
        decoration: const BoxDecoration(
          color: Color(0xFFFAF7F0),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'בחר לקוח מהרשימה',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF513222),
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
