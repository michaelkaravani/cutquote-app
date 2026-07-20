import 'package:flutter/material.dart';

class ItemList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(int index) onDeleteItem;

  const ItemList({
    super.key,
    required this.items,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final double itemTotal = ((item['price'] as num?)?.toDouble() ?? 0) *
            ((item['quantity'] as num?)?.toDouble() ?? 0);
        return Card(
          key: ValueKey(item['name'] ?? index),
          surfaceTintColor: Colors.transparent,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              item['name'] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              '${(item['quantity'] as num?)?.toInt() ?? 0} יח\' X ₪${((item['price'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₪${itemTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => onDeleteItem(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
