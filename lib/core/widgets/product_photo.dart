import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import '../theme/madad_colors.dart';
import 'category_glyph.dart';

/// صور مؤقتة محلية لكل منتج. تُستبدل لاحقًا بصور المورد.
class ProductPhoto extends StatelessWidget {
  const ProductPhoto({
    super.key,
    required this.productId,
    this.size = 64,
    this.height,
    this.expandWidth = false,
    this.radius = 14,
    this.fit = BoxFit.cover,
    this.fallbackIcon = CategoryIcon.food,
  });

  final String productId;
  final double size;
  final double? height;
  final bool expandWidth;
  final double radius;
  final BoxFit fit;
  final CategoryIcon fallbackIcon;

  static const _assets = <String, String>{
    'p1': 'assets/products/p1.png',
    'p2': 'assets/products/p2.png',
    'p3': 'assets/products/p3.png',
    'p4': 'assets/products/p4.png',
    'p5': 'assets/products/p5.png',
    'p6': 'assets/products/p6.png',
    'p7': 'assets/products/p7.png',
    'p8': 'assets/products/p8.png',
    'p9': 'assets/products/p9.png',
    'p10': 'assets/products/p10.png',
    'p11': 'assets/products/p11.png',
    'p12': 'assets/products/p12.png',
  };

  @override
  Widget build(BuildContext context) {
    final path = _assets[productId];
    final boxHeight = height ?? size;
    final fallback = ColoredBox(
      color: MadadColors.sand,
      child: Center(
        child: CategoryGlyph(icon: fallbackIcon, size: boxHeight * 0.55),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: expandWidth ? double.infinity : size,
        height: boxHeight,
        child: path == null
            ? fallback
            : ColoredBox(
                color: MadadColors.sand,
                child: Image.asset(
                  path,
                  fit: fit,
                  alignment: Alignment.center,
                  errorBuilder: (_, _, _) => fallback,
                ),
              ),
      ),
    );
  }
}
