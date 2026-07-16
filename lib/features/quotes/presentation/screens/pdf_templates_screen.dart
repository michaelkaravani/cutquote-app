import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:cutquote/core/pdf_service.dart';
import 'package:cutquote/core/pdf_template_notifier.dart';

class PdfTemplatesScreen extends StatelessWidget {
  const PdfTemplatesScreen({super.key});

  void _showPreview(BuildContext context, _TemplateInfo info) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Text('תצוגה מקדימה — ${info.title}'),
            ),
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
              loadingWidget: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _templates = [
    _TemplateInfo(
      key: 'premium_dark',
      title: 'יוקרתי כהה',
      subtitle: 'ראש כהה עם זהב, עיצוב יוקרתי ומלוטש',
      bandColors: [Color(0xFF1A1A2E), Color(0xFFC9A84C)],
      baseColor: Color(0xFFF8F7F4),
    ),
    _TemplateInfo(
      key: 'clean_corporate',
      title: 'תאגידי נקי',
      subtitle: 'טורקיז מקצועי, פריסה נקייה ואווירית',
      bandColors: [Color(0xFF0D7377), Color(0xFFE8F4F4)],
      baseColor: Color(0xFFFAFAFA),
    ),
    _TemplateInfo(
      key: 'natural_craft',
      title: 'קראפטי טבעי',
      subtitle: 'ירוק זית וקרם, מראה חם ומלאכותי',
      bandColors: [Color(0xFF5B7B4A), Color(0xFFFEFAF0)],
      baseColor: Color(0xFFFCF8F0),
    ),
    _TemplateInfo(
      key: 'minimal_stone',
      title: 'מינימל אבן',
      subtitle: 'גריי טרה-קוטה, מינימליסטי וארכיטקטוני',
      bandColors: [Color(0xFF4A4A4A), Color(0xFFC4A484)],
      baseColor: Color(0xFFFAFAF8),
    ),
    _TemplateInfo(
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
        appBar: AppBar(
          title: const Text('תבניות PDF'),
        ),
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
                return _TemplateCard(
                  info: t,
                  isSelected: isSelected,
                  onTap: () => pdfTemplateNotifier.setTemplate(t.key),
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

class _TemplateInfo {
  final String key;
  final String title;
  final String subtitle;
  final List<Color> bandColors;
  final Color baseColor;

  const _TemplateInfo({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.bandColors,
    required this.baseColor,
  });
}

class _TemplateCard extends StatelessWidget {
  final _TemplateInfo info;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPreview;

  const _TemplateCard({
    required this.info,
    required this.isSelected,
    required this.onTap,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected
        ? const Color(0xFFE88432)
        : theme.colorScheme.outlineVariant;

    return Card(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: info.baseColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: info.bandColors,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(7),
                            topRight: Radius.circular(7),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 8,
                      right: 8,
                      child: Row(
                        children: List.generate(3, (i) {
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: info.bandColors.length > 1
                                    ? info.bandColors.last
                                        .withValues(alpha: 0.4)
                                    : Colors.grey.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onPreview,
                icon: Icon(
                  Icons.visibility_outlined,
                  color: isSelected
                      ? const Color(0xFFE88432)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                tooltip: 'תצוגה מקדימה',
                visualDensity: VisualDensity.compact,
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFE88432),
                  size: 28,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
