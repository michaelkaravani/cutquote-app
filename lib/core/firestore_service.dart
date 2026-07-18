import 'package:cloud_firestore/cloud_firestore.dart';

/// שירות לשמירה וטעינה של נתונים ב-Cloud Firestore, כאשר כל הנתונים
/// (לקוחות, קטלוג, הצעות מחיר) מבודדים תחת המשתמש המחובר (uid).
/// המבנה ב-Firestore:
///   users/{uid}                -> פרטי פרופיל העסק
///   users/{uid}/customers/{id} -> לקוחות
///   users/{uid}/catalog/{id}   -> פריטי קטלוג
///   users/{uid}/quotes/{id}    -> הצעות מחיר
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _customers(String uid) =>
      _db.collection('users').doc(uid).collection('customers');

  static CollectionReference<Map<String, dynamic>> _catalog(String uid) =>
      _db.collection('users').doc(uid).collection('catalog');

  static CollectionReference<Map<String, dynamic>> _quotes(String uid) =>
      _db.collection('users').doc(uid).collection('quotes');

  // --- לקוחות ---

  static Future<List<Map<String, String>>> loadCustomers(String uid) async {
    final snapshot = await _customers(uid).get();
    return snapshot.docs.map((doc) {
      final data = doc.data().map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// מוסיף לקוח חדש ומחזיר את המזהה (id) שקיבל המסמך ב-Firestore.
  static Future<String> addCustomer(
    String uid,
    Map<String, String> customer,
  ) async {
    final docRef = await _customers(uid).add(customer);
    return docRef.id;
  }

  static Future<void> deleteCustomer(String uid, String docId) async {
    await _customers(uid).doc(docId).delete();
  }

  static Future<void> updateCustomer(
    String uid,
    String docId,
    Map<String, String> data,
  ) async {
    await _customers(uid).doc(docId).update(data);
  }

  // --- קטלוג ---

  static Future<List<Map<String, dynamic>>> loadCatalog(String uid) async {
    final snapshot = await _catalog(uid).get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  static Future<String> addCatalogItem(
    String uid,
    Map<String, dynamic> item,
  ) async {
    final docRef = await _catalog(uid).add(item);
    return docRef.id;
  }

  static Future<void> updateCatalogItem(String uid, String docId, Map<String, dynamic> data) async {
    await _catalog(uid).doc(docId).update(data);
  }

  static Future<void> deleteCatalogItem(String uid, String docId) async {
    await _catalog(uid).doc(docId).delete();
  }

  // --- הצעות מחיר ---

  static Future<List<Map<String, dynamic>>> loadQuotes(String uid) async {
    final snapshot = await _quotes(uid).orderBy('createdAt').get();
    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  static Future<int> nextQuoteNumber(String uid) async {
    final snapshot = await _quotes(uid)
        .orderBy('quoteNumber', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return 1001;
    final lastNumber = snapshot.docs.first.data()['quoteNumber'] as int?;
    return (lastNumber ?? 1000) + 1;
  }

  static Future<Map<String, dynamic>> addQuote(String uid, Map<String, dynamic> quote) async {
    final number = await nextQuoteNumber(uid);
    final docRef = await _quotes(uid).add({
      ...quote,
      'quoteNumber': number,
      'status': quote['status'] ?? 'draft',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return {'id': docRef.id, 'quoteNumber': number};
  }

  static Future<void> updateQuote(
    String uid,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _quotes(uid).doc(docId).update(data);
  }

  static Future<void> deleteQuote(String uid, String docId) async {
    await _quotes(uid).doc(docId).delete();
  }

  // --- פרופיל עסק ---

  static Future<Map<String, dynamic>?> loadProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<void> saveProfile(
    String uid,
    Map<String, dynamic> profile,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .set(profile, SetOptions(merge: true));
  }
}
