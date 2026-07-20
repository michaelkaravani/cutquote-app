import 'package:flutter/material.dart';

Future<void> showDeleteCustomerDialog({
  required BuildContext context,
  required String customerName,
  required VoidCallback onConfirm,
}) async {
  await showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'מחיקת לקוח',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'האם אתה בטוח שברצונך למחוק את "$customerName"? הפעולה אינה הפיכה.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ביטול',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('מחיקה'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showDeleteQuoteDialog({
  required BuildContext context,
  required String quoteDate,
  required VoidCallback onConfirm,
}) async {
  await showDialog(
    context: context,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'מחיקת הצעה',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'האם אתה בטוח שברצונך למחוק הצעה זו מתאריך $quoteDate?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ביטול',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('מחק'),
          ),
        ],
      ),
    ),
  );
}
