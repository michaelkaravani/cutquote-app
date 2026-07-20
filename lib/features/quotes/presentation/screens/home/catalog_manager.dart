import 'package:cutquote/core/firestore_service.dart';

class CatalogManager {
  List<Map<String, dynamic>> catalog = [];

  Future<bool> addItem(String uid, Map<String, dynamic> newItem) async {
    if (_hasDuplicate(newItem['name'])) return false;

    try {
      final id = await FirestoreService.addCatalogItem(uid, newItem);
      final withId = Map<String, dynamic>.from(newItem)..['id'] = id;
      catalog.add(withId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateItem(int index, String uid, Map<String, dynamic> updatedItem) async {
    final original = catalog[index];
    final docId = original['id'];
    if (docId == null) return false;

    catalog[index] = Map<String, dynamic>.from(updatedItem)..['id'] = docId;

    try {
      final data = Map<String, dynamic>.from(updatedItem)..remove('id');
      await FirestoreService.updateCatalogItem(uid, docId, data);
      return true;
    } catch (e) {
      catalog[index] = original;
      return false;
    }
  }

  Future<bool> deleteItem(int index, String uid) async {
    final item = catalog[index];
    final docId = item['id'];

    catalog.removeAt(index);

    if (docId == null) return true;
    try {
      await FirestoreService.deleteCatalogItem(uid, docId);
      return true;
    } catch (e) {
      catalog.insert(index, item);
      return false;
    }
  }

  bool _hasDuplicate(String? name) {
    return catalog.any(
      (item) =>
          (item['name'] ?? '').toString().trim() ==
          (name ?? '').toString().trim(),
    );
  }
}
