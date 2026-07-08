class QuoteItem {
  final String name;
  final double price;
  final int quantity;

  QuoteItem({required this.name, required this.price, this.quantity = 1});

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price, 'quantity': quantity};
  }

  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    return QuoteItem(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}
