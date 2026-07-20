import 'package:flutter/material.dart';

class AddItemButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddItemButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Theme.of(context).colorScheme.secondary, size: 20),
            const SizedBox(width: 6),
            Text(
              'הוסף שירות / פריט',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
