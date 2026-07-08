import 'package:flutter/material.dart';
import 'customers_screen.dart';
import 'quote_builder_screen.dart';
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
  bool _isLoading = true; // משתנה שמראה אם האפליקציה עדיין טוענת נתונים מהדיסק

  @override
  void initState() {
    super.initState();
    _loadAllData(); // טעינת כל הנתונים השמורים מיד כשהאפליקציה נדלקת
  }

  // פונקציית טעינה מהדיסק של הטלפון
  Future<void> _loadAllData() async {
    final customers = await StorageService.loadCustomers();
    final catalog = await StorageService.loadCatalog();
    final quotes = await StorageService.loadQuotes();

    setState(() {
      _globalCustomers = customers;
      _globalQuotes = quotes;

      // אם הקטלוג ריק בטלפון (פעם ראשונה שהאפליקציה עולה), נשים מוצרי ברירת מחדל
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

  // שמירה ועדכון לקוחות
  void _addCustomer(Map<String, String> newCustomer) {
    setState(() {
      _globalCustomers.add(newCustomer);
    });
    StorageService.saveCustomers(_globalCustomers); // שמירה קבועה
  }

  void _deleteCustomer(int index) {
    setState(() {
      _globalCustomers.removeAt(index);
    });
    StorageService.saveCustomers(_globalCustomers); // שמירה קבועה
  }

  // שמירה ועדכון קטלוג
  void _addCatalogItem(Map<String, dynamic> newItem) {
    final exists = _globalCatalog.any(
      (item) =>
          item['name'].toString().trim() == newItem['name'].toString().trim(),
    );
    if (!exists) {
      setState(() {
        _globalCatalog.add(newItem);
      });
      StorageService.saveCatalog(_globalCatalog); // שמירה קבועה
    }
  }

  // שמירה ועדכון הצעות מחיר
  void _saveQuote(Map<String, dynamic> newQuote) {
    setState(() {
      _globalQuotes.add(newQuote);
    });
    StorageService.saveQuotes(_globalQuotes); // שמירה קבועה
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

  @override
  Widget build(BuildContext context) {
    // אם המידע עדיין נטען מהדיסק, נציג אינדיקטור טעינה יפה במרכז המסך
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    final List<Widget> screens = [
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
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
          ],
        ),
      ),
    );
  }
}
