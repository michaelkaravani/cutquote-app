import 'package:flutter/material.dart';

class AddCustomerDialog extends StatefulWidget {
  final Map<String, String>? existingCustomer;
  final Future<void> Function(Map<String, String>) onCustomerAdded;

  const AddCustomerDialog({super.key, this.existingCustomer, required this.onCustomerAdded});

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _nameController = TextEditingController();
  final _hpController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingCustomer != null) {
      final c = widget.existingCustomer!;
      _nameController.text = c['name'] ?? '';
      _hpController.text = c['hp'] ?? '';
      _addressController.text = c['address'] ?? '';
      _phoneController.text = c['phone'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hpController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
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
          widget.existingCustomer != null ? 'עריכת לקוח' : 'הוספת לקוח חדש',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'שם הלקוח / חברה',
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
              TextField(
                controller: _hpController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'ח.פ / ת.ז',
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
              TextField(
                controller: _addressController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'כתובת',
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
              TextField(
                controller: _phoneController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'טלפון',
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
            onPressed: _isAdding
                ? null
                : () async {
                    if (_nameController.text.trim().isEmpty) return;
                    final phone = _phoneController.text.trim();
                    if (phone.isNotEmpty && !RegExp(r'^[\d+\- ]+$').hasMatch(phone)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('מספר טלפון לא תקין')),
                      );
                      return;
                    }
                    final navigator = Navigator.of(context);

                    setState(() => _isAdding = true);

                    await widget.onCustomerAdded({
                      'name': _nameController.text.trim(),
                      'hp': _hpController.text.trim(),
                      'address': _addressController.text.trim(),
                      'phone': _phoneController.text.trim(),
                    });

                    if (!mounted) return;
                    navigator.pop();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            child: _isAdding
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('שמירה'),
          ),
        ],
      ),
    );
  }
}
