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
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'ייצוא דוח הכנסות חודשי',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF513222),
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
                  child: const Text(
                    'ביטול',
                    style: TextStyle(color: Colors.grey),
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
                    backgroundColor: const Color(0xFF513222),
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

Widget _buildQuickChip({
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
            ? const Color(0xFF513222)
            : const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected ? const Color(0xFF513222) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF513222),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white70 : Colors.grey,
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
