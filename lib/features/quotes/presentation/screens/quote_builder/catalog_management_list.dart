import 'package:flutter/material.dart';

class CatalogManagementList extends StatelessWidget {
  final List<Map<String, dynamic>> catalog;
  final void Function(int index, Map<String, dynamic> item) onEditItem;
  final void Function(int index) onDeleteItem;

  const CatalogManagementList({
    super.key,
    required this.catalog,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    if (catalog.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          'ניהול פריטים שמורים (מועדפים)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: catalog.length,
          itemBuilder: (context, index) {
            final catItem = catalog[index];
            return Card(
              key: ValueKey(catItem['name'] ?? index),
              surfaceTintColor: Colors.transparent,
              margin: const EdgeInsets.symmetric(vertical: 3),
              child: ListTile(
                dense: true,
                title: Text(
                  catItem['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("₪${(catItem['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => onEditItem(index, catItem),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                      onPressed: () => onDeleteItem(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
