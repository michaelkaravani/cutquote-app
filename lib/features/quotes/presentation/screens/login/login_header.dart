import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Text(
              'CQ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'CutQuote Pro',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Center(
          child: Text(
            'מערכת ניהול וחישוב הצעות מחיר לייצור',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
