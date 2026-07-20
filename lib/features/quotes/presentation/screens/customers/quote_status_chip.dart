import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cutquote/core/quote_status.dart';
import '../home/status_picker.dart';

class QuoteStatusChip extends StatefulWidget {
  final Map<String, dynamic> quote;
  final Function(String quoteId, String newStatus)? onUpdateQuoteStatus;
  final bool isSelectionMode;

  const QuoteStatusChip({
    super.key,
    required this.quote,
    this.onUpdateQuoteStatus,
    this.isSelectionMode = false,
  });

  static bool isQuoteOverdue(Map<String, dynamic> quote) {
    if (QuoteStatus.fromString(quote['status'] as String?) !=
        QuoteStatus.sent) {
      return false;
    }
    final createdAt = quote['createdAt'] as Timestamp?;
    if (createdAt == null) return false;
    return createdAt
        .toDate()
        .isBefore(DateTime.now().subtract(const Duration(days: 7)));
  }

  static int overdueDays(Map<String, dynamic> quote) {
    final createdAt = quote['createdAt'] as Timestamp?;
    if (createdAt == null) return 0;
    return DateTime.now().difference(createdAt.toDate()).inDays;
  }

  @override
  State<QuoteStatusChip> createState() => _QuoteStatusChipState();
}

class _QuoteStatusChipState extends State<QuoteStatusChip> {
  void _showStatusPicker() {
    showStatusPicker(
      context: context,
      quote: widget.quote,
      onUpdateStatus: (dbValue) {
        final docId = widget.quote['id'] as String?;
        if (docId != null) {
          widget.onUpdateQuoteStatus?.call(docId, dbValue);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final overdue = QuoteStatusChip.isQuoteOverdue(widget.quote);
    final status = QuoteStatus.fromString(widget.quote['status'] as String?);
    return GestureDetector(
      onTap: widget.isSelectionMode
          ? null
          : () => _showStatusPicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: overdue
              ? Colors.red.shade50
              : status.displayColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (overdue) ...[
              Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: Colors.red.shade800,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              overdue
                  ? 'ממתין ${QuoteStatusChip.overdueDays(widget.quote)} ימים ⏳'
                  : status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: overdue
                    ? Colors.red.shade800
                    : status.displayColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
