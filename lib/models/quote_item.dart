/// שורת פריט בתוך הצעת מחיר ספציפית (לא להתבלבל עם CatalogItem, שהוא הפריט
/// השמור במועדפים - QuoteItem הוא "עותק קפוא" של הפריט בזמן יצירת ההצעה).
class QuoteItem {
  final String name;
  final double price;
  final int quantity;

  const QuoteItem({required this.name, required this.price, this.quantity = 1});

  double get total => price * quantity;

  QuoteItem copyWith({String? name, double? price, int? quantity}) {
    return QuoteItem(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price, 'quantity': quantity};
  }

  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    return QuoteItem(
      name: (json['name'] ?? '').toString(),
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toInt()
          : 1,
    );
  }

  /// alias נוח לעקביות עם שאר המודלים (toMap/fromMap)
  Map<String, dynamic> toMap() => toJson();
  factory QuoteItem.fromMap(Map<String, dynamic> map) =>
      QuoteItem.fromJson(map);
}
