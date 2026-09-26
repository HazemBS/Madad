import 'package:flutter/material.dart';

import 'app/madad_app.dart';
import 'core/config/app_environment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!AppConfig.isDemo) {
    throw StateError(
      'وضع الإنتاج غير موصول بنقطة التشغيل. العرض الافتراضي محلي فقط.',
    );
  }
  runApp(const MadadApp());
}
