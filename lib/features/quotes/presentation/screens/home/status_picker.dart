import 'package:flutter/material.dart';
import 'package:cutquote/core/quote_status.dart';

void showStatusPicker({
  required BuildContext context,
  required Map<String, dynamic> quote,
  required void Function(String dbValue) onUpdateStatus,
}) {
  final currentStatus = QuoteStatus.fromString(quote['status'] as String?);

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'בחר סטטוס',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              ...QuoteStatus.values.map((status) {
                final isSelected = status == currentStatus;
                return ListTile(
                  leading: Icon(
                    Icons.circle,
                    color: status.displayColor,
                    size: 20,
                  ),
                  title: Text(status.label),
                  trailing: isSelected
                      ? Icon(Icons.check,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    if (!isSelected) {
                      onUpdateStatus(status.dbValue);
                    }
                  },
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}
