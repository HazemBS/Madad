import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/widgets/madad_logo.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = <(IconData, String, String)>[
    (
      Icons.storefront_outlined,
      'وصول مباشر إلى الموردين',
      'تصفح تجار الجملة الموثوقين في مدينتك، وتعرّف على تصنيفاتهم وتقييمهم من مكان واحد.',
    ),
    (
      Icons.compare_arrows,
      'قارن منتجات الجملة',
      'شاهد سعر الجملة والوحدة والحد الأدنى للطلب قبل أن تتواصل مع أي مورد.',
    ),
    (
      Icons.local_shipping_outlined,
      'اطلب وتتبّع مشترياتك',
      'جهّز سلتك، أكّد الطلب، وتابع حالته من جديد حتى الاكتمال دون رسائل متفرقة.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    MadadScope.of(context).session.completeOnboarding();
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final last = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              const MadadLogo(compact: true),
              const SizedBox(height: 12),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: MadadColors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight - 40,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: const BoxDecoration(
                                        color: MadadColors.sand,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        page.$1,
                                        size: 34,
                                        color: MadadColors.navy,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      page.$2,
                                      textAlign: TextAlign.center,
                                      style: theme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      page.$3,
                                      textAlign: TextAlign.center,
                                      style: theme.bodyMedium?.copyWith(
                                        color: MadadColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _index ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? MadadColors.teal
                            : MadadColors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: last ? const ValueKey('start-now') : null,
                  onPressed: _next,
                  child: Text(last ? 'ابدأ الآن' : 'التالي'),
                ),
              ),
              TextButton(
                key: const ValueKey('skip-onboarding'),
                onPressed: _finish,
                child: const Text('تخطي'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
