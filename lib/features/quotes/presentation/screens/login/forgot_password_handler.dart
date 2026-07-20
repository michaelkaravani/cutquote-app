import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_error_handler.dart';

Future<void> handleForgotPassword({
  required BuildContext context,
  required String email,
  required VoidCallback onStart,
  required VoidCallback onDone,
}) async {
  if (email.isEmpty || !email.contains('@')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'אנא הזן כתובת אימייל תקינה בשדה ההתחברות לשחזור הסיסמה',
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  onStart();

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'אימות נשלח',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'קישור מאובטח לאיפוס הסיסמה נשלח לכתובת:\n$email',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'הבנתי',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(friendlyAuthError(e)),
        backgroundColor: Colors.redAccent,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('שגיאה בשליחת השחזור: $e'),
        backgroundColor: Colors.redAccent,
      ),
    );
  } finally {
    if (context.mounted) {
      onDone();
    }
  }
}
