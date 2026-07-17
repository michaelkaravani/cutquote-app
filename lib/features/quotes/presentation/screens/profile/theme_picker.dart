import 'package:flutter/material.dart';
import 'package:cutquote/core/app_theme.dart';
import 'package:cutquote/core/theme_notifier.dart';

class ThemePicker {
  static void show(BuildContext context) {
    final currentMode = themeNotifier.themeMode;
    final currentStyle = themeNotifier.themeStyle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ערכת נושא',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(ctx).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'סגנון צבע',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Theme.of(ctx)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ThemeStyle.values.map((style) {
                  final isSelected = style == currentStyle;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        themeNotifier.setThemeStyle(style);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(ctx)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1)
                              : Theme.of(ctx)
                                  .colorScheme
                                  .surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(ctx).colorScheme.primary
                                : Theme.of(ctx)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.15),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              style.icon,
                              color: isSelected
                                  ? Theme.of(ctx).colorScheme.primary
                                  : Theme.of(ctx)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              style.label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isSelected
                                    ? Theme.of(ctx).colorScheme.primary
                                    : Theme.of(ctx)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'מצב תצוגה',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Theme.of(ctx)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              _ThemeModeOption(
                icon: Icons.brightness_auto,
                label: 'ברירת מחדל של המערכת',
                mode: ThemeMode.system,
                isSelected: currentMode == ThemeMode.system,
              ),
              _ThemeModeOption(
                icon: Icons.light_mode,
                label: 'מצב בהיר',
                mode: ThemeMode.light,
                isSelected: currentMode == ThemeMode.light,
              ),
              _ThemeModeOption(
                icon: Icons.dark_mode,
                label: 'מצב כהה',
                mode: ThemeMode.dark,
                isSelected: currentMode == ThemeMode.dark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeMode mode;
  final bool isSelected;

  const _ThemeModeOption({
    required this.icon,
    required this.label,
    required this.mode,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        Navigator.pop(context);
        themeNotifier.setThemeMode(mode);
      },
    );
  }
}
