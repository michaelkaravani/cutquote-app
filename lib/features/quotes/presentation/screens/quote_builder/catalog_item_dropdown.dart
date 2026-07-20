import 'package:flutter/material.dart';

class CatalogItemDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> catalog;
  final void Function(Map<String, dynamic> item) onItemSelected;

  const CatalogItemDropdown({
    super.key,
    required this.catalog,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<Map<String, dynamic>>(
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerLow,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
          alignment: Alignment.centerRight,
          decoration: InputDecoration(
            labelText: 'בחירה מהירה מהמועדפים שלך',
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          items: catalog.asMap().entries.map((entry) {
            final item = entry.value;
            return DropdownMenuItem<Map<String, dynamic>>(
              value: item,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${item['name'] ?? ''} (₪${item['price'] ?? ''})",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            );
          }).toList(),
          onChanged: (selectedItem) {
            if (selectedItem != null) {
              onItemSelected(selectedItem);
            }
          },
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'או הקלדת פריט חדש',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
      ],
    );
  }
}
