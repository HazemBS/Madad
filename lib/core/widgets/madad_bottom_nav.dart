import 'package:flutter/material.dart';

import '../theme/madad_colors.dart';

class MadadBottomNav extends StatelessWidget {
  const MadadBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
    this.items = shopItems,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<(IconData, IconData, String)> items;

  static const shopItems = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home, 'الرئيسية'),
    (Icons.grid_view_outlined, Icons.grid_view, 'التصنيفات'),
    (Icons.receipt_long_outlined, Icons.receipt_long, 'طلباتي'),
    (Icons.favorite_border, Icons.favorite, 'المفضلة'),
    (Icons.person_outline, Icons.person, 'حسابي'),
  ];

  static const supplierItems = <(IconData, IconData, String)>[
    (Icons.storefront_outlined, Icons.storefront, 'الرئيسية'),
    (Icons.inventory_2_outlined, Icons.inventory_2, 'منتجاتي'),
    (Icons.receipt_long_outlined, Icons.receipt_long, 'الطلبات'),
    (Icons.person_outline, Icons.person, 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MadadColors.white,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: MadadColors.line)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: InkWell(
                      key: ValueKey('tab-$i'),
                      onTap: () => onChanged(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            index == i ? items[i].$2 : items[i].$1,
                            color: index == i
                                ? MadadColors.teal
                                : MadadColors.muted,
                            size: 22,
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                items[i].$3,
                                maxLines: 1,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: index == i
                                          ? MadadColors.teal
                                          : MadadColors.muted,
                                      fontWeight: index == i
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
