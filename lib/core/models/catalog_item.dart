import 'package:cloud_firestore/cloud_firestore.dart';

/// Catalog item data model
class CatalogItem {
  final String id;
  final String name;
  final double price;

  CatalogItem({
    required this.id,
    required this.name,
    required this.price,
  });

  /// Create CatalogItem from Firestore document
  factory CatalogItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CatalogItem(
      id: doc.id,
      name: data['name'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Create CatalogItem from Map
  factory CatalogItem.fromMap(Map<String, dynamic> map) {
    return CatalogItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to Map for Firestore (without id)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
    };
  }

  /// Convert to Map with id
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  /// Create a copy with updated fields
  CatalogItem copyWith({
    String? id,
    String? name,
    double? price,
  }) {
    return CatalogItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  @override
  String toString() {
    return 'CatalogItem(id: $id, name: $name, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CatalogItem &&
        other.id == id &&
        other.name == name &&
        other.price == price;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ price.hashCode;
  }
}
