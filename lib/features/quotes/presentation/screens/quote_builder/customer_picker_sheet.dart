import 'package:flutter/material.dart';

class CustomerPickerSheet extends StatelessWidget {
  final List<Map<String, String>> customers;
  final void Function(Map<String, String> customer) onCustomerSelected;

  const CustomerPickerSheet({
    super.key,
    required this.customers,
    required this.onCustomerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'בחר לקוח מהרשימה',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(customer['name']!),
                  onTap: () {
                    onCustomerSelected(customer);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
