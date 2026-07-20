import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onNavigateToNewQuote;
  final VoidCallback onNavigateToCustomers;

  const QuickActionsGrid({
    super.key,
    required this.onNavigateToNewQuote,
    required this.onNavigateToCustomers,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _ActionButton(
          title: 'הצעת מחיר חדשה',
          icon: Icons.calculate_rounded,
          color: Theme.of(context).colorScheme.secondary,
          onTap: onNavigateToNewQuote,
        ),
        _ActionButton(
          title: 'ניהול לקוחות',
          icon: Icons.people_alt_rounded,
          color: Theme.of(context).colorScheme.primary,
          onTap: onNavigateToCustomers,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
