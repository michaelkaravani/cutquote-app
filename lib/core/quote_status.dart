import 'package:flutter/material.dart';

enum QuoteStatus {
  draft,
  sent,
  approved,
  inProduction,
  paid;

  String get label {
    switch (this) {
      case QuoteStatus.draft:
        return 'טיוטה';
      case QuoteStatus.sent:
        return 'נשלח';
      case QuoteStatus.approved:
        return 'אושר';
      case QuoteStatus.inProduction:
        return 'בייצור';
      case QuoteStatus.paid:
        return 'שולם';
    }
  }

  Color get displayColor {
    switch (this) {
      case QuoteStatus.draft:
        return Colors.grey;
      case QuoteStatus.sent:
        return Colors.blue;
      case QuoteStatus.approved:
        return Colors.orange;
      case QuoteStatus.inProduction:
        return Colors.purple;
      case QuoteStatus.paid:
        return Colors.green;
    }
  }

  static QuoteStatus fromString(String? value) =>
      QuoteStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => QuoteStatus.draft,
      );

  String get dbValue => name;
}
