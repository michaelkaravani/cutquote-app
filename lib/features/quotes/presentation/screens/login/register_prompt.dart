import 'package:flutter/material.dart';

class RegisterPrompt extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRegister;

  const RegisterPrompt({
    super.key,
    this.isLoading = false,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'אין לך חשבון עדיין?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        TextButton(
          onPressed: isLoading ? null : onRegister,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
          child: Text(
            'הרשמה כאן',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
