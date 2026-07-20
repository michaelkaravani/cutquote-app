import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cutquote/core/firestore_service.dart';

class QuoteLoader {
  List<Map<String, dynamic>> quotes = [];
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  bool hasMore = false;
  bool isLoadingMore = false;
  bool isLoadingAll = false;
  static const int pageSize = 50;

  Future<bool> loadInitialPage(String uid) async {
    try {
      final page = await FirestoreService.loadQuotesPage(
        uid,
        limit: pageSize,
      );

      quotes = page.quotes;
      lastDocument = page.lastDocument;
      hasMore = page.hasMore;
      isLoadingMore = false;
      return true;
    } catch (e) {
      isLoadingMore = false;
      return false;
    }
  }

  Future<bool> loadMore(String uid) async {
    if (isLoadingMore || !_canLoadMore) return false;

    isLoadingMore = true;
    try {
      final page = await FirestoreService.loadQuotesPage(
        uid,
        limit: pageSize,
        startAfter: lastDocument,
      );

      _appendPage(page);
      isLoadingMore = false;
      return true;
    } catch (e) {
      isLoadingMore = false;
      return false;
    }
  }

  Future<bool> loadAllRemaining(String uid) async {
    if (isLoadingAll || !hasMore) return false;

    isLoadingAll = true;
    try {
      while (hasMore) {
        final page = await FirestoreService.loadQuotesPage(
          uid,
          limit: pageSize,
          startAfter: lastDocument,
        );

        _appendPage(page);
      }

      isLoadingAll = false;
      return true;
    } catch (e) {
      isLoadingAll = false;
      return false;
    }
  }

  void _appendPage(QuotePage page) {
    final existingIds = quotes
        .map((q) => q['id']?.toString())
        .whereType<String>()
        .toSet();

    quotes.addAll(
      page.quotes.where(
        (q) => !existingIds.contains(q['id']?.toString()),
      ),
    );
    lastDocument = page.lastDocument ?? lastDocument;
    hasMore = page.hasMore;
  }

  void reset() {
    quotes = [];
    lastDocument = null;
    hasMore = false;
    isLoadingMore = false;
    isLoadingAll = false;
  }

  bool get _canLoadMore {
    return hasMore && !isLoadingMore && !isLoadingAll;
  }
}
