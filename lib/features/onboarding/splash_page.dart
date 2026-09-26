import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/madad_brand.dart';
import '../../core/theme/madad_colors.dart';
import '../../core/widgets/madad_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  var _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _continue());
  }

  Future<void> _continue() async {
    if (_started) return;
    _started = true;
    final delay = MadadScope.of(context).splashDelay;
    await Future<void>.delayed(delay);
    if (!mounted) return;
    final scope = MadadScope.of(context);
    if (!scope.demoMode) {
      await scope.catalog.refresh();
    }
    if (!mounted) return;
    final restored = await scope.session.restore();
    if (!mounted) return;
    if (restored) {
      try {
        await scope.orders.refresh();
        await scope.favorites.refresh();
      } catch (_) {}
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.shell, (_) => false);
      return;
    }
    final done = scope.session.onboardingDone;
    Navigator.of(
      context,
    ).pushReplacementNamed(done ? AppRoutes.login : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: MadadColors.navy,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: MadadColors.sand,
                    shape: BoxShape.circle,
                  ),
                  child: const MadadLogo(showEnglish: false, compact: true),
                ),
                const SizedBox(height: 28),
                Text(
                  MadadBrand.englishName,
                  style: theme.labelLarge?.copyWith(
                    color: MadadColors.teal,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  MadadBrand.tagline,
                  textAlign: TextAlign.center,
                  style: theme.titleMedium?.copyWith(
                    color: MadadColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (MadadScope.of(context).demoMode) ...[
                  const SizedBox(height: 20),
                  Text(
                    MadadScope.of(context).startupNote ??
                        'وضع التجربة المحلي: البيانات على هذا الجهاز فقط.',
                    key: const ValueKey('demo-mode-banner'),
                    textAlign: TextAlign.center,
                    style: theme.bodySmall?.copyWith(color: MadadColors.sand),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
