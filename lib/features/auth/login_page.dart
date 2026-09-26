import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/madad_brand.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/widgets/madad_logo.dart';
import 'session_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phone = TextEditingController();
  String? _error;
  var _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  bool _valid(String value) => RegExp(r'^05\d{8}$').hasMatch(value);

  Future<void> _submit({AccountRole? demoRole}) async {
    if (_busy) return;
    final phone = switch (demoRole) {
      AccountRole.supplier => MadadBrand.demoSupplierPhone,
      AccountRole.shop => MadadBrand.demoPhone,
      null => _phone.text.trim(),
    };
    if (demoRole != null) _phone.text = phone;
    if (!_valid(phone)) {
      setState(() => _error = 'أدخل رقم جوال سعودي من 10 أرقام يبدأ بـ 05');
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final scope = MadadScope.of(context);
    try {
      await scope.session.login(phone, role: demoRole ?? AccountRole.shop);
      await scope.orders.refresh();
      await scope.favorites.refresh();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'تعذر تسجيل الدخول. تحقق من الاتصال ثم أعد المحاولة.';
      });
      return;
    }
    if (!mounted) return;
    scope.shell.goTo(0);
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: MadadColors.navy,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
              child: Column(
                children: [
                  const MadadLogo(light: true),
                  const SizedBox(height: 8),
                  Text(
                    MadadBrand.tagline,
                    style: theme.bodyMedium?.copyWith(color: MadadColors.sand),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: MadadColors.sand,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 28, 20, 16 + bottomInset),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - 44 - bottomInset)
                            .clamp(0, double.infinity),
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('تسجيل الدخول', style: theme.headlineSmall),
                            const SizedBox(height: 8),
                            Text(
                              'أدخل رقم جوال المنشأة للمتابعة إلى سوق الجملة.',
                              style: theme.bodyMedium?.copyWith(
                                color: MadadColors.muted,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                labelText: 'رقم الجوال',
                                hintText: '05xxxxxxxx',
                                errorText: _error,
                                prefixIcon: const Icon(Icons.phone_iphone),
                              ),
                              onSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _busy ? null : () => _submit(),
                                child: _busy
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: MadadColors.white,
                                        ),
                                      )
                                    : const Text('متابعة'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                key: const ValueKey('demo-login'),
                                onPressed: _busy
                                    ? null
                                    : () => _submit(demoRole: AccountRole.shop),
                                child: const Text('دخول تجريبي'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                key: const ValueKey('demo-supplier'),
                                onPressed: _busy
                                    ? null
                                    : () => _submit(
                                        demoRole: AccountRole.supplier,
                                      ),
                                child: const Text('دخول كمورد'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'دخول المتجر يفتح بقالة النور. دخول المورد يفتح واحة الغذاء للجملة.',
                              textAlign: TextAlign.center,
                              style: theme.bodySmall,
                            ),
                            const Spacer(),
                            const SizedBox(height: 20),
                            const _LoginFooter(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  static const _points = <(IconData, String)>[
    (Icons.verified_outlined, 'موردون موثّقون'),
    (Icons.payments_outlined, 'سعر جملة واضح'),
    (Icons.inventory_2_outlined, 'حد أدنى للطلب'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MadadColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MadadColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        child: Row(
          children: [
            for (final point in _points)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(point.$1, color: MadadColors.teal, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      point.$2,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.bodySmall?.copyWith(
                        color: MadadColors.navy,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
