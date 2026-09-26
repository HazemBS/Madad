import 'supabase_config.dart';

enum AppEnvironment { demo, connected }

/// وضع التجربة يُفعَّل عند غياب إعداد Supabase، لا بعلم محفوظ على الجهاز.
abstract final class AppConfig {
  static bool get isDemo => !SupabaseConfig.isConfigured;

  static AppEnvironment get environment =>
      isDemo ? AppEnvironment.demo : AppEnvironment.connected;
}
