import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cutquote/core/pdf_service.dart';

class CustomersScreen extends StatefulWidget {
  final List<Map<String, String>> customers;
  final List<Map<String, dynamic>> quotes;
  final Function(Map<String, String>) onCustomerAdded;
  final Function(int) onCustomerDeleted;
  final Function(Map<String, String>) onGenerateSummary;
  final Function(Map<String, dynamic>) onEditQuote;
  final Function(Map<String, dynamic>) onShareQuote;
  final Function(Map<String, dynamic>) onDeleteQuote;

  const CustomersScreen({
    super.key,
    required this.customers,
    required this.quotes,
    required this.onCustomerAdded,
    required this.onCustomerDeleted,
    required this.onGenerateSummary,
    required this.onEditQuote,
    required this.onShareQuote,
    required this.onDeleteQuote,
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

  final Set<String> _selectedQuoteIds = {};
  bool _isSelectionMode = false;

  void _confirmDeleteCustomer(int index, String customerName) {
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
              'מחיקת לקוח',
              style: TextStyle(color: primaryDark, fontWeight: FontWeight.bold),
            ),
            content: Text(
              'האם אתה בטוח שברצונך למחוק את "$customerName"? הפעולה אינה הפיכה.',
              style: const TextStyle(color: Colors.black87),
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
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'מחיקת הצעה',
              style: TextStyle(
                color: primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'האם אתה בטוח שברצונך למחוק הצעה זו מתאריך ${quote['date'] ?? '—'}?',
              style: const TextStyle(color: Colors.black87),
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
    setState(() {
      _selectedQuoteIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _shareSelectedQuotes() async {
    final selected = widget.quotes
        .where((q) => _selectedQuoteIds.contains(q['id']))
        .toList();
    if (selected.isEmpty) return;

    try {
      final files = <XFile>[];
      final tempDir = Directory.systemTemp;

      for (int i = 0; i < selected.length; i++) {
        final q = selected[i];
        final bytes = await PdfService.generateQuotePdfBytes(
          customer: q['customer'] != null
              ? Map<String, String>.from(q['customer'] as Map)
              : null,
          items: List<Map<String, dynamic>>.from(q['items'] ?? []),
          total: (q['total'] as num?)?.toDouble() ?? 0.0,
          notes: q['notes'] as String?,
        );

        final title = q['title']?.toString() ?? 'הצעת מחיר';
        final safeName = title.replaceAll(RegExp(r'[^\w\s\-]'), '').trim();
        final file = File('${tempDir.path}/${safeName}_$i.pdf');
        await file.writeAsBytes(bytes);
        files.add(XFile(file.path));
      }

      await Share.shareXFiles(files);

      for (final f in files) {
        try {
          await File(f.path).delete();
        } catch (_) {}
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
          backgroundColor: primaryDark,
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
                        if (customerQuotes.isNotEmpty) ...[
                          const Text(
                            'הצעות מחיר',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: customerQuotes.map((quote) {
                              final items =
                                  quote['items'] as List<dynamic>? ?? [];
                              return GestureDetector(
                                onLongPress: () =>
                                    _toggleSelection(quote['id']),
                                onTap: _isSelectionMode
                                    ? () => _toggleSelection(quote['id'])
                                    : null,
                                child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF9F3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: const Border(
                                    right: BorderSide(
                                      color: Color(0xFFE88432),
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (_isSelectionMode)
                                          Checkbox(
                                            value: _selectedQuoteIds.contains(
                                              quote['id'],
                                            ),
                                            onChanged: (_) =>
                                                _toggleSelection(quote['id']),
                                            activeColor: accentOrange,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        Expanded(
                                          child: Text(
                                            quote['title']?.toString() ??
                                                'הצעת מחיר',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: primaryDark,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'סה״כ: ₪${quote['total']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: primaryDark,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'תאריך: ${quote['date'] ?? '—'}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${items.length} פריטים',
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (!_isSelectionMode)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 18,
                                                ),
                                                color: Colors.blueGrey,
                                                onPressed: () =>
                                                    widget.onEditQuote(quote),
                                              ),
                                              const SizedBox(width: 4),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                icon: const Icon(
                                                  Icons.share,
                                                  size: 18,
                                                ),
                                                color: Colors.teal,
                                                onPressed: () =>
                                                    widget.onShareQuote(quote),
                                              ),
                                              const SizedBox(width: 4),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 18,
                                                ),
                                                color: Colors.redAccent,
                                                onPressed: () =>
                                                    _confirmDeleteQuote(quote),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                        ],
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
                          child: TextButton(
                            onPressed: () => _confirmDeleteCustomer(
                              index,
                              customer['name'] ?? '',
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              textDirection: TextDirection.ltr,
                              children: [
                                const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'מחק לקוח',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        floatingActionButton: _isSelectionMode
            ? (_selectedQuoteIds.isNotEmpty
                ? FloatingActionButton.extended(
                    onPressed: () { _shareSelectedQuotes(); },
                    backgroundColor: accentOrange,
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: Text(
                      'שתף ${_selectedQuoteIds.length} הצעות',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink())
            : FloatingActionButton(
                onPressed: _openAddCustomerDialog,
                backgroundColor: accentOrange,
                elevation: 2,
                child: const Icon(Icons.add, color: Colors.white),
              ),
      ),
    );
  }
}
