import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'customers_screen.dart';
import 'quote_builder_screen.dart';
import 'profile_screen.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:cutquote/core/quote_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;

  List<Map<String, String>> _globalCustomers = [];
  List<Map<String, dynamic>> _globalCatalog = [];
  List<Map<String, dynamic>> _globalQuotes = [];
  bool _isLoading = true;
  String _businessName = '';

  String? _selectedCustomerFilter;
  bool _showOnlyPending = false;

  List<Map<String, dynamic>> get _filteredQuotes {
    var result = _globalQuotes.toList()
      ..sort((a, b) {
        final aDate = a['createdAt'] as Timestamp?;
        final bDate = b['createdAt'] as Timestamp?;
        if (aDate != null && bDate != null) return bDate.compareTo(aDate);
        return 0;
      });

    if (_showOnlyPending) {
      result = result
          .where(
              (q) => (q['status'] as String?) != QuoteStatus.paid.dbValue)
          .toList();
    }

    if (_selectedCustomerFilter != null) {
      result = result
          .where((q) =>
              q['customer']?['name']?.toString() == _selectedCustomerFilter)
          .toList();
    }

    return result;
  }

  // מזהה המשתמש המחובר - כל הנתונים מבודדים תחת ה-uid הזה ב-Firestore
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final customers = await FirestoreService.loadCustomers(_uid);
      final catalog = await FirestoreService.loadCatalog(_uid);
      final quotes = await FirestoreService.loadQuotes(_uid);
      final profile = await FirestoreService.loadProfile(_uid);

      if (!mounted) return;
      setState(() {
        _globalCustomers = customers;
        _globalQuotes = quotes;
        _globalCatalog = catalog; // פשוט טוען את מה שיש, בלי מוצרי ברירת מחדל!
        _businessName = profile?['businessName'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בטעינת הנתונים: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _addCustomer(Map<String, String> newCustomer) async {
    try {
      final id = await FirestoreService.addCustomer(_uid, newCustomer);
      final withId = Map<String, String>.from(newCustomer)..['id'] = id;
      setState(() {
        _globalCustomers.add(withId);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בהוספת לקוח: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _deleteCustomer(int index) async {
    final customer = _globalCustomers[index];
    final docId = customer['id'];

    setState(() {
      _globalCustomers.removeAt(index);
    });

    if (docId == null) return;
    try {
      await FirestoreService.deleteCustomer(_uid, docId);
    } catch (e) {
      if (!mounted) return;
      // מחזירים את הלקוח לרשימה אם המחיקה בענן נכשלה
      setState(() {
        _globalCustomers.insert(index, customer);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה במחיקת לקוח: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _editQuote(Map<String, dynamic> quote) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuoteBuilderScreen(
          customers: _globalCustomers,
          catalog: _globalCatalog,
          onAddToCatalog: _addCatalogItem,
          onSaveQuote: _saveQuote,
          onDeleteFromCatalog: _confirmDeleteCatalogItem,
          initialQuote: quote,
          onUpdateQuote: _updateQuote,
        ),
      ),
    );
  }

  String _generateShareMessage(Map<String, dynamic> quote, int index) {
    final customerName = quote['customer'] != null
        ? (quote['customer']['name']?.toString() ?? 'לקוח')
        : 'לקוח';
    final quoteNumber = index + 1001;
    final quoteTitle = quote['title']?.toString() ?? 'הצעת מחיר';
    final total = (quote['total'] as num?)?.toDouble() ?? 0.0;
    final totalFormatted = total.toStringAsFixed(0);
    final senderName = _businessName.isNotEmpty ? _businessName : 'העסק';

    return 'היי $customerName 👋 מצורפת הצעת מחיר מס\' $quoteNumber עבור \'$quoteTitle\' על סך $totalFormatted ₪. נשמח לאישורך כדי שנוכל להתקדם לייצור! תודה, $senderName.';
  }

  Future<void> _shareQuote(Map<String, dynamic> quote) async {
    final index = _globalQuotes.indexOf(quote);
    final message = _generateShareMessage(quote, index);

    await Clipboard.setData(ClipboardData(text: message));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('הודעת השיתוף הועתקה ללוח! הדבק אותה בוואטסאפ'),
          duration: Duration(seconds: 3),
        ),
      );
    }

    final customer = Map<String, String>.from(quote['customer'] ?? {});
    PdfService.generateAndShareQuote(
      customer: customer,
      items: List<Map<String, dynamic>>.from(quote['items'] ?? []),
      total: (quote['total'] as num?)?.toDouble() ?? 0.0,
      filename: 'quote_${customer['name'] ?? 'general'}.pdf',
      notes: quote['notes'] as String?,
    );
  }

  Future<void> _updateQuote(Map<String, dynamic> updatedQuote) async {
    final docId = updatedQuote['id'] as String?;
    if (docId == null) return;

    final dataToSave = Map<String, dynamic>.from(updatedQuote)..remove('id');

    try {
      await FirestoreService.updateQuote(_uid, docId, dataToSave);
      final index = _globalQuotes.indexWhere((q) => q['id'] == docId);
      if (index != -1) {
        setState(() {
          _globalQuotes[index] = Map<String, dynamic>.from(updatedQuote);
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('הצעת המחיר עודכנה בהצלחה!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בעדכון הצעת המחיר: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _deleteQuote(Map<String, dynamic> quote) async {
    final docId = quote['id'] as String?;
    final index = _globalQuotes.indexWhere((q) => q['id'] == docId);
    if (index == -1) return;
    await _deleteQuoteByIndex(index);
  }

  Future<void> _addCatalogItem(Map<String, dynamic> newItem) async {
    final exists = _globalCatalog.any(
      (item) =>
          item['name'].toString().trim() == newItem['name'].toString().trim(),
    );
    if (exists) return;

    try {
      final id = await FirestoreService.addCatalogItem(_uid, newItem);
      final withId = Map<String, dynamic>.from(newItem)..['id'] = id;
      setState(() {
        _globalCatalog.add(withId);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בהוספת פריט לקטלוג: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _confirmDeleteCatalogItem(int index) {
    final itemName = _globalCatalog[index]['name'] ?? '';
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
            title: const Text(
              'מחיקת פריט מהקטלוג',
              style: TextStyle(
                color: Color(0xFF513222),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'האם אתה בטוח שברצונך למחוק את "$itemName" מהקטלוג?',
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
                  _deleteCatalogItem(index);
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

  Future<void> _deleteCatalogItem(int index) async {
    final item = _globalCatalog[index];
    final docId = item['id'];

    setState(() {
      _globalCatalog.removeAt(index);
    });

    if (docId == null) return;
    try {
      await FirestoreService.deleteCatalogItem(_uid, docId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _globalCatalog.insert(index, item);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה במחיקת פריט מהקטלוג: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _saveQuote(Map<String, dynamic> newQuote) async {
    try {
      final id = await FirestoreService.addQuote(_uid, newQuote);
      final withId = Map<String, dynamic>.from(newQuote)..['id'] = id;
      setState(() {
        _globalQuotes.add(withId);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בשמירת הצעת המחיר: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _updateQuoteStatus(
    Map<String, dynamic> quote,
    String newStatus,
  ) async {
    final docId = quote['id'] as String?;
    if (docId == null) return;

    try {
      await FirestoreService.updateQuote(_uid, docId, {'status': newStatus});
      setState(() {
        quote['status'] = newStatus;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בעדכון סטטוס: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
                const Text(
                  'בחר סטטוס',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF513222),
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
                        ? const Icon(
                            Icons.check,
                            color: Color(0xFF513222),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      if (!isSelected) {
                        _updateQuoteStatus(quote, status.dbValue);
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

  Future<void> _deleteQuoteByIndex(int index) async {
    final quote = _globalQuotes[index];
    final docId = quote['id'];

    setState(() {
      _globalQuotes.removeAt(index);
    });

    if (docId == null) return;
    try {
      await FirestoreService.deleteQuote(_uid, docId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _globalQuotes.insert(index, quote);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה במחיקת הצעת המחיר: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _confirmDeleteQuote(int index) {
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
            title: const Text(
              'מחיקת הצעת מחיר',
              style: TextStyle(
                color: Color(0xFF513222),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'האם אתה בטוח שברצונך למחוק את הצעת המחיר? הפעולה אינה הפיכה.',
              style: TextStyle(color: Colors.black87),
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
                  _deleteQuoteByIndex(index);
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

  void _generateMonthlySummary(Map<String, String> customer) {
    final customerQuotes = _globalQuotes
        .where(
          (quote) =>
              quote['customer'] != null &&
              quote['customer']['name'] == customer['name'],
        )
        .toList();

    if (customerQuotes.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('לא נמצאו הצעות מחיר שמורות עבור לקוח זה'),
        ),
      );
      return;
    }

    final Map<String, Map<String, dynamic>> consolidatedItems = {};

    for (var quote in customerQuotes) {
      final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
        quote['items'],
      );
      for (var item in items) {
        final String name = item['name'];
        final int quantity = item['quantity'];
        final double price = item['price'];

        if (consolidatedItems.containsKey(name)) {
          consolidatedItems[name]!['quantity'] += quantity;
        } else {
          consolidatedItems[name] = {
            'name': name,
            'quantity': quantity,
            'price': price,
          };
        }
      }
    }

    final List<Map<String, dynamic>> finalItems = consolidatedItems.values
        .toList();

    double finalTotal = 0;
    for (var item in finalItems) {
      finalTotal += item['price'] * item['quantity'];
    }

    PdfService.generateAndShareQuote(
      customer: customer,
      items: finalItems,
      total: finalTotal,
      filename: 'quote_${customer['name'] ?? 'general'}.pdf',
      notes: null,
    );
  }

  void _showCustomerFilterSheet() {
    final uniqueNames = _globalQuotes
        .where((q) =>
            q['customer'] != null &&
            q['customer']['name'] != null &&
            q['customer']['name'].toString().trim().isNotEmpty)
        .map((q) => q['customer']['name'].toString())
        .toSet()
        .toList()
      ..sort();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'בחר לקוח לסינון',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF513222),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: uniqueNames.length,
                  itemBuilder: (context, i) => ListTile(
                    title: Text(uniqueNames[i]),
                    trailing: _selectedCustomerFilter == uniqueNames[i]
                        ? const Icon(
                            Icons.check,
                            color: Color(0xFF513222),
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _selectedCustomerFilter = uniqueNames[i];
                        _showOnlyPending = false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardView() {
    // צבעי ערכת הנושא החומה-שמנת החדשה שלך
    const customPrimaryDark = Color(0xFF513222);
    const customAccentOrange = Color(0xFFE88432);

    Widget kpiCard(
      IconData icon,
      String value,
      String label, {
      VoidCallback? onTap,
      bool isActive = false,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive
                ? customAccentOrange.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: customAccentOrange, width: 1.5)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: customAccentOrange, size: 22),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: customPrimaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    String formatCurrency(double amount) {
      final whole = amount.floor();
      final str = whole.toString();
      final buffer = StringBuffer();
      int count = 0;
      for (int i = str.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) buffer.write(',');
        buffer.write(str[i]);
        count++;
      }
      return '₪${buffer.toString().split('').reversed.join()}';
    }

    Widget buildKpiRow() {
      final totalQuotes = _globalQuotes.length;

      final uniqueCustomers = _globalQuotes
          .where((q) =>
              q['customer'] != null &&
              q['customer']['name'] != null &&
              q['customer']['name'].toString().trim().isNotEmpty)
          .map((q) => q['customer']['name'].toString())
          .toSet()
          .length;

      double pendingTotal = 0;
      for (final q in _globalQuotes) {
        final status = q['status'] as String?;
        if (status != QuoteStatus.paid.dbValue) {
          pendingTotal += (q['total'] as num?)?.toDouble() ?? 0;
        }
      }

      final formattedPending = formatCurrency(pendingTotal);

      return Row(
        children: [
          Expanded(
            child: kpiCard(
              Icons.description_outlined,
              '$totalQuotes',
              'הצעות',
              onTap: () => setState(() {
                _selectedCustomerFilter = null;
                _showOnlyPending = false;
              }),
              isActive: _selectedCustomerFilter == null && !_showOnlyPending,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: kpiCard(
              Icons.people_outline,
              '$uniqueCustomers',
              'לקוחות',
              onTap: _showCustomerFilterSheet,
              isActive: _selectedCustomerFilter != null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: kpiCard(
              Icons.trending_up,
              formattedPending,
              'סה"כ פתוח',
              onTap: () => setState(() {
                _showOnlyPending = !_showOnlyPending;
                _selectedCustomerFilter = null;
              }),
              isActive: _showOnlyPending,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      appBar: AppBar(
        title: const Text(
          'CutQuote Pro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF513222),
        elevation: 0,
        centerTitle: true,
        // השארנו את leading ריק כדי שלא יתפוס מקום
        leading: null,
        // העברנו את האייקון ל-actions כדי שימוקם בצד שמאל
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0), // ריווח קטן מהקצה
            child: IconButton(
              icon: const Icon(
                Icons.account_circle_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ).then((_) => _loadAllData());
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _businessName.isEmpty ? 'שלום,' : 'שלום $_businessName,',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: customPrimaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ניהול הצעות מחיר וחישובי ייצור בזמן אמת',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              const Text(
                'פעולות מהירות',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: customPrimaryDark,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildActionButton(
                    title: 'הצעת מחיר חדשה',
                    icon: Icons.calculate_rounded,
                    color: customAccentOrange,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                  _buildActionButton(
                    title: 'ניהול לקוחות',
                    icon: Icons.people_alt_rounded,
                    color: customPrimaryDark,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              buildKpiRow(),
              const SizedBox(height: 24),

              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'הצעות מחיר אחרונות',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: customPrimaryDark,
                      ),
                    ),
                    if (_selectedCustomerFilter != null ||
                        _showOnlyPending)
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _selectedCustomerFilter = null;
                          _showOnlyPending = false;
                        }),
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF513222),
                        ),
                        label: const Text(
                          'נקה סינון',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF513222),
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 12),
              _globalQuotes.isEmpty
                  ? Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'אין עדיין הצעות מחיר שמורות. לחץ על הצעת מחיר חדשה כדי להתחיל.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    )
                  : _filteredQuotes.isEmpty
                      ? Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.black12),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'לא נמצאו הצעות מחיר העונות לסינון זה',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredQuotes.length > 5
                              ? 5
                              : _filteredQuotes.length,
                          itemBuilder: (context, index) {
                            final quote = _filteredQuotes[index];
                            final customerName =
                                quote['customer'] != null
                                    ? quote['customer']['name']
                                    : 'לקוח כללי';

                            double total = 0;
                            if (quote['items'] != null) {
                              for (var item in quote['items']) {
                                total += (item['price'] ?? 0) *
                                    (item['quantity'] ?? 1);
                              }
                            }

                            return Card(
                              color: Colors.white,
                              elevation: 0,
                              margin:
                                  const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                side: const BorderSide(
                                    color: Colors.black12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              customAccentOrange
                                                  .withValues(
                                                alpha: 0.15,
                                              ),
                                          child: const Icon(
                                            Icons
                                                .description_rounded,
                                            color:
                                                customAccentOrange,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                '${quote['title'] ?? 'הצעת מחיר'} #${index + 1001}',
                                                style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color:
                                                      customPrimaryDark,
                                                ),
                                              ),
                                              Text(
                                                'לקוח: $customerName',
                                                style: const TextStyle(
                                                  color:
                                                      Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '₪ ${total.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                            color:
                                                customAccentOrange,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _showStatusPicker(
                                                  context, quote),
                                          child: Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration:
                                                BoxDecoration(
                                              color: QuoteStatus
                                                  .fromString(
                                                quote['status']
                                                    as String?,
                                              )
                                                  .displayColor
                                                  .withValues(
                                                      alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(12),
                                            ),
                                            child: Text(
                                              QuoteStatus.fromString(
                                                quote['status']
                                                    as String?,
                                              ).label,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: QuoteStatus
                                                    .fromString(
                                                  quote['status']
                                                      as String?,
                                                ).displayColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              padding:
                                                  EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 18,
                                                color:
                                                    Colors.blueGrey,
                                              ),
                                              onPressed: () =>
                                                  _editQuote(quote),
                                            ),
                                            const SizedBox(
                                                width: 4),
                                            IconButton(
                                              padding:
                                                  EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(
                                                Icons.share,
                                                size: 18,
                                                color: Colors.teal,
                                              ),
                                              onPressed: () =>
                                                  _shareQuote(
                                                      quote),
                                            ),
                                            const SizedBox(
                                                width: 4),
                                            IconButton(
                                              padding:
                                                  EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                                color:
                                                    Colors.black38,
                                              ),
                                              onPressed: () {
                                                final idx = _globalQuotes
                                                    .indexWhere(
                                                        (q) =>
                                                            q['id'] ==
                                                            quote[
                                                                'id']);
                                                if (idx != -1) {
                                                  _confirmDeleteQuote(
                                                      idx);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF7F0),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE88432)),
        ),
      );
    }

    final List<Widget> screens = [
      CustomersScreen(
        businessName: _businessName,
        customers: _globalCustomers,
        quotes: _globalQuotes,
        onCustomerAdded: _addCustomer,
        onCustomerDeleted: _deleteCustomer,
        onGenerateSummary: _generateMonthlySummary,
        onEditQuote: _editQuote,
        onShareQuote: _shareQuote,
        onDeleteQuote: _deleteQuote,
        onUpdateQuoteStatus: (quoteId, newStatus) {
          FirestoreService.updateQuote(
            _uid,
            quoteId,
            {'status': newStatus},
          );
          setState(() {
            final idx =
                _globalQuotes.indexWhere((q) => q['id'] == quoteId);
            if (idx != -1) {
              _globalQuotes[idx]['status'] = newStatus;
            }
          });
        },
      ),
      QuoteBuilderScreen(
        customers: _globalCustomers,
        catalog: _globalCatalog,
        onAddToCatalog: _addCatalogItem,
        onSaveQuote: _saveQuote,
        onDeleteFromCatalog: _confirmDeleteCatalogItem,
      ),
      _buildDashboardView(),
    ];

    // כאן נפתרת שגיאת הליקולזציה: ה-Scaffold מוחזר ישירות, וה-Directionality עוטף אך ורק את ה-body הפנימי!
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFE88432),
        unselectedItemColor: const Color(0xFF513222).withValues(alpha: 0.5),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'לקוחות'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'הצעת מחיר',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'ראשי',
          ),
        ],
      ),
    );
  }
}
