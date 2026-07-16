import 'package:flutter/material.dart';

class MonthPickerResult {
  final int year;
  final int month;

  MonthPickerResult({required this.year, required this.month});
}

Future<MonthPickerResult?> showMonthPickerDialog(BuildContext context) async {
  final now = DateTime.now();

  int selectedYear = now.year;
  int selectedMonth = now.month;
  bool isCustom = false;

  return showDialog<MonthPickerResult>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'ייצוא דוח הכנסות חודשי',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildQuickChip(
                        context,
                        label: 'החודש',
                        subtitle: '${_getMonthName(now.month)} ${now.year}',
                        isSelected: !isCustom &&
                            selectedYear == now.year &&
                            selectedMonth == now.month,
                        onTap: () {
                          setDialogState(() {
                            isCustom = false;
                            selectedYear = now.year;
                            selectedMonth = now.month;
                          });
                        },
                      ),
                      _buildQuickChip(
                        context,
                        label: 'חודש שעבר',
                        subtitle: _getPreviousMonthLabel(now),
                        isSelected: !isCustom &&
                            _isPreviousMonth(
                                selectedYear, selectedMonth, now),
                        onTap: () {
                          final prev = DateTime(now.year, now.month - 1, 1);
                          setDialogState(() {
                            isCustom = false;
                            selectedYear = prev.year;
                            selectedMonth = prev.month;
                          });
                        },
                      ),
                      _buildQuickChip(
                        context,
                        label: 'בחירה ידנית',
                        subtitle: isCustom
                            ? '${_getMonthName(selectedMonth)} $selectedYear'
                            : '',
                        isSelected: isCustom,
                        onTap: () {
                          setDialogState(() {
                            isCustom = true;
                          });
                        },
                      ),
                    ],
                  ),
                  if (isCustom) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'שנה',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedYear,
                                isExpanded: true,
                                isDense: true,
                                items: List.generate(
                                  now.year - 2019,
                                  (i) => now.year - i,
                                ).map((y) {
                                  return DropdownMenuItem(
                                    value: y,
                                    child: Text('$y'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      selectedYear = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'חודש',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedMonth,
                                isExpanded: true,
                                isDense: true,
                                items: List.generate(12, (i) => i + 1).map((m) {
                                  return DropdownMenuItem(
                                    value: m,
                                    child: Text(_getMonthName(m)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      selectedMonth = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'ביטול',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      MonthPickerResult(
                          year: selectedYear, month: selectedMonth),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ייצא CSV'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildQuickChip(
  BuildContext context, {
  required String label,
  required String subtitle,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

String _getMonthName(int month) {
  const months = [
    '',
    'ינואר',
    'פברואר',
    'מרץ',
    'אפריל',
    'מאי',
    'יוני',
    'יולי',
    'אוגוסט',
    'ספטמבר',
    'אוקטובר',
    'נובמבר',
    'דצמבר',
  ];
  return month >= 1 && month <= 12 ? months[month] : '$month';
}

String _getPreviousMonthLabel(DateTime now) {
  final prev = DateTime(now.year, now.month - 1, 1);
  return '${_getMonthName(prev.month)} ${prev.year}';
}

bool _isPreviousMonth(int year, int month, DateTime now) {
  final prev = DateTime(now.year, now.month - 1, 1);
  return year == prev.year && month == prev.month;
}
