import 'package:flutter/material.dart';

class CustomerSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const CustomerSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends State<CustomerSearchBar> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _query = widget.controller.text;
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: 'חיפוש לקוח...',
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        suffixIcon: _query.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged('');
                  FocusScope.of(context).unfocus();
                },
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
        ),
      ),
    );
  }
}
