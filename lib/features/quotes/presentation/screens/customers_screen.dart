import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/quote_status.dart';
import 'package:cutquote/core/firestore_service.dart';

class CustomersScreen extends StatefulWidget {
  final String businessName;
  final Map<String, dynamic>? profile;
  final List<Map<String, String>> customers;
  final List<Map<String, dynamic>> quotes;
  final Function(Map<String, String>) onCustomerAdded;
  final Function(int) onCustomerDeleted;
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
  final _nameController = TextEditingController();
  final _hpController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, String>> get _filteredCustomers {
    if (_searchQuery.isEmpty) return widget.customers;

    final query = _searchQuery.trim().toLowerCase();

    final quoteNumbers = <String, int>{};
    for (int i = 0; i < widget.quotes.length; i++) {
      quoteNumbers[widget.quotes[i]['id']] = i + 1001;
    }

    return widget.customers.where((customer) {
      if ((customer['name'] ?? '').toLowerCase().contains(query)) return true;
      if ((customer['phone'] ?? '').contains(query)) return true;

      for (final quote in widget.quotes) {
        if (quote['customer'] == null) continue;
        final quoteCustomer = quote['customer'] as Map;
        if (quoteCustomer['name'] != customer['name']) continue;

        final title = (quote['title']?.toString() ?? '').toLowerCase();
        if (title.contains(query)) return true;

        final number = quoteNumbers[quote['id']];
        if (number != null && number.toString().contains(query)) return true;
      }

      return false;
    }).toList();
  }

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

  Widget _buildStatusChip(Map<String, dynamic> quote) {
    final overdue = _isQuoteOverdue(quote);
    final status = QuoteStatus.fromString(quote['status'] as String?);
    return GestureDetector(
      onTap: _isSelectionMode
          ? null
          : () => _showStatusPicker(context, quote),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: overdue
              ? Colors.red.shade50
              : status.displayColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (overdue) ...[
              Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: Colors.red.shade800,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                overdue
                    ? 'ממתין ${_overdueDays(quote)} ימים ⏳'
                    : status.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: overdue
                      ? Colors.red.shade800
                      : status.displayColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(
    BuildContext context,
    Map<String, dynamic> quote,
  ) {
    final currentStatus =
        QuoteStatus.fromString(quote['status'] as String?);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'בחר סטטוס',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...QuoteStatus.values.map((status) {
                  final isSelected = status == currentStatus;
                  return ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: status.displayColor,
                      size: 20,
                    ),
                    title: Text(status.label),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: primaryDark,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      if (!isSelected) {
                        final docId = quote['id'] as String?;
                        if (docId != null) {
                          widget.onUpdateQuoteStatus
                              ?.call(docId, status.dbValue);
                          setState(() {
                            quote['status'] = status.dbValue;
                          });
                        }
                      }
                    },
                  );
                }),
              ],
            ),
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

  bool _isQuoteOverdue(Map<String, dynamic> quote) {
    if (QuoteStatus.fromString(quote['status'] as String?) !=
        QuoteStatus.sent) {
      return false;
    }
    final createdAt = quote['createdAt'] as Timestamp?;
    if (createdAt == null) return false;
    return createdAt
        .toDate()
        .isBefore(DateTime.now().subtract(const Duration(days: 7)));
  }

  int _overdueDays(Map<String, dynamic> quote) {
    final createdAt = quote['createdAt'] as Timestamp?;
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt.toDate()).inDays;
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
      final freshProfile =
          await FirestoreService.loadProfile(
        FirebaseAuth.instance.currentUser!.uid,
      );
      final profile = freshProfile ?? widget.profile;

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
          profile: profile,
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

      await Share.shareXFiles(files);

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

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'חיפוש לקוח...',
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: const Icon(Icons.search, color: Colors.black45),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.black45),
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
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentOrange, width: 1.5),
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
          style: TextStyle(color: Colors.black45, fontSize: 14),
        ),
      );
    }

    if (_filteredCustomers.isEmpty) {
      return const Center(
        child: Text(
          'לא נמצאו לקוחות המתאימים לחיפוש זה',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black45, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];

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
                              Flexible(
                                fit: FlexFit.loose,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildStatusChip(quote),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '${items.length} פריטים',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!_isSelectionMode)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_isQuoteOverdue(quote) &&
                                        quote['customer']?['phone']
                                                ?.toString() !=
                                            null) ...[
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.phone,
                                          size: 18,
                                          color: Colors.green,
                                        ),
                                        onPressed: () =>
                                            _callCustomer(quote),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
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
