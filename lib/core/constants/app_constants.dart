/// Application-wide constants for the Pinterest Clone app.
class AppConstants {
  AppConstants._();

  // ── Pexels API ──────────────────────────────────────────────────────────
  /// Replace with your own Pexels API key from https://www.pexels.com/api/
  /// Loaded via --dart-define=PEXELS_API_KEY=<your_key>
  /// Never hardcode API keys in source files!
  static const String pexelsApiKey = String.fromEnvironment(
    'PEXELS_API_KEY',
    defaultValue: '',
  );

  static const String pexelsBaseUrl = 'https://api.pexels.com/v1';

  // ── Pagination ──────────────────────────────────────────────────────────
  static const int itemsPerPage = 20;

  // ── Grid ────────────────────────────────────────────────────────────────
  static const int gridColumnCount = 2;
  static const double gridCrossAxisSpacing = 8.0;
  static const double gridMainAxisSpacing = 8.0;
  static const double screenPadding = 12.0;

  // ── UI ──────────────────────────────────────────────────────────────────
  static const double cardBorderRadius = 16.0;
  static const double searchBarBorderRadius = 24.0;

  // ── Animation ───────────────────────────────────────────────────────────
  static const int tapScaleDurationMs = 120;
  static const double tapScaleDown = 0.97;
  static const int heroTransitionDurationMs = 300;
  static const int debounceDurationMs = 300;

  // ── Shimmer ─────────────────────────────────────────────────────────────
  static const int shimmerBaseColor = 0xFFE0E0E0;
  static const int shimmerHighlightColor = 0xFFF5F5F5;
}
