import 'package:flutter/material.dart';

import '../theme/madad_colors.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MadadColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MadadColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(
            Icons.remove,
            value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: compact ? 28 : 40,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: compact
                  ? Theme.of(context).textTheme.titleSmall
                  : Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _button(Icons.add, value < max ? () => onChanged(value + 1) : null),
        ],
      ),
    );
  }

  Widget _button(IconData icon, VoidCallback? onTap) {
    final side = compact ? 28.0 : 40.0;
    return SizedBox(
      width: side,
      height: side,
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(),
        iconSize: compact ? 16 : 20,
        icon: Icon(
          icon,
          color: onTap == null ? MadadColors.muted : MadadColors.navy,
        ),
      ),
    );
  }
}
