/// إعداد الإنتاج فقط. لا يستدعيه وضع العرض، ولا يحتوي أسرارًا مكتوبة.
///
/// المفتاح العام (anon) ليس مفتاح الخدمة. إن استُخدم لاحقًا فيجب أن يبقى
/// بلا صلاحيات خطرة إلى أن تُختبر سياسات الصفوف. مفتاح الخدمة وكلمة مرور
/// قاعدة البيانات لا يوضعان في التطبيق.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const demoEmail = String.fromEnvironment('MADAD_DEMO_EMAIL');
  static const demoPassword = String.fromEnvironment('MADAD_DEMO_PASSWORD');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
