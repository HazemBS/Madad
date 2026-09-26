import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rafd_v01/main.dart' as app;

Future<void> mark(
  String name, {
  Duration hold = const Duration(milliseconds: 1600),
}) async {
  final file = File('${Directory.systemTemp.path}/madad_step.txt');
  await file.writeAsString('$name\n${DateTime.now().toIso8601String()}');
  await Future<void>.delayed(hold);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('رحلة العرض المحلية على الجهاز', (tester) async {
    await app.main();
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await tester.pump();
    if (find.textContaining('قيمة تتبادل').evaluate().isNotEmpty) {
      await mark('splash', hold: const Duration(milliseconds: 500));
    }
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.text('تخطي').evaluate().isNotEmpty) break;
    }

    expect(find.text('تخطي'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('skip-onboarding')));
    await tester.pumpAndSettle();

    expect(find.text('دخول تجريبي'), findsOneWidget);
    await mark('login');
    await tester.tap(find.byKey(const ValueKey('demo-login')));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.textContaining('بقالة النور'), findsOneWidget);
    await mark('home');

    await tester.scrollUntilVisible(
      find.text('أرز بسمتي هندي 10 كجم'),
      400,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('home-scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('أرز بسمتي هندي 10 كجم'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المنتج'), findsOneWidget);
    expect(find.text('إضافة إلى السلة'), findsOneWidget);
    await mark('product_details');

    await tester.tap(find.byTooltip('إضافة إلى المفضلة'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.byKey(const ValueKey('add-to-cart')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byKey(const ValueKey('details-open-cart')));
    await tester.pumpAndSettle();

    expect(find.text('سلة المشتريات'), findsOneWidget);
    expect(find.text('أرز بسمتي هندي 10 كجم'), findsOneWidget);
    await mark('cart');

    await tester.tap(find.byKey(const ValueKey('checkout-button')));
    await tester.pumpAndSettle();
    expect(find.text('تأكيد الطلب'), findsWidgets);
    await mark('checkout');

    await tester.ensureVisible(find.byKey(const ValueKey('confirm-order')));
    await tester.tap(find.byKey(const ValueKey('confirm-order')));
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('confirm-order')))
          .onPressed,
      isNull,
    );
    await tester.pumpAndSettle();

    expect(find.text('تم تأكيد طلبك'), findsOneWidget);
    expect(find.text('MD-1049'), findsOneWidget);
    await mark('order_success');

    await tester.tap(find.byKey(const ValueKey('track-order')));
    await tester.pumpAndSettle();
    expect(find.text('طلباتي'), findsWidgets);
    expect(find.text('MD-1049'), findsOneWidget);
    await mark('orders');

    await tester.tap(find.byKey(const ValueKey('tab-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('logout')));
    await tester.pumpAndSettle();
    expect(find.text('دخول تجريبي'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('demo-login')));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();
    expect(find.text('سلتك فارغة'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tab-3')));
    await tester.pumpAndSettle();
    expect(find.text('لا توجد مفضلة'), findsOneWidget);

    await mark('done', hold: const Duration(milliseconds: 200));
  });
}
