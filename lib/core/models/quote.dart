import 'package:cloud_firestore/cloud_firestore.dart';
import 'quote_item.dart';
import 'customer.dart';
import '../quote_status.dart';

/// Quote data model
class Quote {
  final String id;
  final int quoteNumber;
  final Customer customer;
  final List<QuoteItem> items;
  final double total;
  final double discount;
  final String date; // DD/MM/YYYY format
  final String title;
  final String notes;
  final QuoteStatus status;
  final Timestamp createdAt;

  Quote({
    required this.id,
    required this.quoteNumber,
    required this.customer,
    required this.items,
    required this.total,
    this.discount = 0.0,
    required this.date,
    this.title = '',
    this.notes = '',
    this.status = QuoteStatus.draft,
    required this.createdAt,
  });

  /// Create Quote from Firestore document
  factory Quote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse customer
    final customerMap = data['customer'] as Map<String, dynamic>?;
    final customer = customerMap != null
        ? Customer.fromMap(Map<String, String>.from(customerMap))
        : Customer(id: '', name: '', hp: '', address: '', phone: '');

    // Parse items
    final itemsList = data['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map((item) => QuoteItem.fromMap(item as Map<String, dynamic>))
        .toList();

    return Quote(
      id: doc.id,
      quoteNumber: data['quoteNumber'] as int? ?? 0,
      customer: customer,
      items: items,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
      date: data['date'] as String? ?? '',
      title: data['title'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      status: QuoteStatus.fromString(data['status'] as String?),
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Create Quote from Map
  factory Quote.fromMap(Map<String, dynamic> map) {
    // Parse customer
    final customerMap = map['customer'] as Map<String, dynamic>?;
    final customer = customerMap != null
        ? Customer.fromMap(Map<String, String>.from(customerMap))
        : Customer(id: '', name: '', hp: '', address: '', phone: '');

    // Parse items
    final itemsList = map['items'] as List<dynamic>? ?? [];
    final items = itemsList
        .map((item) => QuoteItem.fromMap(item as Map<String, dynamic>))
        .toList();

    return Quote(
      id: map['id'] as String? ?? '',
      quoteNumber: map['quoteNumber'] as int? ?? 0,
      customer: customer,
      items: items,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] as String? ?? '',
      title: map['title'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      status: QuoteStatus.fromString(map['status'] as String?),
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Convert to Map for Firestore (without id)
  Map<String, dynamic> toFirestore() {
    return {
      'quoteNumber': quoteNumber,
      'customer': customer.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'discount': discount,
      'date': date,
      'title': title,
      'notes': notes,
      'status': status.dbValue,
      'createdAt': createdAt,
    };
  }

  /// Convert to Map with id
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quoteNumber': quoteNumber,
      'customer': customer.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'discount': discount,
      'date': date,
      'title': title,
      'notes': notes,
      'status': status.dbValue,
      'createdAt': createdAt,
    };
  }

  /// Calculate subtotal (before discount)
  double get subtotal => items.fold(0.0, (total, item) => total + item.total);

  /// Calculate final total after discount
  double get finalTotal => total - discount;

  /// Check if quote is overdue (status not paid and date is in the past)
  bool isOverdue() {
    if (status == QuoteStatus.paid) return false;
    
    try {
      final parts = date.split('/');
      if (parts.length != 3) return false;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final quoteDate = DateTime(year, month, day);
      return quoteDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// Get number of days overdue
  int overdueDays() {
    if (!isOverdue()) return 0;
    
    try {
      final parts = date.split('/');
      if (parts.length != 3) return 0;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final quoteDate = DateTime(year, month, day);
      return DateTime.now().difference(quoteDate).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Create a copy with updated fields
  Quote copyWith({
    String? id,
    int? quoteNumber,
    Customer? customer,
    List<QuoteItem>? items,
    double? total,
    double? discount,
    String? date,
    String? title,
    String? notes,
    QuoteStatus? status,
    Timestamp? createdAt,
  }) {
    return Quote(
      id: id ?? this.id,
      quoteNumber: quoteNumber ?? this.quoteNumber,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      date: date ?? this.date,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Quote(id: $id, quoteNumber: $quoteNumber, customer: ${customer.name}, items: ${items.length}, total: $total, discount: $discount, status: ${status.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quote &&
        other.id == id &&
        other.quoteNumber == quoteNumber &&
        other.customer == customer &&
        other.total == total &&
        other.discount == discount &&
        other.date == date &&
        other.title == title &&
        other.notes == notes &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        quoteNumber.hashCode ^
        customer.hashCode ^
        total.hashCode ^
        discount.hashCode ^
        date.hashCode ^
        title.hashCode ^
        notes.hashCode ^
        status.hashCode;
  }
}
