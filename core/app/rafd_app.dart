import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/routing/app_router.dart';
import '../core/routing/app_routes.dart';
import '../core/theme/rafd_theme.dart';

class RafdApp extends StatelessWidget {
  const RafdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'رَفْد',
      debugShowCheckedModeBanner: false,

      theme: RafdTheme.light,

      locale: const Locale('ar', 'SA'),

      supportedLocales: const [Locale('ar', 'SA')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,

      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
