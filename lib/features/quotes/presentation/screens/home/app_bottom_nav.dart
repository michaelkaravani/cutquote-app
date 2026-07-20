import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'ראשי',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'הצעת מחיר',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'לקוחות'),
      ],
    );
  }
}
