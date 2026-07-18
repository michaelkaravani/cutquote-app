import 'package:cloud_firestore/cloud_firestore.dart';

/// Customer data model
class Customer {
  final String id;
  final String name;
  final String hp; // Company/Tax ID
  final String address;
  final String phone;

  Customer({
    required this.id,
    required this.name,
    required this.hp,
    required this.address,
    required this.phone,
  });

  /// Create Customer from Firestore document
  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      name: data['name'] as String? ?? '',
      hp: data['hp'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }

  /// Create Customer from Map
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      hp: map['hp'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
    );
  }

  /// Convert to Map for Firestore (without id)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'hp': hp,
      'address': address,
      'phone': phone,
    };
  }

  /// Convert to Map with id (for embedding in quotes)
  Map<String, String> toMap() {
    return {
      'id': id,
      'name': name,
      'hp': hp,
      'address': address,
      'phone': phone,
    };
  }

  /// Create a copy with updated fields
  Customer copyWith({
    String? id,
    String? name,
    String? hp,
    String? address,
    String? phone,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      hp: hp ?? this.hp,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name, hp: $hp, address: $address, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer &&
        other.id == id &&
        other.name == name &&
        other.hp == hp &&
        other.address == address &&
        other.phone == phone;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        hp.hashCode ^
        address.hashCode ^
        phone.hashCode;
  }
}
