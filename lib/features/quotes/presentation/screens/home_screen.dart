import 'package:flutter/material.dart';
import 'customers_screen.dart';
import 'quote_builder_screen.dart';
import 'profile_screen.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Map<String, String>> _globalCustomers = [];
  List<Map<String, dynamic>> _globalCatalog = [];
  List<Map<String, dynamic>> _globalQuotes = [];
  bool _isLoading = true;
  String _businessName = '';

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

  Future<void> _deleteQuote(int index) async {
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
                  _deleteQuote(index);
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
    );
  }

  Widget _buildDashboardView() {
    // צבעי ערכת הנושא החומה-שמנת החדשה שלך
    const customPrimaryDark = Color(0xFF513222);
    const customAccentOrange = Color(0xFFE88432);

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
                        _selectedIndex = 2;
                      });
                    },
                  ),
                  _buildActionButton(
                    title: 'ניהול לקוחות',
                    icon: Icons.people_alt_rounded,
                    color: customPrimaryDark,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const Text(
                'הצעות מחיר אחרונות',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: customPrimaryDark,
                ),
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
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _globalQuotes.length > 5
                          ? 5
                          : _globalQuotes.length,
                      itemBuilder: (context, index) {
                        final reversedIndex = _globalQuotes.length - 1 - index;
                        final quote = _globalQuotes[reversedIndex];
                        final customerName = quote['customer'] != null
                            ? quote['customer']['name']
                            : 'לקוח כללי';

                        double total = 0;
                        if (quote['items'] != null) {
                          for (var item in quote['items']) {
                            total +=
                                (item['price'] ?? 0) * (item['quantity'] ?? 1);
                          }
                        }

                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.black12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: customAccentOrange.withValues(
                                alpha: 0.15,
                              ),
                              child: const Icon(
                                Icons.description_rounded,
                                color: customAccentOrange,
                              ),
                            ),
                            title: Text(
                              'הצעת מחיר #${reversedIndex + 1001}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: customPrimaryDark,
                              ),
                            ),
                            subtitle: Text(
                              'לקוח: $customerName',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₪ ${total.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: customAccentOrange,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: Colors.black38,
                                  ),
                                  onPressed: () =>
                                      _confirmDeleteQuote(reversedIndex),
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
      _buildDashboardView(),
      CustomersScreen(
        customers: _globalCustomers,
        quotes: _globalQuotes,
        onCustomerAdded: _addCustomer,
        onCustomerDeleted: _deleteCustomer,
        onGenerateSummary: _generateMonthlySummary,
      ),
      QuoteBuilderScreen(
        customers: _globalCustomers,
        catalog: _globalCatalog,
        onAddToCatalog: _addCatalogItem,
        onSaveQuote: _saveQuote,
        onDeleteFromCatalog: _confirmDeleteCatalogItem,
      ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'ראשי',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'לקוחות'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'הצעת מחיר',
          ),
        ],
      ),
    );
  }
}
