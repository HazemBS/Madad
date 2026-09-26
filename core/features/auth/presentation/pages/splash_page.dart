import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/rafd_colors.dart';
import '../cubit/splash_cubit.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SplashCubit(supabase: Supabase.instance.client)..checkSession(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: _handleState,
      child: Scaffold(
        backgroundColor: RafdColors.navy,
        body: SafeArea(
          child: Center(
            child: BlocBuilder<SplashCubit, SplashState>(
              builder: (context, state) {
                if (state is SplashFailure) {
                  return _SplashError(message: state.message);
                }

                return const _SplashContent();
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleState(BuildContext context, SplashState state) {
    if (state is! SplashSuccess) {
      return;
    }

    final route = switch (state.destination) {
      SplashDestination.login => AppRoutes.login,
      SplashDestination.customerHome => AppRoutes.customerHome,
      SplashDestination.wholesalerDashboard => AppRoutes.wholesalerDashboard,
    };

    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/rafd_logo.png',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'رَفْد',
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(color: RafdColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'نربط الأعمال بفرصها',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: RafdColors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 28),
          const SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              minHeight: 5,
              color: RafdColors.teal,
              backgroundColor: RafdColors.ink,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashError extends StatelessWidget {
  const _SplashError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: RafdColors.white,
            size: 64,
          ),
          const SizedBox(height: 20),
          Text(
            'تعذر تشغيل التطبيق',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: RafdColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: RafdColors.border),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              context.read<SplashCubit>().checkSession();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
