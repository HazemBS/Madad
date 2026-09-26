import 'package:flutter/material.dart';

import '../../app/madad_scope.dart';
import '../../core/widgets/madad_builder.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/madad_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = MadadScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: MadadBuilder(
        cubits: [scope.session],
        builder: (context, _) {
          final profile = scope.session.profile;
          if (profile == null) {
            return const Center(child: Text('لا توجد جلسة دخول'));
          }
          final theme = Theme.of(context).textTheme;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MadadColors.navy,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.businessName,
                      style: theme.headlineSmall?.copyWith(
                        color: MadadColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.ownerName,
                      style: theme.bodyLarge?.copyWith(color: MadadColors.sand),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                label: 'نوع الحساب',
                value: scope.session.isSupplier ? 'مورد' : 'متجر',
              ),
              _InfoRow(label: 'رقم الجوال', value: profile.phone, ltr: true),
              _InfoRow(label: 'المدينة', value: profile.city),
              const SizedBox(height: 8),
              Text('العناوين', style: theme.titleMedium),
              const SizedBox(height: 8),
              for (final address in profile.addresses)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: MadadColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(address, style: theme.bodyLarge),
                ),
              const SizedBox(height: 8),
              Text(
                'بيانات المنشأة محلية لهذا العرض، وتُمسح عند إغلاق التطبيق.',
                style: theme.bodySmall,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const ValueKey('logout'),
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    scope.shell.goTo(0);
                    await scope.session.logout();
                    scope.cart.clear();
                    scope.favorites.clear();
                    navigator.pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (_) => false,
                    );
                  },
                  child: const Text('تسجيل الخروج'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.ltr = false});

  final String label;
  final String value;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MadadColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.bodyMedium)),
          const SizedBox(width: 12),
          Flexible(
            child: ltr
                ? Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(value, style: theme.titleSmall),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.end,
                    style: theme.titleSmall,
                  ),
          ),
        ],
      ),
    );
  }
}
