import 'package:flutter/material.dart';

import '../theme/madad_colors.dart';
import '../utils/formatters.dart';

class PriceLabel extends StatelessWidget {
  const PriceLabel(
    this.amount, {
    super.key,
    this.style,
    this.color = MadadColors.teal,
  });

  final double amount;
  final TextStyle? style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final base = style ?? Theme.of(context).textTheme.titleMedium;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          formatPrice(amount),
          style: base?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
