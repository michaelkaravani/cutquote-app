import 'dart:io';

import 'package:flutter/material.dart';

class LogoPicker extends StatelessWidget {
  final String? logoPath;
  final bool isEditing;
  final VoidCallback onPickLogo;
  final VoidCallback onClearLogo;

  const LogoPicker({
    super.key,
    this.logoPath,
    required this.isEditing,
    required this.onPickLogo,
    required this.onClearLogo,
  });

  Widget _defaultLogoPreview(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.business_rounded,
        size: 32,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: logoPath != null &&
                  File(logoPath!).existsSync()
              ? Image.file(
                  File(logoPath!),
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _defaultLogoPreview(context),
                )
              : _defaultLogoPreview(context),
        ),
        if (isEditing) ...[
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: onPickLogo,
            icon: const Icon(Icons.image, size: 18),
            label: const Text('בחר לוגו'),
          ),
          if (logoPath != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onClearLogo,
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.redAccent,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
