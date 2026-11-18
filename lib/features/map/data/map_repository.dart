import '../domain/map_location.dart';
import '../../../core/config/map_config.dart';

/// Interface for geocoding lookups.
///
/// In the current demo build, a local preset-based implementation is used.
/// Replace with a real geocoding service (e.g. Nominatim, MapTiler Geocoding)
/// for production — after reviewing the service's usage policy and rate limits.
abstract class GeocodingRepository {
  /// Search for locations matching [query].
  /// Returns a list of [MapLocation] candidates.
  Future<List<MapLocation>> search(String query);

  /// Reverse-geocode a coordinate to a human-readable address.
  Future<MapLocation?> reverse(double latitude, double longitude);
}

/// Demo implementation that returns results from the local preset list only.
/// Clearly labelled — does not perform real network geocoding.
class LocalPresetGeocodingRepository implements GeocodingRepository {
  const LocalPresetGeocodingRepository();

  @override
  Future<List<MapLocation>> search(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    return MapPresets.all
        .where(
          (p) =>
              p.location.name.toLowerCase().contains(q) ||
              (p.region?.toLowerCase().contains(q) ?? false),
        )
        .map((p) => p.location)
        .toList();
  }

  @override
  Future<MapLocation?> reverse(double latitude, double longitude) async {
    // Find the closest preset as a fallback label.
    MapPreset? closest;
    double minDist = double.infinity;
    for (final preset in MapPresets.all) {
      final dLat = preset.location.latitude - latitude;
      final dLng = preset.location.longitude - longitude;
      final dist = dLat * dLat + dLng * dLng;
      if (dist < minDist) {
        minDist = dist;
        closest = preset;
      }
    }
    if (closest != null) {
      return MapLocation(
        name: '${closest.location.name} area (approximate)',
        latitude: latitude,
        longitude: longitude,
        category: MapLocationCategory.custom,
      );
    }
    return MapLocation(
      name: 'Selected location',
      latitude: latitude,
      longitude: longitude,
      category: MapLocationCategory.custom,
    );
  }
}

// ─── Map presets ──────────────────────────────────────────────────────────────

/// Named map navigation presets for Kampala and Uganda.
/// Coordinates are approximate and used for map navigation only.
/// These are NOT claims about live road conditions at these locations.
abstract class MapPresets {
  static final MapPreset kampala = MapPreset(
    id: 'kampala',
    name: 'Kampala Central',
    location: MapLocation(
      name: 'Kampala Central',
      latitude: MapConfig.defaultLatitude,
      longitude: MapConfig.defaultLongitude,
      category: MapLocationCategory.city,
    ),
    zoom: MapConfig.defaultZoom,
    region: 'Kampala',
  );

  static final MapPreset ntinda = MapPreset(
    id: 'ntinda',
    name: 'Ntinda',
    location: MapLocation(
      name: 'Ntinda',
      latitude: 0.3620,
      longitude: 32.6180,
      category: MapLocationCategory.neighbourhood,
    ),
    zoom: MapConfig.neighbourhoodZoom,
    region: 'Kampala',
  );

  static final MapPreset nakawa = MapPreset(
    id: 'nakawa',
    name: 'Nakawa',
    location: MapLocation(
      name: 'Nakawa',
      latitude: 0.3374,
      longitude: 32.6200,
      category: MapLocationCategory.neighbourhood,
    ),
    zoom: MapConfig.neighbourhoodZoom,
    region: 'Kampala',
  );

  static final MapPreset kireka = MapPreset(
    id: 'kireka',
    name: 'Kireka',
    location: MapLocation(
      name: 'Kireka',
      latitude: 0.3584,
      longitude: 32.6512,
      category: MapLocationCategory.neighbourhood,
    ),
    zoom: MapConfig.neighbourhoodZoom,
    region: 'Kampala',
  );

  static final MapPreset banda = MapPreset(
    id: 'banda',
    name: 'Banda',
    location: MapLocation(
      name: 'Banda',
      latitude: 0.3521,
      longitude: 32.6350,
      category: MapLocationCategory.neighbourhood,
    ),
    zoom: MapConfig.neighbourhoodZoom,
    region: 'Kampala',
  );

