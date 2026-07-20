import 'package:flutter/material.dart';

Future<void> showEditCatalogItemDialog({
  required BuildContext context,
  required Map<String, dynamic> item,
  required void Function(Map<String, dynamic>) onSave,
}) async {
  final nameController = TextEditingController(text: item['name']?.toString() ?? '');
  final priceController = TextEditingController(
    text: ((item['price'] as num?)?.toDouble() ?? 0).toStringAsFixed(2),
  );

  await showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'עריכת פריט',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'שם הפריט / השירות',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'מחיר ליחידה',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              nameController.dispose();
              priceController.dispose();
              Navigator.pop(ctx);
            },
            child: Text(
              'ביטול',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim());
              if (name.isEmpty || price == null || price < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('מחיר לא תקין'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              onSave({'name': name, 'price': price});
              nameController.dispose();
              priceController.dispose();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('שמירה'),
          ),
        ],
      ),
    ),
  );
}
