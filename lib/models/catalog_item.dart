/// מייצג פריט קבוע בקטלוג/מועדפים של בעל העסק (למשל שירות או מוצר שחוזר על עצמו
/// בהצעות מחיר שונות).
class CatalogItem {
  final String? id;
  final String name;
  final double price;

  const CatalogItem({this.id, required this.name, required this.price});

  CatalogItem copyWith({String? id}) {
    return CatalogItem(id: id ?? this.id, name: name, price: price);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price};
  }

  factory CatalogItem.fromMap(Map<String, dynamic> map, {String? id}) {
    return CatalogItem(
      id: id,
      name: (map['name'] ?? '').toString(),
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0.0,
    );
  }
}
