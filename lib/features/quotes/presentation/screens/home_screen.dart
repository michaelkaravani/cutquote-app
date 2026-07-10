import 'package:flutter/material.dart';
import 'customers_screen.dart';
import 'quote_builder_screen.dart';
import 'profile_screen.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/storage_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final customers = await StorageService.loadCustomers();
    final catalog = await StorageService.loadCatalog();
    final quotes = await StorageService.loadQuotes();

    if (!mounted) {
      return;
    }

    setState(() {
      _globalCustomers = customers;
      _globalQuotes = quotes;

      if (catalog.isEmpty) {
        _globalCatalog = [
          {'name': 'פלטת אלומיניום שחור מט', 'price': 150.0},
          {'name': 'חיתוך לייזר מדוייק', 'price': 85.0},
        ];
        StorageService.saveCatalog(_globalCatalog);
      } else {
        _globalCatalog = catalog;
      }
      _isLoading = false;
    });
  }

  void _addCustomer(Map<String, String> newCustomer) {
    setState(() {
      _globalCustomers.add(newCustomer);
    });
    StorageService.saveCustomers(_globalCustomers);
  }

  void _deleteCustomer(int index) {
    setState(() {
      _globalCustomers.removeAt(index);
    });
    StorageService.saveCustomers(_globalCustomers);
  }

  void _addCatalogItem(Map<String, dynamic> newItem) {
    final exists = _globalCatalog.any(
      (item) =>
          item['name'].toString().trim() == newItem['name'].toString().trim(),
    );
    if (!exists) {
      setState(() {
        _globalCatalog.add(newItem);
      });
      StorageService.saveCatalog(_globalCatalog);
    }
  }

  void _saveQuote(Map<String, dynamic> newQuote) {
    setState(() {
      _globalQuotes.add(newQuote);
    });
    StorageService.saveQuotes(_globalQuotes);
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
                );
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
              const Text(
                'שלום מיכאל,',
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
                            trailing: Text(
                              '₪ ${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: customAccentOrange,
                                fontSize: 16,
                              ),
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
