import 'package:flutter/material.dart';
import 'package:cutquote/core/pdf_service.dart';

class QuoteBuilderScreen extends StatefulWidget {
  final List<Map<String, String>> customers;
  final List<Map<String, dynamic>> catalog;
  final Function(Map<String, dynamic>) onAddToCatalog;
  final Function(Map<String, dynamic>)
  onSaveQuote; // שים לב שהשורה הזו קיימת כאן!

  const QuoteBuilderScreen({
    super.key,
    required this.customers,
    required this.catalog,
    required this.onAddToCatalog,
    required this.onSaveQuote, // וגם השורה הזו!
  });

  @override
  State<QuoteBuilderScreen> createState() => _QuoteBuilderScreenState();
}

class _QuoteBuilderScreenState extends State<QuoteBuilderScreen> {
  final List<Map<String, dynamic>> items = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  Map<String, String>? selectedCustomer;
  bool saveToCatalog = false; // משתנה למצב ה-Checkbox בדיאלוג

  double calculateTotal() {
    double total = 0;
    for (var item in items) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  void openAddItemDialog() {
    // 🔥 שינוי: במקום רק להציב "1", אנחנו גם בוחרים את כל הטקסט כדי שיימחק מיד בהקלדה
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
                title: const Text('הוספת פריט להצעה'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // בחירה מהירה מתוך קטלוג קיים
                      if (widget.catalog.isNotEmpty) ...[
                        DropdownButtonFormField<Map<String, dynamic>>(
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          alignment: Alignment
                              .centerRight, // 🔥 חדש: מיישר את התפריט עצמו לימין
                          decoration: const InputDecoration(
                            labelText: 'בחירה מהירה מהקטלוג',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          items: widget.catalog.map((item) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: item,
                              child: Align(
                                alignment: Alignment
                                    .centerRight, // 🔥 מבטיח יישור ימני מוחלט של הטקסט
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

                                // 🔥 חדש: ברגע שבוחרים מוצר, מסמנים אוטומטית את הכמות (1) כדי שיהיה אפשר להקליד מעליה מיד
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
                            Expanded(child: Divider(color: Colors.black26)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'או הקלדה ידנית',
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.black26)),
                          ],
                        ),
                      ],

                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'שם הפריט / השירות',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'מחיר ליחידה',
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              // 🔥 חדש: כשלוחצים על שדה הכמות ידנית, הוא יבחר את כל הטקסט אוטומטית
                              onTap: () {
                                quantityController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: quantityController.text.length,
                                );
                              },
                              decoration: const InputDecoration(
                                labelText: 'כמות',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // כפתור שמירה למועדפים
                      Row(
                        children: [
                          Checkbox(
                            value: saveToCatalog,
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'יצירת הצעת מחיר',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: widget.customers.isEmpty
                ? const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orangeAccent),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'על מנת לשייך לקוח להצעה, יש להוסיף תחילה לקוחות במסך "לקוחות".',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ],
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, String>>(
                      dropdownColor: Colors.grey[900],
                      hint: const Text(
                        'בחר לקוח עבור ההצעה',
                        style: TextStyle(color: Colors.grey),
                      ),
                      value: selectedCustomer,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      items: widget.customers.map((
                        Map<String, String> customer,
                      ) {
                        return DropdownMenuItem<Map<String, String>>(
                          value: customer,
                          child: Text(
                            customer['name']!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (Map<String, String>? newValue) {
                        setState(() {
                          selectedCustomer = newValue;
                        });
                      },
                    ),
                  ),
          ),
          if (selectedCustomer != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'עבור: ${selectedCustomer!['name']}',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'ח.פ: ${selectedCustomer!['hp']} | כתובת: ${selectedCustomer!['address']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Divider(color: Colors.grey, height: 20),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: openAddItemDialog,
              icon: const Icon(Icons.add),
              label: const Text(
                'הוסף פריט להצעה',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'אין עדיין פריטים בהצעת המחיר',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final double itemTotal = item['price'] * item['quantity'];
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            item['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${item['quantity']} יח\' X ₪${item['price'].toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '₪${itemTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'סה"כ לתשלום:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₪${calculateTotal().toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // כפתור 1: שיתוף PDF
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: items.isEmpty
                        ? null
                        : () async {
                            await PdfService.generateAndShareQuote(
                              customer: selectedCustomer,
                              items: items,
                              total: calculateTotal(),
                            );
                          },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text(
                      'שתף PDF',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[800],
                      disabledForegroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // כפתור 2: שמירה למערכת בשביל הריכוז החודשי
                Expanded(
                  child: ElevatedButton.icon(
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
                                content: Text(
                                  'הצעת המחיר נשמרה בהיסטוריה בהצלחה!',
                                ),
                              ),
                            );

                            setState(() {
                              items.clear();
                              selectedCustomer = null;
                            });
                          },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text(
                      'שמור הצעה',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(45),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[800],
                      disabledForegroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
