import 'package:flutter/material.dart';

import '../constants/madad_brand.dart';
import '../theme/madad_colors.dart';

/// شعار نصي مؤقت. لاستبداله بصورة: اجعل [useImage] true وضع الملف في [assetPath].
class MadadLogo extends StatelessWidget {
  const MadadLogo({
    super.key,
    this.light = false,
    this.compact = false,
    this.showEnglish = true,
  });

  static const useImage = false;
  static const assetPath = 'assets/brand/logo.png';

  final bool light;
  final bool compact;
  final bool showEnglish;

  @override
  Widget build(BuildContext context) {
    if (useImage) {
      return Image.asset(
        assetPath,
        height: compact ? 42 : 88,
        fit: BoxFit.contain,
      );
    }

    final titleColor = light ? MadadColors.white : MadadColors.navy;
    final theme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          MadadBrand.arabicName,
          style: (compact ? theme.headlineMedium : theme.displaySmall)
              ?.copyWith(color: titleColor),
        ),
        if (showEnglish) ...[
          const SizedBox(height: 2),
          Text(
            MadadBrand.englishName,
            style: theme.labelLarge?.copyWith(
              color: MadadColors.teal,
              letterSpacing: 3,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ],
      ],
    );
  }
}