  static final MapPreset bweyogerere = MapPreset(
    id: 'bweyogerere',
    name: 'Bweyogerere',
    location: MapLocation(
      name: 'Bweyogerere',
      latitude: 0.3740,
      longitude: 32.6850,
      category: MapLocationCategory.neighbourhood,
    ),
    zoom: MapConfig.neighbourhoodZoom,
    region: 'Kampala',
  );

  static final MapPreset kyambogo = MapPreset(
    id: 'kyambogo',
    name: 'Kyambogo',
    location: MapLocation(
      name: 'Kyambogo',
      latitude: 0.3445,
      longitude: 32.6414,
      category: MapLocationCategory.neighbourhood,
    ),
    zoom: MapConfig.neighbourhoodZoom,
    region: 'Kampala',
  );

  static final MapPreset entebbe = MapPreset(
    id: 'entebbe',
    name: 'Entebbe',
    location: MapLocation(
      name: 'Entebbe',
      latitude: 0.0612,
      longitude: 32.4628,
      category: MapLocationCategory.city,
    ),
    zoom: MapConfig.defaultZoom,
    region: 'Central Uganda',
  );

  static final MapPreset jinja = MapPreset(
    id: 'jinja',
    name: 'Jinja',
    location: MapLocation(
      name: 'Jinja',
      latitude: 0.4244,
      longitude: 33.2041,
      category: MapLocationCategory.city,
    ),
    zoom: MapConfig.defaultZoom,
    region: 'Eastern Uganda',
  );

  static final MapPreset mukono = MapPreset(
    id: 'mukono',
    name: 'Mukono',
    location: MapLocation(
      name: 'Mukono',
      latitude: 0.3534,
      longitude: 32.7542,
      category: MapLocationCategory.city,
    ),
    zoom: MapConfig.defaultZoom,
    region: 'Central Uganda',
  );

  static final MapPreset mbarara = MapPreset(
    id: 'mbarara',
    name: 'Mbarara',
    location: MapLocation(
      name: 'Mbarara',
      latitude: -0.6144,
      longitude: 30.6547,
      category: MapLocationCategory.city,
    ),
    zoom: MapConfig.defaultZoom,
    region: 'Western Uganda',
  );

  static final MapPreset gulu = MapPreset(
    id: 'gulu',
    name: 'Gulu',
    location: MapLocation(
      name: 'Gulu',
      latitude: 2.7748,
      longitude: 32.2990,
      category: MapLocationCategory.city,
    ),
    zoom: MapConfig.defaultZoom,
    region: 'Northern Uganda',
  );

  static final MapPreset arua = MapPreset(
    id: 'arua',
    name: 'Arua',
    location: MapLocation(
      name: 'Arua',
      latitude: 3.0281,
      longitude: 30.9124,
      category: MapLocationCategory.city,
    ),
    zoom: MapConfig.defaultZoom,
    region: 'Northern Uganda',
  );

  static final MapPreset ugandaOverview = MapPreset(
    id: 'uganda_overview',
    name: 'Uganda Overview',
    location: MapLocation(
      name: 'Uganda',
      latitude: 1.3733,
      longitude: 32.2903,
      category: MapLocationCategory.city,
    ),
    zoom: MapConfig.ugandaOverviewZoom,
    region: 'Uganda',
  );

  /// All available presets grouped for the UI selector.
  static List<MapPreset> get all => [
        kampala,
        ntinda,
        nakawa,
        kireka,
        banda,
        bweyogerere,
        kyambogo,
        entebbe,
        jinja,
        mukono,
        mbarara,
        gulu,
        arua,
        ugandaOverview,
      ];

  /// Kampala-area presets for compact selectors.
  static List<MapPreset> get kampalaArea => [
        kampala,
        ntinda,
        nakawa,
        kireka,
        banda,
        bweyogerere,
        kyambogo,
      ];
}
