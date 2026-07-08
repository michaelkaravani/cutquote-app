import 'package:flutter/material.dart';
import 'package:cutquote/core/pdf_service.dart';

class CustomersScreen extends StatefulWidget {
  final List<Map<String, String>> customers;
  final List<Map<String, dynamic>> quotes; // 🔥 מקבלים את רשימת כל ההצעות
  final Function(Map<String, String>) onCustomerAdded;
  final Function(int) onCustomerDeleted;
  final Function(Map<String, String>) onGenerateSummary;

  const CustomersScreen({
    super.key,
    required this.customers,
    required this.quotes,
    required this.onCustomerAdded,
    required this.onCustomerDeleted,
    required this.onGenerateSummary,
  });

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _nameController = TextEditingController();
  final _hpController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  void _openAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('הוספת לקוח חדש'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'שם הלקוח / חברה',
                    ),
                  ),
                  TextField(
                    controller: _hpController,
                    decoration: const InputDecoration(labelText: 'ח.פ / ת.ז'),
                  ),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'כתובת'),
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'מספר טלפון'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ביטול',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isEmpty) return;
                  widget.onCustomerAdded({
                    'name': _nameController.text,
                    'hp': _hpController.text,
                    'address': _addressController.text,
                    'phone': _phoneController.text,
                  });
                  _nameController.clear();
                  _hpController.clear();
                  _addressController.clear();
                  _phoneController.clear();
                  Navigator.pop(context);
                },
                child: const Text('שמירה'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'ניהול לקוחות והיסטוריה',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black,
        ),
        body: widget.customers.isEmpty
            ? const Center(
                child: Text(
                  'אין לקוחות רשומים כרגע.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: widget.customers.length,
                itemBuilder: (context, index) {
                  final customer = widget.customers[index];

                  // 🔥 סינון הצעות המחיר השייכות אך ורק ללקוח הנוכחי הזה ברשימה
                  final customerQuotes = widget.quotes
                      .where(
                        (quote) =>
                            quote['customer'] != null &&
                            quote['customer']['name'] == customer['name'],
                      )
                      .toList();

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: ExpansionTile(
                      iconColor: Colors.blueAccent,
                      collapsedIconColor: Colors.grey,
                      title: Text(
                        customer['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'טלפון: ${customer['phone'] ?? ''} | ${customerQuotes.length} הצעות שמורות',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      children: [
                        // כפתור מהיר להפקת ריכוז חודשי מרוכז בתחילת הרשימה הפנימית
                        if (customerQuotes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  widget.onGenerateSummary(customer),
                              icon: const Icon(Icons.analytics, size: 18),
                              label: const Text(
                                'הפק סיכום חודשי מרוכז (איחוד פריטים)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(38),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),

                        // רשימת הצעות המחיר של אותו לקוח
                        customerQuotes.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'אין הצעות מחיר שמורות ללקוח זה.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: customerQuotes.length,
                                itemBuilder: (context, qIndex) {
                                  final quote = customerQuotes[qIndex];
                                  final int itemsCount =
                                      (quote['items'] as List).length;
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    title: Text(
                                      'הצעה מיום ${quote['date']}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '$itemsCount פריטים בהצעה',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₪${quote['total'].toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.share,
                                            color: Colors.green,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            PdfService.generateAndShareQuote(
                                              customer: quote['customer'],
                                              items:
                                                  List<
                                                    Map<String, dynamic>
                                                  >.from(quote['items']),
                                              total: quote['total'],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                        // כפתור מחיקת לקוח בתחתית התפריט הנפתח שלו
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => widget.onCustomerDeleted(index),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                              size: 16,
                            ),
                            label: const Text(
                              'מחק לקוח',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddCustomerDialog,
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
