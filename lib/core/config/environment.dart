/// SmartRoute Uganda — Environment configuration.
///
/// All external service credentials are read from this class.
/// **NEVER commit real credentials to source control.**
/// Use a `.env` file or build-time --dart-define flags.
///
/// ## Configuration
///
/// For development, create `lib/core/config/environment.local.dart` (git-ignored)
/// and override the const values, or pass via flutter run:
///
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ... \
///     --dart-define=ENVIRONMENT=development
///
/// ## Available environments
/// - `development` — local/emulated backend, demo data fallback enabled
/// - `staging`     — real Supabase project, test data
/// - `production`  — real Supabase project, live data
abstract class AppEnvironment {
  // ─── Supabase ─────────────────────────────────────────────────────────────

  /// Supabase project URL.
  /// Example: https://abcdefghijklmnop.supabase.co
  /// Set via: --dart-define=SUPABASE_URL=https://...
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anonymous public key.
  /// This is safe to include in client code — it has limited RLS-enforced access.
  /// Set via: --dart-define=SUPABASE_ANON_KEY=eyJ...
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // ─── Routing API ─────────────────────────────────────────────────────────

  /// OpenRouteService API key (optional — enables real routing).
  /// Free tier available at https://openrouteservice.org
  /// Set via: --dart-define=ORS_API_KEY=...
  static const String orsApiKey = String.fromEnvironment(
    'ORS_API_KEY',
    defaultValue: '',
  );

  // ─── Environment name ─────────────────────────────────────────────────────

  static const String _envName = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static EnvironmentName get current {
    switch (_envName) {
      case 'production':
        return EnvironmentName.production;
      case 'staging':
        return EnvironmentName.staging;
      default:
        return EnvironmentName.development;
    }
  }

  // ─── Feature flags ────────────────────────────────────────────────────────

  /// True when Supabase is configured and should be used.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// True when real routing via OpenRouteService is available.
  static bool get isRoutingConfigured => orsApiKey.isNotEmpty;

  /// True when demo/fallback mode should be used as the primary data source.
  /// This is true in development if no backend credentials are provided.
  static bool get isDemoMode =>
      !isSupabaseConfigured || current == EnvironmentName.development;

  /// Routing service base URL (OpenRouteService).
  static const String orsBaseUrl = 'https://api.openrouteservice.org';

  /// Whether to show demo data banners throughout the UI.
  static bool get showDemoBanners => isDemoMode;
}

enum EnvironmentName { development, staging, production }
