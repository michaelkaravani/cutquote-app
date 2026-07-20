import 'package:flutter/material.dart';

class PdfTemplateInfo {
  final String key;
  final String title;
  final String subtitle;
  final List<Color> bandColors;
  final Color baseColor;

  const PdfTemplateInfo({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.bandColors,
    required this.baseColor,
  });
}

class TemplateCard extends StatelessWidget {
  final PdfTemplateInfo info;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPreview;

  const TemplateCard({
    super.key,
    required this.info,
    required this.isSelected,
    required this.onTap,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected
        ? theme.colorScheme.secondary
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
                          gradient: LinearGradient(colors: info.bandColors),
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
                              margin: const EdgeInsets.symmetric(
                                horizontal: 2,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: info.bandColors.length > 1
                                    ? info.bandColors.last.withValues(alpha: 0.4)
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
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                      ? theme.colorScheme.secondary
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
