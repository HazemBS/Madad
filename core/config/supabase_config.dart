abstract final class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');

  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured {
    return url.isNotEmpty && anonKey.isNotEmpty;
  }

  static void validate() {
    if (!isConfigured) {
      throw StateError(
        'Supabase is not configured. '
        'Run the application with SUPABASE_URL '
        'and SUPABASE_ANON_KEY.',
      );
    }
  }
}
