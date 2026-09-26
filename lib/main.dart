import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/madad_app.dart';
import 'core/config/supabase_config.dart';
import 'core/storage/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await LocalStore.open();
  var demoMode = !SupabaseConfig.isConfigured;
  const missingConfig =
      'وضع التجربة المحلي: لم يُضبط SUPABASE_URL أو SUPABASE_ANON_KEY. البيانات على هذا الجهاز فقط.';
  var startupNote = demoMode ? missingConfig : null;
  if (!demoMode) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.anonKey,
      );
    } catch (_) {
      demoMode = true;
      startupNote =
          'تعذر الاتصال بخادم مَدَد. يعمل التطبيق في وضع التجربة المحلي.';
    }
  }
  runApp(MadadApp(store: store, demoMode: demoMode, startupNote: startupNote));
}
