/// SmartRoute Uganda — Map configuration.
///
/// Centralises all map provider settings so the tile source can be replaced
/// without touching map UI code.
///
/// Production note: The standard OSM tile service is used for demonstration
/// purposes. A production deployment should evaluate a suitable hosted tile
/// provider (e.g. MapTiler, Stadia Maps, self-hosted) to comply with OSM
/// tile usage policy at scale.
abstract class MapConfig {
  // ─── Tile Provider ────────────────────────────────────────────────────────

  /// Standard OpenStreetMap raster tiles.
  /// Requires HTTPS. Attribution must always be visible.
  /// Do not bulk-download, bypass caching, or scrape tiles.
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Attribution text that must remain visible on all map views.
  static const String osmAttribution = '© OpenStreetMap contributors';

  /// OpenStreetMap tile usage policy URL.
  static const String osmPolicyUrl =
      'https://operations.osmfoundation.org/policies/tiles/';

  /// User-Agent hint for the HTTP client (good practice for OSM tile requests).
  static const String tileUserAgent = 'SmartRoute-Uganda-App/1.0';

  // ─── Photon Geocoding ─────────────────────────────────────────────────────

  /// Photon geocoding API base URL (komoot-hosted, OSM-based).
  /// Free to use; respect rate limits — do not query per-keystroke without
  /// debouncing. See: https://photon.komoot.io
  static const String photonBaseUrl = 'https://photon.komoot.io';

  /// Uganda bounding box for Photon search bias: minLon,minLat,maxLon,maxLat.
  /// Biases results towards Uganda without excluding global results entirely.
  static const String ugandaBbox = '29.5,-1.5,35.1,4.3';

  /// Maximum number of geocoding suggestions to request per query.
  static const int geocodingSuggestionLimit = 7;

  /// Debounce duration for geocoding search inputs (ms).
  /// Prevents excessive API requests while the user is still typing.
  static const int geocodingDebounceMs = 400;

  // ─── Nominatim Reverse Geocoding ──────────────────────────────────────────

  /// Nominatim reverse geocoding endpoint.
  /// Used only for single reverse lookups (not autocomplete).
  /// Complies with OSM Nominatim usage policy: one request per user action.
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  // ─── Default map view ─────────────────────────────────────────────────────

  /// Initial map centre — Kampala, Uganda.
  static const double defaultLatitude = 0.3476;
  static const double defaultLongitude = 32.5825;

  /// City-level zoom that provides a useful Kampala overview.
  static const double defaultZoom = 13.0;

  /// Country-level zoom for Uganda overview.
  static const double ugandaOverviewZoom = 7.0;

  /// Minimum zoom level.
  static const double minZoom = 4.0;

  /// Maximum zoom level.
  static const double maxZoom = 18.0;

  /// Zoom for a neighbourhood-level view.
  static const double neighbourhoodZoom = 15.0;

  // ─── Tile layer settings ──────────────────────────────────────────────────

  /// Tile size in pixels (standard is 256).
  static const int tileSize = 256;

  /// Maximum number of tiles to keep in the memory cache.
  static const int maxTileCacheSize = 150;

  /// Whether to keep tiles visible while loading new ones (reduces flicker).
  static const bool keepBuffer = true;
}
