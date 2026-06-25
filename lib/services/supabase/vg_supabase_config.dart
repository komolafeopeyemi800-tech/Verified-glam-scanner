/// Supabase + Google OAuth configuration via --dart-define.
class VGSupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static bool get hasValidUrl {
    final u = url.trim();
    return u.startsWith('https://') && u.contains('.');
  }

  static bool get isConfigured =>
      hasValidUrl && anonKey.trim().isNotEmpty;

  static bool get hasGoogleSignIn => googleWebClientId.isNotEmpty;
}
