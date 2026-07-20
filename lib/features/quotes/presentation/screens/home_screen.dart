import 'package:flutter/material.dart';
import 'package:cutquote/core/firestore_service.dart';
import 'package:cutquote/core/quote_actions.dart';
import 'package:cutquote/core/pdf_template_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home/dashboard_view.dart';
import 'home/quote_filter.dart';
import 'home/quote_loader.dart';
import 'home/app_bottom_nav.dart';
import 'home/catalog_delete_dialog.dart';
import 'home/catalog_manager.dart';
import 'home/customer_manager.dart';
import 'home/customer_delete_dialog.dart';
import 'home/customer_filter_sheet.dart';
import 'home/customer_pdf_exporter.dart';
import 'home/revenue_exporter.dart';
import 'home/status_picker.dart';
import 'customers_screen.dart';
import 'customers/quote_status_chip.dart';
import 'quote_builder_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _customerManager = CustomerManager();
  final _catalogManager = CatalogManager();
  final _quoteLoader = QuoteLoader();
  bool _isLoading = true;
  String get _businessName => _profile?['businessName'] as String? ?? '';
  Map<String, dynamic>? _profile;

  String? _selectedCustomerFilter;
  bool _showOnlyPending = false;
  String _dashboardSearchQuery = '';
  final _dashboardSearchController = TextEditingController();

  List<Map<String, dynamic>> get _filteredQuotes => QuoteFilter.apply(
    quotes: _quoteLoader.quotes,
    showOnlyPending: _showOnlyPending,
    selectedCustomerFilter: _selectedCustomerFilter,
    searchQuery: _dashboardSearchQuery,
  );

  bool get _canLoadMore => QuoteFilter.canLoadMore(
    hasMore: _quoteLoader.hasMore,
    searchQuery: _dashboardSearchQuery,
    showOnlyPending: _showOnlyPending,
    selectedCustomerFilter: _selectedCustomerFilter,
  );

  // מזהה המשתמש המחובר - כל הנתונים מבודדים תחת ה-uid הזה ב-Firestore
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _dashboardSearchController.addListener(() {
      setState(() {
        _dashboardSearchQuery = _dashboardSearchController.text;
      });
    });
    _loadAllData();
  }

  @override
  void dispose() {
    _dashboardSearchController.dispose();
    super.dispose();
  }

  Future<bool> _runOperation(Future<bool> Function() operation, String errorMessage) async {
    final success = await operation();
    if (!mounted) return false;
    setState(() {});
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
      );
    }
    return success;
  }

  Future<void> _loadMoreQuotes() async {
    final success = await _quoteLoader.loadMore(_uid);
    if (!mounted) return;
    setState(() {});
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שגיאה בטעינת הצעות נוספות'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _loadAllRemainingQuotes() async {
    await _quoteLoader.loadAllRemaining(_uid);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadAllData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final customers = await FirestoreService.loadCustomers(_uid);
      final catalog = await FirestoreService.loadCatalog(_uid);
      await _quoteLoader.loadInitialPage(_uid);
      final profile = await FirestoreService.loadProfile(_uid);

      if (!mounted) return;
      setState(() {
        _customerManager.customers = customers;
        _catalogManager.catalog = catalog;
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

  void _updateCustomer(Map<String, String> updatedCustomer) {
    _runOperation(
      () => _customerManager.updateCustomer(_uid, updatedCustomer),
      'שגיאה בעדכון לקוח',
    );
  }

  Future<void> _addCustomer(Map<String, String> newCustomer) async {
    await _runOperation(
      () => _customerManager.addCustomer(_uid, newCustomer),
      'שגיאה בהוספת לקוח',
    );
  }

  Future<void> _deleteCustomer(int index) async {
    final customer = _customerManager.customers[index];
    final docId = customer['id'];

    final customerQuotes = _quoteLoader.quotes.where((quote) {
      final qc = quote['customer'] as Map?;
      if (qc == null) return false;
      return qc['id'] == docId;
    }).toList();

    if (customerQuotes.isNotEmpty) {
      if (!mounted) return;
      final shouldProceed = await showDeleteCustomerWarningDialog(
        context: context,
        customerName: customer['name'] ?? '',
        quoteCount: customerQuotes.length,
      );
      if (!shouldProceed) return;
    }

    final success = await _customerManager.deleteCustomer(_uid, index);
    if (!mounted) return;
    setState(() {});
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('שגיאה במחיקת לקוח'),
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
      customers: _customerManager.customers,
      catalog: _catalogManager.catalog,
      onAddToCatalog: _addCatalogItem,
      onSaveQuote: _saveQuote,
      onDeleteFromCatalog: _confirmDeleteCatalogItem,
      onEditCatalogItem: _updateCatalogItem,
      onUpdateQuote: _updateQuote,
    );
  }

  bool _isQuoteOverdue(Map<String, dynamic> quote) =>
      QuoteStatusChip.isQuoteOverdue(quote);

  int _overdueDays(Map<String, dynamic> quote) =>
      QuoteStatusChip.overdueDays(quote);

  Future<void> _callCustomer(Map<String, dynamic> quote) async {
    await QuoteActions.callCustomer(context, quote);
  }

  Future<void> _shareQuote(Map<String, dynamic> quote) async {
    await QuoteActions.shareQuote(
      context: context,
      quote: quote,
      allQuotes: _quoteLoader.quotes,
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
      if (!mounted) return;
      final index = _quoteLoader.quotes.indexWhere((q) => q['id'] == docId);
      if (index != -1) {
        setState(() {
          _quoteLoader.quotes[index] = Map<String, dynamic>.from(updatedQuote);
        });
      }
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
    final index = _quoteLoader.quotes.indexWhere((q) => q['id'] == docId);
    if (index == -1) return;
    await QuoteActions.deleteQuoteByIndex(
      context: context,
      uid: _uid,
      allQuotes: _quoteLoader.quotes,
      index: index,
      onRemoved: (idx) {
        setState(() {
          _quoteLoader.quotes.removeAt(idx);
        });
      },
      onRollback: (idx, q) {
        setState(() {
          _quoteLoader.quotes.insert(idx, q);
        });
      },
    );
  }

  Future<void> _addCatalogItem(Map<String, dynamic> newItem) async {
    await _runOperation(
      () => _catalogManager.addItem(_uid, newItem),
      'שגיאה בהוספת פריט לקטלוג',
    );
  }

  Future<void> _updateCatalogItem(int index, Map<String, dynamic> updatedItem) async {
    await _runOperation(
      () => _catalogManager.updateItem(index, _uid, updatedItem),
      'שגיאה בעדכון פריט',
    );
  }

  void _confirmDeleteCatalogItem(int index) {
    final itemName = _catalogManager.catalog[index]['name'] ?? '';
    showConfirmDeleteCatalogItemDialog(
      context: context,
      itemName: itemName,
      onConfirm: () => _deleteCatalogItem(index),
    );
  }

  Future<void> _deleteCatalogItem(int index) async {
    await _runOperation(
      () => _catalogManager.deleteItem(index, _uid),
      'שגיאה במחיקת פריט מהקטלוג',
    );
  }

  Future<void> _saveQuote(Map<String, dynamic> newQuote) async {
    try {
      final result = await FirestoreService.addQuote(_uid, newQuote);
      if (!mounted) return;
      final withId = Map<String, dynamic>.from(newQuote)
        ..['id'] = result['id']
        ..['quoteNumber'] = result['quoteNumber']
        ..['createdAt'] = Timestamp.now();
      setState(() {
        _quoteLoader.quotes.add(withId);
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
    showStatusPicker(
      context: context,
      quote: quote,
      onUpdateStatus: (statusDbValue) {
        _updateQuoteStatus(quote, statusDbValue);
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
          allQuotes: _quoteLoader.quotes,
          index: idx,
          onRemoved: (i) {
            setState(() {
              _quoteLoader.quotes.removeAt(i);
            });
          },
          onRollback: (i, q) {
            setState(() {
              _quoteLoader.quotes.insert(i, q);
            });
          },
        );
      },
    );
  }

  Future<void> _consolidateCustomerQuotesAsPdf(Map<String, String> customer) async {
    await consolidateCustomerQuotesAsPdf(
      context: context,
      customer: customer,
      allQuotes: _quoteLoader.quotes,
      onEnsureAllQuotesLoaded: _loadAllRemainingQuotes,
      onLoadProfile: () => FirestoreService.loadProfile(_uid),
      pdfTemplateNotifier: pdfTemplateNotifier,
    );
  }

  Future<void> _showCustomerFilterSheet() async {
    try {
      await _loadAllRemainingQuotes();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('שגיאה בטעינת רשימת הלקוחות: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    if (!mounted) return;

    final result = await showCustomerFilterSheet(
      context: context,
      quotes: _quoteLoader.quotes,
      selectedCustomerFilter: _selectedCustomerFilter,
    );

    if (result != null && mounted) {
      setState(() {
        _selectedCustomerFilter = result['key'];
        _showOnlyPending = false;
      });
    }
  }

  Future<void> _exportMonthlyRevenue() async {
    await exportMonthlyRevenue(
      context: context,
      onEnsureAllQuotesLoaded: _loadAllRemainingQuotes,
      allQuotes: _quoteLoader.quotes,
      defaultVatRate: (_profile?['vatRate'] as num?)?.toDouble() ?? 0.18,
      vatExempt: _profile?['vatExempt'] == true,
    );
  }

  void _handleProfileTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    ).then((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        _loadAllData();
      }
    });
  }

  Widget _buildCustomersTab() {
    return CustomersScreen(
      businessName: _businessName,
      profile: _profile,
      customers: _customerManager.customers,
      quotes: _quoteLoader.quotes,
      onCustomerAdded: _addCustomer,
      onCustomerDeleted: _deleteCustomer,
      onCustomerUpdated: _updateCustomer,
      onGenerateSummary: _consolidateCustomerQuotesAsPdf,
      onEditQuote: _editQuote,
      onShareQuote: _shareQuote,
      onDeleteQuote: _deleteQuote,
      onUpdateQuoteStatus: _handleUpdateQuoteStatus,
    );
  }

  Widget _buildQuoteBuilderTab() {
    return QuoteBuilderScreen(
      profile: _profile,
      customers: _customerManager.customers,
      catalog: _catalogManager.catalog,
      onAddToCatalog: _addCatalogItem,
      onSaveQuote: _saveQuote,
      onDeleteFromCatalog: _confirmDeleteCatalogItem,
      onEditCatalogItem: _updateCatalogItem,
    );
  }

  Widget _buildDashboardView() {
    return DashboardView(
      quotes: _quoteLoader.quotes,
      filteredQuotes: _filteredQuotes,
      businessName: _businessName,
      selectedCustomerFilter: _selectedCustomerFilter,
      showOnlyPending: _showOnlyPending,
      onShowCustomerFilter: _showCustomerFilterSheet,
      onExportMonthlyRevenue: _exportMonthlyRevenue,
      onProfileTap: _handleProfileTap,
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
      dashboardSearchController: _dashboardSearchController,
      canLoadMore: _canLoadMore,
      isLoadingMore: _quoteLoader.isLoadingMore,
      onLoadMore: _loadMoreQuotes,
      totalFilteredCount: _filteredQuotes.length,
      hasUnloadedQuotes: _quoteLoader.hasMore,
    );
  }

  Future<void> _handleUpdateQuoteStatus(String quoteId, String newStatus) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirestoreService.updateQuote(_uid, quoteId, {'status': newStatus});
      if (!mounted) return;
      setState(() {
        final idx = _quoteLoader.quotes.indexWhere((q) => q['id'] == quoteId);
        if (idx != -1) {
          _quoteLoader.quotes[idx]['status'] = newStatus;
        }
      });
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('שגיאה בעדכון סטטוס: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
      _buildDashboardView(),
      _buildQuoteBuilderTab(),
      _buildCustomersTab(),
    ];

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
