import 'package:cutquote/core/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pdf template survives map serialization and copyWith', () {
    final profile = Profile(
      businessName: 'CutQuote',
      phone: '0500000000',
      email: 'test@example.com',
      pdfTemplateStyle: 'minimal_stone',
    );

    final restored = Profile.fromMap(profile.toMap());
    final copied = restored.copyWith(businessName: 'Updated');

    expect(restored.pdfTemplateStyle, 'minimal_stone');
    expect(restored.toFirestore()['pdfTemplateStyle'], 'minimal_stone');
    expect(copied.pdfTemplateStyle, 'minimal_stone');
  });

  test('old profiles default to the first supported template', () {
    final profile = Profile.fromMap({
      'businessName': 'Legacy',
      'phone': '',
      'email': '',
    });

    expect(profile.pdfTemplateStyle, 'premium_dark');
  });

  test('pdf template participates in equality', () {
    final first = Profile(
      businessName: 'CutQuote',
      phone: '',
      email: '',
      pdfTemplateStyle: 'premium_dark',
    );
    final second = first.copyWith(pdfTemplateStyle: 'clean_corporate');

    expect(first, isNot(second));
  });
}
