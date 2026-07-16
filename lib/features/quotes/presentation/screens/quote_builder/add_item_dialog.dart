import 'package:flutter/material.dart';

class AddItemDialog extends StatefulWidget {
  final List<Map<String, dynamic>> catalog;
  final Function(Map<String, dynamic>) onAddToCatalog;
  final Function(Map<String, dynamic>) onItemAdded;

  const AddItemDialog({
    super.key,
    required this.catalog,
    required this.onAddToCatalog,
    required this.onItemAdded,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  bool saveToCatalog = false;

  @override
  void initState() {
    super.initState();
    quantityController.text = "1";
    quantityController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: quantityController.text.length,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'הוספת פריט להצעה',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.catalog.isNotEmpty) ...[
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                  items: widget.catalog.asMap().entries.map((entry) {
                    final item = entry.value;
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: item,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "${item['name']} (₪${item['price']})",
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
                      setState(() {
                        nameController.text = selectedItem['name'];
                        priceController.text = selectedItem['price']
                            .toString();
                        quantityController.text = "1";
                        quantityController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: quantityController.text.length,
                        );
                      });
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
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ],
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'שם הפריט / השירות',
                  labelStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: priceController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                      decoration: InputDecoration(
                        labelText: 'מחיר ליחידה',
                        labelStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: quantityController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      keyboardType: TextInputType.number,
                      onTap: () {
                        quantityController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: quantityController.text.length,
                        );
                      },
                      decoration: InputDecoration(
                        labelText: 'כמות',
                        labelStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Checkbox(
                    value: saveToCatalog,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (val) {
                      setState(() {
                        saveToCatalog = val ?? false;
                      });
                    },
                  ),
                  Text(
                    'שמור מוצר זה למועדפים קבועים',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'ביטול',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;

              final price = double.tryParse(priceController.text.trim());
              final quantity =
                  int.tryParse(quantityController.text.trim());

              if (price == null || price < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('מחיר לא תקין'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              if (quantity == null || quantity < 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('כמות לא תקינה'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              if (saveToCatalog) {
                widget.onAddToCatalog({
                  'name': nameController.text,
                  'price': price,
                });
              }

              widget.onItemAdded({
                'name': nameController.text,
                'price': price,
                'quantity': quantity,
              });

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('שמירה'),
          ),
        ],
      ),
    );
  }
}
