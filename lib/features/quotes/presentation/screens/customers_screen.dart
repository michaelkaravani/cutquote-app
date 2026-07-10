import 'package:flutter/material.dart';

class CustomersScreen extends StatefulWidget {
  final List<Map<String, String>> customers;
  final List<Map<String, dynamic>> quotes;
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

  // פלטת הצבעים המדויקת מהעיצוב שלך
  final Color backgroundColor = const Color(0xFFFAF7F0); // רקע שמנת חם
  final Color primaryDark = const Color(0xFF513222); // חום שוקולד כהה
  final Color accentOrange = const Color(0xFFE88432); // כתום חמרה
  final Color cardColor = Colors.white;

  void _openAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'הוספת לקוח חדש',
              style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'שם הלקוח / חברה',
                      labelStyle: const TextStyle(color: Colors.black54),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accentOrange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _hpController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'ח.פ / ת.ז',
                      labelStyle: const TextStyle(color: Colors.black54),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accentOrange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: 'כתובת',
                      labelStyle: const TextStyle(color: Colors.black54),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accentOrange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.black87),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'טלפון',
                      labelStyle: const TextStyle(color: Colors.black54),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: accentOrange),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _nameController.clear();
                  _hpController.clear();
                  _addressController.clear();
                  _phoneController.clear();
                  Navigator.pop(context);
                },
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
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'ניהול לקוחות',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: primaryDark,
          elevation: 0,
        ),
        body: widget.customers.isEmpty
            ? const Center(
                child: Text(
                  'אין עדיין לקוחות רשומים.\nלחץ על כפתור ה- "+" להוספת לקוח.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black45, fontSize: 14),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.customers.length,
                itemBuilder: (context, index) {
                  final customer = widget.customers[index];

                  final customerQuotes = widget.quotes.where((quote) {
                    return quote['customer'] != null &&
                        quote['customer']['name'] == customer['name'];
                  }).toList();

                  return Card(
                    color: cardColor,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.black12),
                    ),
                    child: ExpansionTile(
                      iconColor: accentOrange,
                      collapsedIconColor: primaryDark,
                      title: Text(
                        customer['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'ח.פ: ${customer['hp']} | טלפון: ${customer['phone']}',
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 13,
                        ),
                      ),
                      childrenPadding: const EdgeInsets.all(16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'כתובת: ${customer['address']}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'הצעות מחיר במערכת: ${customerQuotes.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                                fontSize: 13,
                              ),
                            ),
                            if (customerQuotes.isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: () =>
                                    widget.onGenerateSummary(customer),
                                icon: const Icon(
                                  Icons.picture_as_pdf,
                                  size: 16,
                                ),
                                label: const Text('ריכוז חודשי (PDF)'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryDark,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 24, color: Colors.black12),
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
                              'mחק לקוח',
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
          backgroundColor: accentOrange, // שינוי לכתום חמרה תואם
          elevation: 2,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
