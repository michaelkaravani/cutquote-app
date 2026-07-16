import 'package:flutter/material.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:cutquote/core/quote_status.dart';
import 'package:cutquote/core/quote_actions.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cutquote/csv_export_service.dart';
import 'package:cutquote/month_picker_dialog.dart';
import 'home/dashboard_view.dart';
import 'customers_screen.dart';
import 'quote_builder_screen.dart';
import 'profile_screen.dart';

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
  String get _businessName => _profile?['businessName'] as String? ?? '';
  Map<String, dynamic>? _profile;

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
          .where((q) => (q['status'] as String?) != QuoteStatus.paid.dbValue)
          .toList();
    }

    if (_selectedCustomerFilter != null) {
      result = result
          .where(
            (q) {
              final c = q['customer'] as Map?;
              if (c == null) return false;
              final name = c['name']?.toString() ?? '';
              final phone = c['phone']?.toString() ?? '';
              return '$name|$phone' == _selectedCustomerFilter;
            },
          )
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
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
        _profile = profile;
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
    QuoteActions.editQuote(
      context: context,
      quote: quote,
      profile: _profile,
      customers: _globalCustomers,
      catalog: _globalCatalog,
      onAddToCatalog: _addCatalogItem,
      onSaveQuote: _saveQuote,
      onDeleteFromCatalog: _confirmDeleteCatalogItem,
      onUpdateQuote: _updateQuote,
    );
  }

  bool _isQuoteOverdue(Map<String, dynamic> quote) {
    if (QuoteStatus.fromString(quote['status'] as String?) !=
        QuoteStatus.sent) {
      return false;
    }
    final createdAt = quote['createdAt'] as Timestamp?;
    if (createdAt == null) return false;
    return createdAt.toDate().isBefore(
      DateTime.now().subtract(const Duration(days: 7)),
    );
  }

  int _overdueDays(Map<String, dynamic> quote) {
    final createdAt = quote['createdAt'] as Timestamp?;
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt.toDate()).inDays;
  }

  Future<void> _callCustomer(Map<String, dynamic> quote) async {
    await QuoteActions.callCustomer(context, quote);
  }

  Future<void> _shareQuote(Map<String, dynamic> quote) async {
    await QuoteActions.shareQuote(
      context: context,
      quote: quote,
      allQuotes: _globalQuotes,
      businessName: _businessName,
      uid: _uid,
      profile: _profile,
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
    await QuoteActions.deleteQuoteByIndex(
      context: context,
      uid: _uid,
      allQuotes: _globalQuotes,
      index: index,
      onRemoved: (idx) {
        setState(() {
          _globalQuotes.removeAt(idx);
        });
      },
      onRollback: (idx, q) {
        setState(() {
          _globalQuotes.insert(idx, q);
        });
      },
    );
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
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'מחיקת פריט מהקטלוג',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'האם אתה בטוח שברצונך למחוק את "$itemName" מהקטלוג?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
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
    await QuoteActions.updateQuoteStatus(
      context: context,
      uid: _uid,
      quote: quote,
      newStatus: newStatus,
      onUpdated: (docId, status) {
        setState(() {
          quote['status'] = status;
        });
      },
    );
  }

  void _showStatusPicker(BuildContext context, Map<String, dynamic> quote) {
    final currentStatus = QuoteStatus.fromString(quote['status'] as String?);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    color: Theme.of(context).colorScheme.primary,
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
                        ? Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary)
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

  void _confirmDeleteQuote(int index) {
    QuoteActions.confirmDeleteQuote(
      context,
      index,
      (idx) {
        QuoteActions.deleteQuoteByIndex(
          context: context,
          uid: _uid,
          allQuotes: _globalQuotes,
          index: idx,
          onRemoved: (i) {
            setState(() {
              _globalQuotes.removeAt(i);
            });
          },
          onRollback: (i, q) {
            setState(() {
              _globalQuotes.insert(i, q);
            });
          },
        );
      },
    );
  }

  Future<void> _consolidateCustomerQuotesAsPdf(Map<String, String> customer) async {
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

    final freshProfile = await FirestoreService.loadProfile(_uid);
    final profile = freshProfile ?? _profile;

    PdfService.generateAndShareQuote(
      customer: customer,
      items: finalItems,
      total: finalTotal,
      filename: 'quote_${customer['name'] ?? 'general'}.pdf',
      notes: null,
      profile: profile,
    );
  }

  void _showCustomerFilterSheet() {
    final uniqueCustomers = <Map<String, String>>[];
    final seen = <String>{};
    for (final q in _globalQuotes) {
      final c = q['customer'] as Map?;
      if (c == null) continue;
      final name = c['name']?.toString() ?? '';
      if (name.trim().isEmpty) continue;
      final phone = c['phone']?.toString() ?? '';
      final key = '$name|$phone';
      if (seen.add(key)) {
        uniqueCustomers.add({'name': name, 'phone': phone, 'key': key});
      }
    }
    uniqueCustomers.sort((a, b) => a['name']!.compareTo(b['name']!));

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'בחר לקוח לסינון',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: uniqueCustomers.length,
                  itemBuilder: (context, i) {
                    final entry = uniqueCustomers[i];
                    final displayName = entry['phone']!.isNotEmpty
                        ? '${entry['name']} (${entry['phone']})'
                        : entry['name']!;
                    return ListTile(
                      title: Text(displayName),
                      trailing: _selectedCustomerFilter == entry['key']
                          ? Icon(Icons.check,
                              color: Theme.of(context).colorScheme.primary)
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedCustomerFilter = entry['key'];
                          _showOnlyPending = false;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportMonthlyRevenue() async {
    final result = await showMonthPickerDialog(context);
    if (result == null || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ),
    );

    try {
      final vatRate = (_profile?['vatRate'] as num?)?.toDouble() ?? 0.18;
      await CsvExportService.exportMonthlyRevenue(
        allQuotes: _globalQuotes,
        year: result.year,
        month: result.month,
        vatRate: vatRate,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildDashboardView() {
    return DashboardView(
      quotes: _globalQuotes,
      filteredQuotes: _filteredQuotes,
      businessName: _businessName,
      selectedCustomerFilter: _selectedCustomerFilter,
      showOnlyPending: _showOnlyPending,
      onShowCustomerFilter: _showCustomerFilterSheet,
      onExportMonthlyRevenue: _exportMonthlyRevenue,
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        ).then((_) {
          if (FirebaseAuth.instance.currentUser != null) {
            _loadAllData();
          }
        });
      },
      onClearFilter: () => setState(() {
        _selectedCustomerFilter = null;
        _showOnlyPending = false;
      }),
      onTogglePendingFilter: () => setState(() {
        _showOnlyPending = !_showOnlyPending;
        _selectedCustomerFilter = null;
      }),
      onNavigateToNewQuote: () => setState(() {
        _selectedIndex = 1;
      }),
      onNavigateToCustomers: () => setState(() {
        _selectedIndex = 0;
      }),
      onShowStatusPicker: _showStatusPicker,
      isQuoteOverdue: _isQuoteOverdue,
      overdueDays: _overdueDays,
      onCallCustomer: _callCustomer,
      onEditQuote: _editQuote,
      onShareQuote: _shareQuote,
      onConfirmDeleteQuote: _confirmDeleteQuote,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      );
    }

    final List<Widget> screens = [
      CustomersScreen(
        businessName: _businessName,
        profile: _profile,
        customers: _globalCustomers,
        quotes: _globalQuotes,
        onCustomerAdded: _addCustomer,
        onCustomerDeleted: _deleteCustomer,
        onGenerateSummary: _consolidateCustomerQuotesAsPdf,
        onEditQuote: _editQuote,
        onShareQuote: _shareQuote,
        onDeleteQuote: _deleteQuote,
        onUpdateQuoteStatus: (quoteId, newStatus) {
          FirestoreService.updateQuote(_uid, quoteId, {'status': newStatus});
          setState(() {
            final idx = _globalQuotes.indexWhere((q) => q['id'] == quoteId);
            if (idx != -1) {
              _globalQuotes[idx]['status'] = newStatus;
            }
          });
        },
      ),
      QuoteBuilderScreen(
        profile: _profile,
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
