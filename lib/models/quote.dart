import 'package:cutquote/models/customer_model.dart';
import 'package:cutquote/models/quote_item.dart';

/// מייצג הצעת מחיר שמורה. שים לב ש-Customer יכול להיות null (הצעה ל"לקוח כללי").
class Quote {
  final String? id;
  final Customer? customer;
  final List<QuoteItem> items;
  final double total;
  final String date;

  const Quote({
    this.id,
    this.customer,
    required this.items,
    required this.total,
    required this.date,
  });

  Quote copyWith({String? id}) {
    return Quote(
      id: id ?? this.id,
      customer: customer,
      items: items,
      total: total,
      date: date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer': customer?.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'date': date,
    };
  }

  factory Quote.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawCustomer = map['customer'];
    final rawItems = map['items'];

    return Quote(
      id: id,
      customer: (rawCustomer is Map<String, dynamic>)
          ? Customer.fromMap(rawCustomer)
          : null,
      items: (rawItems is List)
          ? rawItems
                .whereType<Map>()
                .map((e) => QuoteItem.fromMap(Map<String, dynamic>.from(e)))
                .toList()
          : <QuoteItem>[],
      total: (map['total'] is num) ? (map['total'] as num).toDouble() : 0.0,
      date: (map['date'] ?? '').toString(),
    );
  }
}
