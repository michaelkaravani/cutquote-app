import 'package:cloud_firestore/cloud_firestore.dart';

/// Business profile data model
class Profile {
  final String businessName;
  final String phone;
  final String email;
  final String? logoPath;
  final double vatRate;
  final bool vatExempt;
  final String defaultPdfNotes;
  final String paymentTerms;
  final String pdfTemplateStyle;

  Profile({
    required this.businessName,
    required this.phone,
    required this.email,
    this.logoPath,
    this.vatRate = 0.17,
    this.vatExempt = false,
    this.defaultPdfNotes = '',
    this.paymentTerms = '',
    this.pdfTemplateStyle = 'premium_dark',
  });

  /// Create Profile from Firestore document
  factory Profile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Profile(
      businessName: data['businessName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      logoPath: data['logoPath'] as String?,
      vatRate: (data['vatRate'] as num?)?.toDouble() ?? 0.17,
      vatExempt: data['vatExempt'] as bool? ?? false,
      defaultPdfNotes: data['defaultPdfNotes'] as String? ?? '',
      paymentTerms: data['paymentTerms'] as String? ?? '',
      pdfTemplateStyle: data['pdfTemplateStyle'] as String? ?? 'premium_dark',
    );
  }

  /// Create Profile from Map
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      businessName: map['businessName'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      logoPath: map['logoPath'] as String?,
      vatRate: (map['vatRate'] as num?)?.toDouble() ?? 0.17,
      vatExempt: map['vatExempt'] as bool? ?? false,
      defaultPdfNotes: map['defaultPdfNotes'] as String? ?? '',
      paymentTerms: map['paymentTerms'] as String? ?? '',
      pdfTemplateStyle: map['pdfTemplateStyle'] as String? ?? 'premium_dark',
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'businessName': businessName,
      'phone': phone,
      'email': email,
      'logoPath': logoPath,
      'vatRate': vatRate,
      'vatExempt': vatExempt,
      'defaultPdfNotes': defaultPdfNotes,
      'paymentTerms': paymentTerms,
      'pdfTemplateStyle': pdfTemplateStyle,
    };
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'phone': phone,
      'email': email,
      'logoPath': logoPath,
      'vatRate': vatRate,
      'vatExempt': vatExempt,
      'defaultPdfNotes': defaultPdfNotes,
      'paymentTerms': paymentTerms,
      'pdfTemplateStyle': pdfTemplateStyle,
    };
  }

  /// Create a copy with updated fields
  Profile copyWith({
    String? businessName,
    String? phone,
    String? email,
    String? logoPath,
    double? vatRate,
    bool? vatExempt,
    String? defaultPdfNotes,
    String? paymentTerms,
    String? pdfTemplateStyle,
  }) {
    return Profile(
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoPath: logoPath ?? this.logoPath,
      vatRate: vatRate ?? this.vatRate,
      vatExempt: vatExempt ?? this.vatExempt,
      defaultPdfNotes: defaultPdfNotes ?? this.defaultPdfNotes,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      pdfTemplateStyle: pdfTemplateStyle ?? this.pdfTemplateStyle,
    );
  }

  @override
  String toString() {
    return 'Profile(businessName: $businessName, phone: $phone, email: $email, logoPath: $logoPath, vatRate: $vatRate, vatExempt: $vatExempt, pdfTemplateStyle: $pdfTemplateStyle)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile &&
        other.businessName == businessName &&
        other.phone == phone &&
        other.email == email &&
        other.logoPath == logoPath &&
        other.vatRate == vatRate &&
        other.vatExempt == vatExempt &&
        other.defaultPdfNotes == defaultPdfNotes &&
        other.paymentTerms == paymentTerms &&
        other.pdfTemplateStyle == pdfTemplateStyle;
  }

  @override
  int get hashCode {
    return businessName.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        logoPath.hashCode ^
        vatRate.hashCode ^
        vatExempt.hashCode ^
        defaultPdfNotes.hashCode ^
        paymentTerms.hashCode ^
        pdfTemplateStyle.hashCode;
  }
}
