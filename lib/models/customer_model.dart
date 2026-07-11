/// מייצג לקוח של בעל העסק. כל השדות הם String כי כך הם מוזנים בטפסים
/// (מספר טלפון/ח.פ יכולים להתחיל ב-0 ולכן נשמרים כטקסט, לא כמספר).
class Customer {
  final String? id;
  final String name;
  final String hp;
  final String address;
  final String phone;

  const Customer({
    this.id,
    required this.name,
    this.hp = '',
    this.address = '',
    this.phone = '',
  });

  /// יוצר עותק עם שדה id מעודכן (למשל אחרי שמירה ב-Firestore וקבלת מזהה).
  Customer copyWith({String? id}) {
    return Customer(
      id: id ?? this.id,
      name: name,
      hp: hp,
      address: address,
      phone: phone,
    );
  }

  Map<String, String> toMap() {
    return {'name': name, 'hp': hp, 'address': address, 'phone': phone};
  }

  factory Customer.fromMap(Map<String, dynamic> map, {String? id}) {
    return Customer(
      id: id,
      name: (map['name'] ?? '').toString(),
      hp: (map['hp'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
    );
  }
}
