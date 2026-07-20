import 'package:cutquote/core/firestore_service.dart';

class CustomerManager {
  List<Map<String, String>> customers = [];

  Future<bool> addCustomer(String uid, Map<String, String> newCustomer) async {
    try {
      final id = await FirestoreService.addCustomer(uid, newCustomer);
      final withId = Map<String, String>.from(newCustomer)..['id'] = id;
      customers.add(withId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCustomer(String uid, Map<String, String> updatedCustomer) async {
    final docId = updatedCustomer['id'];
    if (docId == null) return false;

    try {
      final data = Map<String, String>.from(updatedCustomer)..remove('id');
      await FirestoreService.updateCustomer(uid, docId, data);

      final idx = customers.indexWhere((c) => c['id'] == docId);
      if (idx != -1) customers[idx] = updatedCustomer;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCustomer(String uid, int index) async {
    if (index >= customers.length) return false;

    final customer = customers[index];
    final docId = customer['id'];

    customers.removeAt(index);

    if (docId == null) return true;

    try {
      await FirestoreService.deleteCustomer(uid, docId);
      return true;
    } catch (e) {
      customers.insert(index.clamp(0, customers.length), customer);
      return false;
    }
  }
}
