import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/map_config.dart';
import '../../../core/services/service_interfaces.dart';
import '../domain/map_location.dart';
import 'map_repository.dart';

/// Real geocoding implementation backed by the Photon API (photon.komoot.io).
///
/// Photon is an open-source geocoder built on OpenStreetMap data.
/// The komoot-hosted public instance is free to use within reasonable limits.
///
/// Usage rules followed here:
/// - Queries are debounced in the UI layer (see [MapConfig.geocodingDebounceMs]).
/// - Requests include a descriptive User-Agent header.
/// - Results are biased to Uganda via the bbox parameter.
/// - No per-keystroke requests reach this class — debouncing is enforced by
///   the caller ([LocationSearchField]).
///
/// Replace this implementation with [LocalPresetGeocodingRepository] when
/// running offline, or subclass [GeocodingRepository] for a different provider
/// (e.g. MapTiler) without changing any calling code.
class PhotonGeocodingRepository implements GeocodingRepository {
  PhotonGeocodingRepository({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  final http.Client _client;

  // Keeps a reference to the in-flight search request so it can be aborted
  // when a newer query arrives before the previous one completes.
  CancelableOperation<List<MapLocation>>? _pendingSearch;

  static const Duration _requestTimeout = Duration(seconds: 10);

  static const Map<String, String> _headers = {
    'User-Agent': MapConfig.tileUserAgent,
    'Accept': 'application/json',
  };

  // ─── GeocodingRepository implementation ──────────────────────────────────

  /// Searches for Ugandan locations matching [query] using the Photon API.
  ///
  /// Returns up to [MapConfig.geocodingSuggestionLimit] results biased to
  /// Uganda. Returns an empty list on network error or no results.
  ///
  /// Throws [GeocodingException] only for non-recoverable configuration errors.
  @override
  Future<List<MapLocation>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    // Cancel any pending operation before starting a new one.
    _pendingSearch?.cancel();

    final operation = CancelableOperation<List<MapLocation>>.fromFuture(
      _doSearch(q),
    );
    _pendingSearch = operation;

    try {
      return await operation.valueOrCancellation ?? [];
    } catch (e) {
      srLog('Photon', 'Search error: $e');
      return [];
    }
  }

  Future<List<MapLocation>> _doSearch(String query) async {
    final uri = Uri.parse(MapConfig.photonBaseUrl).replace(
      path: '/api/',
      queryParameters: {
        'q': query,
        'lang': 'en',
        'limit': MapConfig.geocodingSuggestionLimit.toString(),
        'bbox': MapConfig.ugandaBbox,
      },
    );

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        srLog('Photon', 'HTTP ${response.statusCode} for query "$query"');
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = (data['features'] as List?)?.cast<Map<String, dynamic>>();
      if (features == null || features.isEmpty) return [];

      return features
          .map(_featureToMapLocation)
          .whereType<MapLocation>()
          .toList();
    } on TimeoutException {
      srLog('Photon', 'Search timed out for query "$query"');
      return [];
    } on FormatException catch (e) {
      srLog('Photon', 'JSON parse error: $e');
      return [];
    } catch (e) {
      srLog('Photon', 'Network error: $e');
      return [];
    }
  }

  /// Reverse-geocodes a coordinate using the Nominatim /reverse endpoint.
  ///
  /// Nominatim must only be called once per user-triggered action (not in a
  /// loop or per-keystroke). This method is intentionally rate-limited to
  /// single-call usage by its callers.
  @override
  Future<MapLocation?> reverse(double latitude, double longitude) async {
    final uri = Uri.parse(MapConfig.nominatimBaseUrl).replace(
      path: '/reverse',
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'format': 'jsonv2',
        'zoom': '16',
        'addressdetails': '1',
      },
    );

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        srLog('Nominatim', 'Reverse geocode HTTP ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final displayName = data['display_name'] as String?;
      final address = data['address'] as Map<String, dynamic>?;

      if (displayName == null) return null;

      // Build a concise human-readable label from the address components.
      final label = _buildReverseLabel(address, displayName);

      return MapLocation(
        name: label,
        latitude: latitude,
        longitude: longitude,
        category: MapLocationCategory.custom,
      );
    } on TimeoutException {
      srLog('Nominatim', 'Reverse geocode timed out');
      return null;
    } catch (e) {
      srLog('Nominatim', 'Reverse geocode error: $e');
      return null;
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  MapLocation? _featureToMapLocation(Map<String, dynamic> feature) {
    try {
      final props = feature['properties'] as Map<String, dynamic>?;
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      if (props == null || geometry == null) return null;

      final coords = (geometry['coordinates'] as List?)?.cast<num>();
      if (coords == null || coords.length < 2) return null;

      final lng = coords[0].toDouble();
      final lat = coords[1].toDouble();

      final name = props['name'] as String?;
      if (name == null || name.isEmpty) return null;

      final description = _buildDescription(props);

      return MapLocation(
        name: name,
        latitude: lat,
        longitude: lng,
        description: description,
        category: _inferCategory(props),
      );
    } catch (_) {
      return null;
    }
  }

  String _buildDescription(Map<String, dynamic> props) {
    final parts = <String>[];
    final street = props['street'] as String?;
    final locality = props['locality'] as String?;
    final district = props['district'] as String?;
    final city = props['city'] as String?;
    final state = props['state'] as String?;

    if (street != null) parts.add(street);
    if (locality != null && locality != (props['name'] as String?)) {
      parts.add(locality);
    }
    if (district != null) parts.add(district);
    if (city != null) parts.add(city);
    if (state != null) parts.add(state);
    parts.add('Uganda');

    return parts.take(3).join(', ');
  }

  MapLocationCategory _inferCategory(Map<String, dynamic> props) {
    final osmValue = props['osm_value'] as String?;
    final type = props['type'] as String?;
    if (type == 'city' || osmValue == 'city' || osmValue == 'town') {
      return MapLocationCategory.city;
    }
    if (osmValue == 'neighbourhood' || osmValue == 'suburb' || type == 'district') {
      return MapLocationCategory.neighbourhood;
    }
    return MapLocationCategory.custom;
  }

  String _buildReverseLabel(Map<String, dynamic>? address, String fallback) {
    if (address == null) return _shortenDisplayName(fallback);
    final road = address['road'] as String?;
    final suburb = address['suburb'] as String?;
    final neighbourhood = address['neighbourhood'] as String?;
    final city = address['city'] as String?;
    final parts = <String>[];
    if (road != null) parts.add(road);
    if ((neighbourhood ?? suburb) != null) parts.add(neighbourhood ?? suburb!);
    if (city != null) parts.add(city);
    if (parts.isNotEmpty) return parts.join(', ');
    return _shortenDisplayName(fallback);
  }

  String _shortenDisplayName(String displayName) {
    // Nominatim display_name is very long — trim to first 3 comma-parts.
    final parts = displayName.split(',');
    return parts.take(3).map((s) => s.trim()).join(', ');
  }
}

// ─── Cancelable operation ─────────────────────────────────────────────────────

/// Minimal cancelable future wrapper — avoids the async package dependency.
class CancelableOperation<T> {
  CancelableOperation.fromFuture(Future<T> future) {
    _future = future;
  }

  late final Future<T> _future;
  bool _cancelled = false;

  void cancel() {
    _cancelled = true;
  }

  Future<T?> get valueOrCancellation => _future.then((value) {
        if (_cancelled) return null;
        return value;
      });
}

/// Thrown by geocoding services on non-recoverable errors.
class GeocodingException implements Exception {
  const GeocodingException(this.message);
  final String message;

  @override
  String toString() => 'GeocodingException: $message';
}
