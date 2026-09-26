import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/madad_scope.dart';
import '../../core/theme/madad_colors.dart';
import '../../data/models/product.dart';
import '../../data/remote/madad_store.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key, required this.supplierId});

  final String supplierId;

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _minOrder = TextEditingController(text: '1');
  final _stock = TextEditingController(text: '10');
  ProductUnit _unit = ProductUnit.carton;
  String? _categoryId;
  String? _error;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _minOrder.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final scope = MadadScope.of(context);
    final name = _name.text.trim();
    final price = double.tryParse(_price.text.trim().replaceAll(',', '.'));
    final minOrder = int.tryParse(_minOrder.text.trim());
    final stock = int.tryParse(_stock.text.trim());
    final categoryId =
        _categoryId ?? scope.catalog.categories().firstOrNull?.id;
    if (name.isEmpty) {
      setState(() => _error = 'اكتب اسم المنتج.');
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _error = 'اكتب سعر جملة أكبر من صفر.');
      return;
    }
    if (minOrder == null || minOrder < 1) {
      setState(() => _error = 'الحد الأدنى يجب أن يكون 1 على الأقل.');
      return;
    }
    if (stock == null || stock < minOrder) {
      setState(() => _error = 'المخزون يجب ألا يقل عن الحد الأدنى للطلب.');
      return;
    }
    if (categoryId == null) {
      setState(() => _error = 'اختر تصنيف المنتج.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final description = _description.text.trim().isEmpty
        ? (scope.demoMode
              ? 'منتج أضافه المورد في العرض المحلي.'
              : 'منتج أضافه المورد.')
        : _description.text.trim();
    try {
      if (scope.demoMode) {
        scope.catalog.addProduct(
          supplierId: widget.supplierId,
          name: name,
          description: description,
          wholesalePrice: price,
          unit: _unit,
          minOrder: minOrder,
          stock: stock,
          categoryId: categoryId,
        );
      } else {
        final product = await scope.commerce.createProduct(
          supplierId: widget.supplierId,
          name: name,
          description: description,
          wholesalePrice: price,
          unit: _unit,
          minOrder: minOrder,
          stock: stock,
          categoryId: categoryId,
        );
        scope.catalog.insertProduct(product);
      }
    } on MadadAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.message;
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'تعذر حفظ المنتج. تحقق من الاتصال ثم أعد المحاولة.';
      });
      return;
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('أُضيف «$name» إلى منتجاتك.')));
  }

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    final catalog = scope.catalog;
    final categories = catalog.categories();
    final categoryId = _categoryId ?? categories.firstOrNull?.id;
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة منتج جديد')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            scope.demoMode
                ? 'يُحفظ المنتج على هذا الجهاز ضمن وضع التجربة.'
                : 'يُحفظ المنتج في حسابك على الخادم. رفع الصور غير متاح الآن، وتظهر أيقونة التصنيف.',
            style: theme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('new-product-name'),
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'اسم المنتج'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            minLines: 2,
            maxLines: 3,
            maxLength: 240,
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
                    const SizedBox.shrink(),
            decoration: const InputDecoration(labelText: 'الوصف'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('new-product-price'),
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(labelText: 'سعر الجملة'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ProductUnit>(
            initialValue: _unit,
            decoration: const InputDecoration(labelText: 'الوحدة'),
            items: [
              for (final unit in ProductUnit.values)
                DropdownMenuItem(value: unit, child: Text(unit.label)),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _unit = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: categoryId,
            decoration: const InputDecoration(labelText: 'التصنيف'),
            items: [
              for (final category in categories)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: (value) => setState(() => _categoryId = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minOrder,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'الحد الأدنى'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'المخزون'),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: theme.bodyMedium?.copyWith(color: MadadColors.navy),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Material(
        color: MadadColors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: FilledButton(
              key: const ValueKey('save-product'),
              onPressed: _saving ? null : _save,
              child: const Text('حفظ المنتج'),
            ),
          ),
        ),
      ),
    );
  }
}

void openAddProduct(BuildContext context) {
  final supplierId = MadadScope.of(context).session.supplierId;
  if (supplierId == null) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => AddProductPage(supplierId: supplierId),
    ),
  );
}
