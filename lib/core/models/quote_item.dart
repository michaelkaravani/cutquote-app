/// Quote item (line item) data model
class QuoteItem {
  final String name;
  final double price;
  final int quantity;

  QuoteItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  /// Create QuoteItem from Map
  factory QuoteItem.fromMap(Map<String, dynamic> map) {
    return QuoteItem(
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 1,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  /// Calculate total for this item
  double get total => price * quantity;

  /// Create a copy with updated fields
  QuoteItem copyWith({
    String? name,
    double? price,
    int? quantity,
  }) {
    return QuoteItem(
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'QuoteItem(name: $name, price: $price, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuoteItem &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return name.hashCode ^ price.hashCode ^ quantity.hashCode;
  }
}
