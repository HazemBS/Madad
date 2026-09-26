import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/madad_brand.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/widgets/madad_logo.dart';
import 'session_cubit.dart';

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
        _error = 'تعذر تسجيل الدخول. أعد المحاولة.';
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
    if (!MadadScope.of(context).demoMode) {
      return const ConnectedLoginPage();
    }
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
                            if (MadadScope.of(context).demoMode) ...[
                              Text(
                                MadadScope.of(context).startupNote ??
                                    'وضع التجربة المحلي: البيانات على هذا الجهاز فقط.',
                                key: const ValueKey('demo-mode-banner'),
                                textAlign: TextAlign.center,
                                style: theme.bodySmall?.copyWith(
                                  color: MadadColors.teal,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
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

class ConnectedLoginPage extends StatefulWidget {
  const ConnectedLoginPage({super.key});

  @override
  State<ConnectedLoginPage> createState() => _ConnectedLoginPageState();
}

class _ConnectedLoginPageState extends State<ConnectedLoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _business = TextEditingController();
  final _owner = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController(text: 'الرياض');
  final _address = TextEditingController();
  var _registering = false;
  var _busy = false;
  var _supplier = false;
  String? _error;
  String? _notice;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phonePattern = RegExp(r'^05\d{8}$');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _business.dispose();
    _owner.dispose();
    _phone.dispose();
    _city.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final email = _email.text.trim();
    final password = _password.text;
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = 'اكتب بريدًا إلكترونيًا صالحًا.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.');
      return;
    }
    if (_registering) {
      if (_business.text.trim().isEmpty || _owner.text.trim().isEmpty) {
        setState(() => _error = 'اكتب اسم المنشأة واسم المسؤول.');
        return;
      }
      if (!_phonePattern.hasMatch(_phone.text.trim())) {
        setState(() => _error = 'اكتب رقم جوال سعودي من 10 أرقام يبدأ بـ 05.');
        return;
      }
      if (_city.text.trim().isEmpty || _address.text.trim().isEmpty) {
        setState(() => _error = 'اكتب المدينة وعنوان التوصيل.');
        return;
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final scope = MadadScope.of(context);
    final ok = _registering
        ? await scope.session.register(
            email: email,
            password: password,
            role: _supplier ? AccountRole.supplier : AccountRole.shop,
            businessName: _business.text.trim(),
            ownerName: _owner.text.trim(),
            phone: _phone.text.trim(),
            city: _city.text.trim(),
            address: _address.text.trim(),
          )
        : await scope.session.signInWithEmail(email: email, password: password);
    if (!mounted) return;
    if (!ok) {
      final confirm = scope.session.state.status == AuthStatus.confirmEmail;
      setState(() {
        _busy = false;
        if (confirm) {
          _registering = false;
          _error = null;
          _notice =
              scope.session.state.message ??
              'أُنشئ الحساب. أكّد البريد الإلكتروني ثم سجّل الدخول.';
          _password.clear();
          _business.clear();
          _owner.clear();
          _phone.clear();
          _address.clear();
          _city.text = 'الرياض';
          _supplier = false;
        } else {
          _notice = null;
          _error = scope.session.state.message ?? 'تعذر إكمال العملية.';
        }
      });
      return;
    }
    await scope.catalog.refresh();
    try {
      await scope.orders.refresh();
      await scope.favorites.refresh();
    } catch (_) {}
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
          const SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 16),
              child: MadadLogo(light: true),
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
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 16 + bottomInset),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - 40 - bottomInset)
                            .clamp(0, double.infinity),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _registering ? 'إنشاء حساب' : 'تسجيل الدخول',
                            style: theme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'الدخول بالبريد وكلمة المرور. رقم الجوال يُحفظ في ملف المنشأة ولا يُستخدم كبريد.',
                            style: theme.bodyMedium?.copyWith(
                              color: MadadColors.muted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            key: const ValueKey('auth-email'),
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            key: const ValueKey('auth-password'),
                            controller: _password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'كلمة المرور',
                            ),
                          ),
                          if (_registering) ...[
                            const SizedBox(height: 12),
                            SegmentedButton<bool>(
                              segments: const [
                                ButtonSegment(
                                  value: false,
                                  label: Text('متجر'),
                                ),
                                ButtonSegment(value: true, label: Text('مورد')),
                              ],
                              selected: {_supplier},
                              onSelectionChanged: (value) {
                                setState(() => _supplier = value.first);
                              },
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _business,
                              decoration: const InputDecoration(
                                labelText: 'اسم المنشأة',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _owner,
                              decoration: const InputDecoration(
                                labelText: 'اسم المسؤول',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              decoration: const InputDecoration(
                                labelText: 'جوال المنشأة',
                                hintText: '05xxxxxxxx',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _city,
                              decoration: const InputDecoration(
                                labelText: 'المدينة',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _address,
                              decoration: const InputDecoration(
                                labelText: 'العنوان',
                              ),
                            ),
                          ],
                          if (_notice != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _notice!,
                              key: const ValueKey('auth-notice'),
                              style: theme.bodyMedium?.copyWith(
                                color: MadadColors.teal,
                              ),
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              key: const ValueKey('auth-error'),
                              style: theme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton(
                            key: const ValueKey('auth-submit'),
                            onPressed: _busy ? null : _submit,
                            child: _busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: MadadColors.white,
                                    ),
                                  )
                                : Text(_registering ? 'إنشاء الحساب' : 'دخول'),
                          ),
                          TextButton(
                            key: const ValueKey('auth-toggle-register'),
                            onPressed: _busy
                                ? null
                                : () => setState(() {
                                    _registering = !_registering;
                                    _error = null;
                                    _notice = null;
                                  }),
                            child: Text(
                              _registering
                                  ? 'لدي حساب بالفعل'
                                  : 'إنشاء حساب جديد',
                            ),
                          ),
                        ],
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
