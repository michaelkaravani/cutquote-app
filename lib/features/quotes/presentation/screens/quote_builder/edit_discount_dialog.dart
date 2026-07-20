import 'package:flutter/material.dart';

Future<void> showEditDiscountDialog({
  required BuildContext context,
  required double currentDiscount,
  required double itemsTotal,
  required ValueChanged<double> onDiscountSet,
}) async {
  final controller = TextEditingController(text: currentDiscount.toStringAsFixed(0));

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
          'הנחה',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'סכום ההנחה בשקלים',
            prefixIcon: const Icon(Icons.money_off, size: 20),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text('ביטול', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value >= 0 && value <= itemsTotal) {
                onDiscountSet(value);
                controller.dispose();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('אישור'),
          ),
        ],
      ),
    ),
  );
}
