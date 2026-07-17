import 'package:flutter/material.dart';
import 'package:cutquote/core/pdf_template_notifier.dart';
import 'package:cutquote/features/quotes/presentation/screens/pdf_templates_screen.dart';

class PdfTemplateChooser extends StatelessWidget {
  const PdfTemplateChooser({super.key});

  static String _label(String template) {
    switch (template) {
      case 'premium_dark':
        return 'יוקרתי כהה';
      case 'clean_corporate':
        return 'תאגידי נקי';
      case 'natural_craft':
        return 'קראפטי טבעי';
      case 'minimal_stone':
        return 'מינימל אבן';
      case 'modern_bordeaux':
        return 'מודרני בורדו';
      default:
        return 'יוקרתי כהה';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.transparent,
      child: ListTile(
        leading: Icon(
          Icons.description_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text(
          'תבניות PDF',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: ListenableBuilder(
          listenable: pdfTemplateNotifier,
          builder: (context, _) => Text(
            _label(pdfTemplateNotifier.currentTemplate),
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_back_ios_new,
          size: 16,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.6),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PdfTemplatesScreen(),
            ),
          );
        },
      ),
    );
  }
}
