import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> showLogoutConfirmation(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('התנתקות'),
        content: const Text('האם אתה בטוח שברצונך להתנתק?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ביטול', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('התנתק'),
          ),
        ],
      ),
    ),
  );

  if (confirmed != true) return;

  await FirebaseAuth.instance.signOut();
}
