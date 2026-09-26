import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/widgets/madad_builder.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/utils/madad_messenger.dart';
import '../../core/widgets/category_glyph.dart';
import '../../core/widgets/price_label.dart';
import '../../core/widgets/product_tile.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/supplier_card.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openProducts({String? categoryId, String? search}) {
    Navigator.of(context).pushNamed(
      AppRoutes.products,
      arguments: ProductsQuery(categoryId: categoryId, search: search),
    );
  }

  void _openProduct(Product product) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.productDetails, arguments: product.id);
  }

  void _add(Product product) {
    final notice = MadadScope.of(context).cart.add(product, product.minOrder);
    showMadadMessage(context, notice ?? 'أُضيف المنتج إلى السلة');
  }

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: MadadBuilder(
          cubits: [scope.session],
          builder: (context, _) {
            final profile = scope.session.profile;
            final popular = scope.catalog.popular();
            return ListView(
              key: const ValueKey('home-scroll'),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (scope.catalog.loadError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      scope.catalog.loadError!,
                      style: theme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحبًا ${profile?.ownerName ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.headlineSmall,
                          ),
                          Text(
                            '${profile?.businessName ?? ''} · ${profile?.city ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodyMedium?.copyWith(
                              color: MadadColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _CartButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.cart),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن منتج أو مورد',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      tooltip: 'بحث',
                      onPressed: () =>
                          _openProducts(search: _search.text.trim()),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  onSubmitted: (value) => _openProducts(search: value.trim()),
                ),
                const SizedBox(height: 16),
                _OfferBanner(onTap: () => _openProducts()),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'التصنيفات',
                  action: 'عرض الكل',
                  onAction: () => scope.shell.goTo(1),
                ),
                SizedBox(
                  height: 108,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: scope.catalog.categories().length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final category = scope.catalog.categories()[index];
                      return _CategoryChip(
                        category: category,
                        onTap: () => _openProducts(categoryId: category.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SectionHeader(
                  title: 'الموردون المميزون',
                  action: 'عرض الكل',
                  onAction: () {
                    Navigator.of(context).pushNamed(AppRoutes.suppliers);
                  },
                ),
                SizedBox(
                  height: 168,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: scope.catalog.suppliers().length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final supplier = scope.catalog.suppliers()[index];
                      final labels = supplier.categoryIds
                          .map(scope.catalog.categoryName)
                          .where((name) => name.isNotEmpty)
                          .join('، ');
                      return SupplierCard(
                        width: 230,
                        supplier: supplier,
                        categoryLabel: labels,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.supplier,
                            arguments: supplier.id,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SectionHeader(
                  title: 'الأكثر طلبًا',
                  action: 'عرض الكل',
                  onAction: () => _openProducts(),
                ),
                for (final product in popular) ...[
                  ProductTile(
                    product: product,
                    supplierName: scope.catalog.supplierName(
                      product.supplierId,
                    ),
                    icon:
                        scope.catalog.categoryById(product.categoryId)?.icon ??
                        CategoryIcon.food,
                    onTap: () => _openProduct(product),
                    onAdd: () => _add(product),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cart = MadadScope.of(context).cart;
    return MadadBuilder(
      cubits: [cart],
      builder: (context, _) {
        return Badge(
          isLabelVisible: cart.count > 0,
          label: Text('${cart.count}'),
          backgroundColor: MadadColors.teal,
          child: IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.shopping_bag_outlined),
            color: MadadColors.navy,
          ),
        );
      },
    );
  }
}

class _OfferBanner extends StatelessWidget {
  const _OfferBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MadadColors.navy,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عرض التوصيل',
                      style: TextStyle(
                        color: MadadColors.sand,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'توصيل مجاني للطلبات التي تبلغ 500 ر.س أو أكثر.',
                      style: TextStyle(color: MadadColors.white, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const PriceLabel(0, color: MadadColors.sand),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            CategoryGlyph(icon: category.icon),
            const SizedBox(height: 6),
            Text(
              category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: MadadColors.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
