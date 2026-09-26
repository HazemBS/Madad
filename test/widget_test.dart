import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafd_v01/app/madad_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> boot(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MadadApp(splashDelay: Duration.zero));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  Future<void> enterDemo(WidgetTester tester) async {
    expect(find.text('وصول مباشر إلى الموردين'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('skip-onboarding')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('demo-login')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  testWidgets('رحلة الطلب من البداية حتى طلباتي', (tester) async {
    await boot(tester, const Size(360, 740));
    await enterDemo(tester);
    expect(find.textContaining('بقالة النور'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أرز بسمتي هندي 10 كجم'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل المنتج'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('add-to-cart')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byKey(const ValueKey('details-open-cart')));
    await tester.pumpAndSettle();

    expect(find.text('سلة المشتريات'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('checkout-button')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.ensureVisible(find.byKey(const ValueKey('confirm-order')));
    await tester.tap(find.byKey(const ValueKey('confirm-order')));
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('confirm-order')))
          .onPressed,
      isNull,
    );
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.text('تم تأكيد طلبك'), findsOneWidget);
    expect(find.text('MD-1049'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('track-order')));
    await tester.pumpAndSettle();
    expect(find.text('طلباتي'), findsWidgets);
    expect(find.text('MD-1049'), findsOneWidget);
  });

  testWidgets('تبويبات الشريط السفلي على شاشة صغيرة', (tester) async {
    await boot(tester, const Size(320, 568));
    await enterDemo(tester);

    for (final tab in [1, 2, 3, 4, 0]) {
      await tester.tap(find.byKey(ValueKey('tab-$tab')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    expect(find.textContaining('خالد العمري'), findsWidgets);
  });

  testWidgets('دخول المورد يفتح حساب واحة الغذاء والطلبات الواردة', (
    tester,
  ) async {
    await boot(tester, const Size(390, 844));
    await tester.tap(find.byKey(const ValueKey('skip-onboarding')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('demo-supplier')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.textContaining('واحة الغذاء للجملة'), findsWidgets);
    expect(find.text('منتجاتك'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tab-2')));
    await tester.pumpAndSettle();
    expect(find.text('الطلبات الواردة'), findsOneWidget);
    expect(find.text('MD-1048'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tab-3')));
    await tester.pumpAndSettle();
    expect(find.text('مورد'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('المورد يضيف منتجًا جديدًا ويظهر في منتجاته', (tester) async {
    await boot(tester, const Size(390, 844));
    await tester.tap(find.byKey(const ValueKey('skip-onboarding')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('demo-supplier')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('add-product')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('new-product-name')),
      'تمر خلاص',
    );
    await tester.enterText(
      find.byKey(const ValueKey('new-product-price')),
      '40',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-product')));
    await tester.tap(find.byKey(const ValueKey('save-product')));
    await tester.pumpAndSettle();

    expect(find.text('تمر خلاص'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
