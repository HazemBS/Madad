import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import '../theme/madad_colors.dart';

IconData categoryIcon(CategoryIcon icon) {
  return switch (icon) {
    CategoryIcon.food => Icons.restaurant_outlined,
    CategoryIcon.store => Icons.storefront_outlined,
    CategoryIcon.care => Icons.clean_hands_outlined,
    CategoryIcon.home => Icons.chair_outlined,
    CategoryIcon.electronics => Icons.devices_outlined,
    CategoryIcon.stationery => Icons.edit_outlined,
  };
}

class CategoryGlyph extends StatelessWidget {
  const CategoryGlyph({
    super.key,
    required this.icon,
    this.size = 56,
    this.iconScale = 0.5,
  });

  final CategoryIcon icon;
  final double size;
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: MadadColors.sand,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        categoryIcon(icon),
        color: MadadColors.navy,
        size: size * iconScale,
      ),
    );
  }
}
