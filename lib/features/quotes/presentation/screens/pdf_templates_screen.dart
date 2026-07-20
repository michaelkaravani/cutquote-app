import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:cutquote/core/navigation.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/pdf_template_notifier.dart';
import 'pdf_templates/template_card.dart';

class PdfTemplatesScreen extends StatelessWidget {
  const PdfTemplatesScreen({super.key});

  void _showPreview(BuildContext context, PdfTemplateInfo info) {
    context.push(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: Text('תצוגה מקדימה — ${info.title}')),
          body: PdfPreview(
            build: (format) => PdfService.generatePreviewPdfBytes(
              templateStyle: info.key,
              customer: const <String, String>{
                'name': 'ישראל ישראלי',
                'hp': '123456789',
                'address': 'רחוב הדוגמה 1, תל אביב',
                'phone': '050-1234567',
              },
              items: const [
                {'name': 'מוצר לדוגמה א', 'price': 250.0, 'quantity': 10},
                {'name': 'מוצר לדוגמה ב', 'price': 85.0, 'quantity': 5},
              ],
              total: 2925.0,
              notes: 'הערות לדוגמה',
              profile: <String, dynamic>{
                'businessName': 'מיכאל פרסיז\'ן ארט',
                'phone': '050-4426130',
                'email': 'michaelprecisionart@gmail.com',
              },
            ),
            loadingWidget: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  static const _templates = [
    PdfTemplateInfo(
      key: 'premium_dark',
      title: 'יוקרתי כהה',
      subtitle: 'ראש כהה עם זהב, עיצוב יוקרתי ומלוטש',
      bandColors: [Color(0xFF1A1A2E), Color(0xFFC9A84C)],
      baseColor: Color(0xFFF8F7F4),
    ),
    PdfTemplateInfo(
      key: 'clean_corporate',
      title: 'תאגידי נקי',
      subtitle: 'טורקיז מקצועי, פריסה נקייה ואווירית',
      bandColors: [Color(0xFF0D7377), Color(0xFFE8F4F4)],
      baseColor: Color(0xFFFAFAFA),
    ),
    PdfTemplateInfo(
      key: 'natural_craft',
      title: 'קראפטי טבעי',
      subtitle: 'ירוק זית וקרם, מראה חם ומלאכותי',
      bandColors: [Color(0xFF5B7B4A), Color(0xFFFEFAF0)],
      baseColor: Color(0xFFFCF8F0),
    ),
    PdfTemplateInfo(
      key: 'minimal_stone',
      title: 'אקווה גיאומטרי',
      subtitle:
          'עיצוב גיאומטרי יוקרתי בגווני טורקיז וכחול עמוק, מתאים להצעות מחיר מודרניות.',
      bandColors: [Color(0xFF0A2540), Color(0xFF00D4B2)],
      baseColor: Color(0xFFF4FBFB),
    ),
    PdfTemplateInfo(
      key: 'modern_bordeaux',
      title: 'מודרני בורדו',
      subtitle: 'בורדו עמוק וורדרד, בוטיק אלגנטי',
      bandColors: [Color(0xFF722F37), Color(0xFFF5E1E4)],
      baseColor: Color(0xFFFDFAFA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('תבניות PDF')),
        body: ListenableBuilder(
          listenable: pdfTemplateNotifier,
          builder: (context, _) {
            final current = pdfTemplateNotifier.currentTemplate;
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _templates.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final t = _templates[index];
                final isSelected = t.key == current;
                return TemplateCard(
                  info: t,
                  isSelected: isSelected,
                  onTap: () async {
                    try {
                      await pdfTemplateNotifier.setTemplate(t.key);
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('שמירת התבנית נכשלה: $error'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  onPreview: () => _showPreview(context, t),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
