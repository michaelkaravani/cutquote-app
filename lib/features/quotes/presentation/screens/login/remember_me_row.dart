import 'package:flutter/material.dart';

class RememberMeRow extends StatelessWidget {
  final bool value;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  const RememberMeRow({
    super.key,
    required this.value,
    this.isLoading = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: isLoading ? null : (v) => onChanged(v ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: isLoading ? null : () => onChanged(!value),
          child: Text(
            'זכור אותי',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
