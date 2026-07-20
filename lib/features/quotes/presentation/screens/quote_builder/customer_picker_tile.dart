import 'package:flutter/material.dart';

class CustomerPickerTile extends StatelessWidget {
  final List<Map<String, String>> customers;
  final Map<String, String>? selectedCustomer;
  final VoidCallback onTap;

  const CustomerPickerTile({
    super.key,
    required this.customers,
    required this.selectedCustomer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'לקוח',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: customers.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'יש להוסיף תחילה לקוחות במסך "לקוחות".',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCustomer?['name'] ?? '-- בחר לקוח --',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        if (selectedCustomer != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'ח.פ: ${selectedCustomer!['hp'] ?? '—'} | כתובת: ${selectedCustomer!['address'] ?? '—'}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
