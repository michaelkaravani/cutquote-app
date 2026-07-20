import 'package:flutter/material.dart';

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'אין עדיין הצעות מחיר שמורות. לחץ על הצעת מחיר חדשה כדי להתחיל.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardFilterEmptyState extends StatelessWidget {
  const DashboardFilterEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'לא נמצאו הצעות מחיר העונות לסינון זה',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
