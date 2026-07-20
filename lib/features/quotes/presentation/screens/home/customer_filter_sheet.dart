import 'package:flutter/material.dart';

Future<Map<String, String>?> showCustomerFilterSheet({
  required BuildContext context,
  required List<Map<String, dynamic>> quotes,
  required String? selectedCustomerFilter,
}) async {
  final uniqueCustomers = <Map<String, String>>[];
  final seen = <String>{};
  for (final q in quotes) {
    final c = q['customer'] as Map?;
    if (c == null) continue;
    final name = c['name']?.toString() ?? '';
    if (name.trim().isEmpty) continue;
    final phone = c['phone']?.toString() ?? '';
    final key = '$name|$phone';
    if (seen.add(key)) {
      uniqueCustomers.add({'name': name, 'phone': phone, 'key': key});
    }
  }
  uniqueCustomers.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

  return showModalBottomSheet<Map<String, String>>(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'בחר לקוח לסינון',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: uniqueCustomers.length,
                itemBuilder: (context, i) {
                  final entry = uniqueCustomers[i];
                  final displayName = (entry['phone'] ?? '').isNotEmpty
                      ? '${entry['name'] ?? ''} (${entry['phone'] ?? ''})'
                      : entry['name'] ?? '';
                  return ListTile(
                    key: ValueKey(entry['key'] ?? i),
                    title: Text(displayName),
                    trailing: selectedCustomerFilter == entry['key']
                        ? Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () => Navigator.pop(ctx, entry),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
