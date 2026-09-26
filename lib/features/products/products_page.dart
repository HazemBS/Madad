import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/utils/madad_messenger.dart';
import '../../core/widgets/madad_message_view.dart';
import '../../core/widgets/product_tile.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../data/models/supplier.dart';
import '../../data/repositories/catalog_repository.dart';

enum ProductSort { popular, priceAsc, priceDesc, name }

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, required this.query});

  final ProductsQuery query;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late final TextEditingController _search;
  ProductSort _sort = ProductSort.popular;
  var _inStockOnly = false;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.query.search ?? '');
    _categoryId = widget.query.categoryId;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Product> _visible(CatalogRepository catalog) {
    final query = _search.text.trim();
    var list = catalog.products().where((product) {
      if (_categoryId != null && product.categoryId != _categoryId) {
        return false;
      }
      if (widget.query.supplierId != null &&
          product.supplierId != widget.query.supplierId) {
        return false;
      }
      if (_inStockOnly && !product.inStock) return false;
      if (query.isEmpty) return true;
      final supplier = catalog.supplierName(product.supplierId);
      return product.name.contains(query) || supplier.contains(query);
    }).toList();

    switch (_sort) {
      case ProductSort.priceAsc:
        list.sort((a, b) => a.wholesalePrice.compareTo(b.wholesalePrice));
      case ProductSort.priceDesc:
        list.sort((a, b) => b.wholesalePrice.compareTo(a.wholesalePrice));
      case ProductSort.name:
        list.sort((a, b) => a.name.compareTo(b.name));
      case ProductSort.popular:
        list.sort((a, b) {
          if (a.isPopular == b.isPopular) return 0;
          return a.isPopular ? -1 : 1;
        });
    }
    return list;
  }

  void _add(Product product) {
    final notice = MadadScope.of(context).cart.add(product, product.minOrder);
    showMadadMessage(context, notice ?? 'أُضيف المنتج إلى السلة');
  }

  Future<void> _openFilters(CatalogRepository catalog) async {
    final sort = await showModalBottomSheet<ProductSort>(
      context: context,
      backgroundColor: MadadColors.sand,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الترتيب', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                _sortTile(context, 'الأكثر طلبًا', ProductSort.popular),
                _sortTile(context, 'السعر: من الأقل', ProductSort.priceAsc),
                _sortTile(context, 'السعر: من الأعلى', ProductSort.priceDesc),
                _sortTile(context, 'الاسم', ProductSort.name),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('المتوفر فقط'),
                  value: _inStockOnly,
                  activeThumbColor: MadadColors.teal,
                  onChanged: (value) {
                    setState(() => _inStockOnly = value);
                    Navigator.pop(context, _sort);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (sort != null) setState(() => _sort = sort);
  }

  Widget _sortTile(BuildContext context, String label, ProductSort sort) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: _sort == sort
          ? const Icon(Icons.check, color: MadadColors.teal)
          : null,
      onTap: () => Navigator.pop(context, sort),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = MadadScope.of(context).catalog;
    final categoryName = _categoryId == null
        ? null
        : catalog.categoryName(_categoryId!);
    final products = _visible(catalog);
    final queryText = _search.text.trim();
    final suppliers = queryText.isEmpty
        ? <Supplier>[]
        : catalog
              .suppliers()
              .where((supplier) => supplier.name.contains(queryText))
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName ?? 'المنتجات'),
        actions: [
          IconButton(
            tooltip: 'السلة',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'ابحث عن منتج أو مورد',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ActionChip(
              label: const Text('ترتيب وتصفية'),
              avatar: const Icon(Icons.tune, size: 18, color: MadadColors.navy),
              backgroundColor: MadadColors.white,
              onPressed: () => _openFilters(catalog),
            ),
          ),
          if (_categoryId != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => setState(() => _categoryId = null),
                child: const Text('إزالة تصفية التصنيف'),
              ),
            ),
          if (suppliers.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'موردون مطابقون',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final supplier in suppliers)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: MadadColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: MadadColors.line),
                  ),
                  title: Text(supplier.name),
                  subtitle: Text(supplier.city),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {
                    Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.supplier, arguments: supplier.id);
                  },
                ),
              ),
          ],
          const SizedBox(height: 8),
          if (products.isEmpty)
            const MadadMessageView(
              icon: Icons.search_off,
              title: 'لا توجد نتائج',
              message: 'جرّب اسمًا آخر أو أزل التصفية.',
            )
          else
            for (final product in products) ...[
              ProductTile(
                product: product,
                supplierName: catalog.supplierName(product.supplierId),
                icon:
                    catalog.categoryById(product.categoryId)?.icon ??
                    CategoryIcon.food,
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.productDetails, arguments: product.id);
                },
                onAdd: () => _add(product),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}
