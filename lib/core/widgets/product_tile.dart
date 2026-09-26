import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../theme/madad_colors.dart';
import 'price_label.dart';
import 'product_photo.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    required this.supplierName,
    required this.icon,
    required this.onTap,
    required this.onAdd,
    this.addIcon = Icons.add_shopping_cart_outlined,
    this.addTooltip = 'إضافة للسلة',
  });

  final Product product;
  final String supplierName;
  final CategoryIcon icon;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final IconData addIcon;
  final String addTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Material(
      color: MadadColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: ValueKey('product-${product.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MadadColors.line),
          ),
          child: Row(
            children: [
              ProductPhoto(productId: product.id, size: 72, fallbackIcon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      supplierName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    PriceLabel(product.wholesalePrice, style: theme.titleSmall),
                    Text(
                      'الوحدة: ${product.unit.label} · الحد الأدنى ${product.minOrder}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onAdd,
                tooltip: addTooltip,
                icon: Icon(addIcon),
                color: MadadColors.teal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
