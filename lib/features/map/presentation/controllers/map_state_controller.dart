import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/config/map_config.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/models/app_models.dart';
import '../../data/map_repository.dart';
import '../../data/photon_geocoding_repository.dart';
import '../../domain/map_location.dart';

/// Central state controller for the SmartRoute map experience.
///
/// Manages:
/// - Current map camera position.
/// - Device location permission and position.
/// - Active markers.
/// - Route geometry overlays.
/// - Layer visibility toggles.
/// - Location preset selection.
class MapStateController extends ChangeNotifier {
  /// Creates the controller with the appropriate geocoding backend.
  ///
  /// Uses [PhotonGeocodingRepository] by default (real Ugandan place search).
  /// Callers may inject a different [GeocodingRepository] — e.g. for tests
  /// or to force the preset-only demo implementation.
  MapStateController({GeocodingRepository? geocodingRepository}) {
    _geocoding = geocodingRepository ?? PhotonGeocodingRepository();
  }

  // ─── Map controller ───────────────────────────────────────────────────────

  /// The flutter_map [MapController] for programmatic camera moves.
  final MapController mapController = MapController();

  // ─── Camera ───────────────────────────────────────────────────────────────

  LatLng _center = LatLng(MapConfig.defaultLatitude, MapConfig.defaultLongitude);
  double _zoom = MapConfig.defaultZoom;
  MapPreset? _activePreset;

  LatLng get center => _center;
  double get zoom => _zoom;
  MapPreset? get activePreset => _activePreset;

  // ─── Location ─────────────────────────────────────────────────────────────

  LocationPermissionStatus _permissionStatus =
      LocationPermissionStatus.initial;
  LatLng? _currentPosition;
  bool _isLocating = false;
  String? _locationError;

  LocationPermissionStatus get permissionStatus => _permissionStatus;
  LatLng? get currentPosition => _currentPosition;
  bool get isLocating => _isLocating;
  String? get locationError => _locationError;
  bool get hasCurrentPosition => _currentPosition != null;

  // ─── Markers ──────────────────────────────────────────────────────────────

  final List<MapMarkerModel> _markers = [];
  bool _showReportMarkers = true;
  bool _showRouteMarkers = true;
  MapMarkerModel? _selectedMarker;

  List<MapMarkerModel> get markers => List.unmodifiable(_markers);
  bool get showReportMarkers => _showReportMarkers;
  bool get showRouteMarkers => _showRouteMarkers;
  MapMarkerModel? get selectedMarker => _selectedMarker;

  List<MapMarkerModel> get visibleMarkers {
    return _markers.where((m) {
      if (!_showReportMarkers &&
          _isReportType(m.type)) {
        return false;
      }
      if (!_showRouteMarkers &&
          (m.type == MapMarkerType.origin ||
              m.type == MapMarkerType.destination)) {
        return false;
      }
      return true;
    }).toList();
  }

  bool _isReportType(MapMarkerType t) {
    return t == MapMarkerType.pothole ||
        t == MapMarkerType.flooding ||
        t == MapMarkerType.accident ||
        t == MapMarkerType.roadworks ||
        t == MapMarkerType.closure ||
        t == MapMarkerType.congestion ||
        t == MapMarkerType.hazard;
  }

  // ─── Route geometry ───────────────────────────────────────────────────────

  final List<MapRouteGeometry> _routeGeometries = [];
  bool _showRouteOverlay = true;

  List<MapRouteGeometry> get routeGeometries =>
      List.unmodifiable(_routeGeometries);
  bool get showRouteOverlay => _showRouteOverlay;

  // ─── Geocoding ────────────────────────────────────────────────────────────

  late final GeocodingRepository _geocoding;

  List<MapLocation> _searchResults = [];
  bool _isSearching = false;
  String? _geocodingError;

  List<MapLocation> get searchResults => List.unmodifiable(_searchResults);
  bool get isSearching => _isSearching;
  String? get geocodingError => _geocodingError;

  /// True when using the real Photon geocoding backend.
  bool get isUsingRealGeocoding => _geocoding is PhotonGeocodingRepository;

  // ─── Camera control ───────────────────────────────────────────────────────

  /// Move the map camera to a specific position with optional zoom.
  void moveCamera(LatLng position, {double? zoom}) {
    _center = position;
    _zoom = zoom ?? _zoom;
    try {
      mapController.move(position, _zoom);
    } catch (_) {
      // MapController may not be ready if called before the map is mounted.
    }
    notifyListeners();
  }

  /// Fly to a named preset location.
  void flyToPreset(MapPreset preset) {
    _activePreset = preset;
    moveCamera(preset.location.latLng, zoom: preset.zoom);
  }

  /// Reset the map to the default Kampala view.
  void resetToDefault() {
    flyToPreset(MapPresets.kampala);
  }

  /// Zoom in by one level.
  void zoomIn() {
    final newZoom = (_zoom + 1).clamp(MapConfig.minZoom, MapConfig.maxZoom);
    moveCamera(_center, zoom: newZoom);
  }

  /// Zoom out by one level.
  void zoomOut() {
    final newZoom = (_zoom - 1).clamp(MapConfig.minZoom, MapConfig.maxZoom);
    moveCamera(_center, zoom: newZoom);
  }

  /// Called by the map widget when the user pans/zooms manually.
  void onCameraMove(MapCamera camera) {
    _center = camera.center;
    _zoom = camera.zoom;
    // Don't call notifyListeners() here — too frequent, causes rebuild loops.
  }

  // ─── Location ─────────────────────────────────────────────────────────────

  /// Checks permission without requesting. Safe to call on init.
  Future<void> checkLocationPermission() async {
    _permissionStatus = await LocationService.instance.checkPermission();
    notifyListeners();
  }

  /// Requests location permission then retrieves the current position.
  /// Only call in response to a deliberate user action.
  Future<void> locateMe() async {
    _isLocating = true;
    _locationError = null;
    notifyListeners();

    final status = await LocationService.instance.requestPermission();
    _permissionStatus = status;

    if (status != LocationPermissionStatus.granted) {
      _isLocating = false;
      _locationError = switch (status) {
        LocationPermissionStatus.denied =>
          'Location permission denied. You can still explore the map manually.',
        LocationPermissionStatus.permanentlyDenied =>
          'Location permission permanently denied. Enable it in app settings.',
        LocationPermissionStatus.serviceDisabled =>
          'Location services are disabled on your device.',
        _ => 'Location is not available.',
      };
      notifyListeners();
      return;
    }

    // Try last known position first (faster, lower battery).
    var position = await LocationService.instance.getLastKnownPosition();
    position ??= await LocationService.instance.getCurrentPosition();

    _isLocating = false;

    if (position != null) {
      _currentPosition = position;
      _updateOrAddCurrentPositionMarker(position);
      moveCamera(position, zoom: MapConfig.neighbourhoodZoom);
    } else {
      _locationError = 'Could not determine your position. Try again.';
    }

    notifyListeners();
  }

  void _updateOrAddCurrentPositionMarker(LatLng position) {
    _markers.removeWhere((m) => m.type == MapMarkerType.currentPosition);
    _markers.add(
      MapMarkerModel(
        id: 'current_position',
        location: MapLocation(
          name: 'Your location',
          latitude: position.latitude,
          longitude: position.longitude,
          category: MapLocationCategory.currentPosition,
        ),
        type: MapMarkerType.currentPosition,
        title: 'Your location',
      ),
    );
  }

  /// Centres the map on the current position without re-requesting permission.
  void reCentreOnPosition() {
    if (_currentPosition != null) {
      moveCamera(_currentPosition!, zoom: MapConfig.neighbourhoodZoom);
    }
  }

  /// Clears the location error message.
  void clearLocationError() {
    _locationError = null;
    notifyListeners();
  }

  // ─── Markers ──────────────────────────────────────────────────────────────

  /// Loads road-report markers from a list of [RoadReport] objects.
  void loadReportMarkers(List<RoadReport> reports) {
    _markers.removeWhere((m) => _isReportType(m.type));
    for (final report in reports) {
      _markers.add(_reportToMarker(report));
    }
    notifyListeners();
  }

  MapMarkerModel _reportToMarker(RoadReport report) {
    final type = switch (report.category) {
      ReportCategory.pothole => MapMarkerType.pothole,
      ReportCategory.flooding => MapMarkerType.flooding,
      ReportCategory.accident => MapMarkerType.accident,
      ReportCategory.roadworks => MapMarkerType.roadworks,
      ReportCategory.closure => MapMarkerType.closure,
      ReportCategory.heavyCongestion => MapMarkerType.congestion,
      ReportCategory.dangerousCondition => MapMarkerType.hazard,
      ReportCategory.otherHazard => MapMarkerType.hazard,
    };
    return MapMarkerModel(
      id: report.id,
      location: MapLocation(
        name: report.locationName,
        latitude: report.latitude,
        longitude: report.longitude,
        category: MapLocationCategory.roadReport,
        id: report.id,
      ),
      type: type,
      title: _reportCategoryLabel(report.category),
      subtitle: report.locationName,
      isDemo: true,
      payload: report.id,
    );
  }

  String _reportCategoryLabel(ReportCategory c) => switch (c) {
        ReportCategory.pothole => 'Pothole',
        ReportCategory.flooding => 'Flooding',
        ReportCategory.accident => 'Accident / Breakdown',
        ReportCategory.roadworks => 'Roadworks',
        ReportCategory.closure => 'Road Closure',
        ReportCategory.heavyCongestion => 'Heavy Congestion',
        ReportCategory.dangerousCondition => 'Dangerous Condition',
        ReportCategory.otherHazard => 'Hazard',
      };

  /// Sets the origin marker.
  void setOriginMarker(MapLocation location) {
    _markers.removeWhere((m) => m.type == MapMarkerType.origin);
    _markers.add(
      MapMarkerModel(
        id: 'origin',
        location: location,
        type: MapMarkerType.origin,
        title: location.name,
        subtitle: 'Starting point',
      ),
    );
    notifyListeners();
  }

  /// Sets the destination marker.
  void setDestinationMarker(MapLocation location) {
    _markers.removeWhere((m) => m.type == MapMarkerType.destination);
    _markers.add(
      MapMarkerModel(
        id: 'destination',
        location: location,
        type: MapMarkerType.destination,
        title: location.name,
        subtitle: 'Destination',
      ),
    );
    notifyListeners();
  }

  void clearRouteMarkers() {
    _markers.removeWhere(
      (m) =>
          m.type == MapMarkerType.origin ||
          m.type == MapMarkerType.destination,
    );
    notifyListeners();
  }

  /// Selects a marker (opens its info panel).
  void selectMarker(MapMarkerModel? marker) {
    _selectedMarker = marker;
    notifyListeners();
  }

  void toggleReportMarkers() {
    _showReportMarkers = !_showReportMarkers;
    notifyListeners();
  }

  void toggleRouteMarkers() {
    _showRouteMarkers = !_showRouteMarkers;
    notifyListeners();
  }

  // ─── Route geometry ───────────────────────────────────────────────────────

  /// Loads route geometry for display.
  /// All illustrative geometries must have [MapRouteGeometry.isIllustrative] = true.
  void loadRouteGeometries(List<MapRouteGeometry> geometries) {
    _routeGeometries
      ..clear()
      ..addAll(geometries);
    notifyListeners();
  }

  void clearRouteGeometries() {
    _routeGeometries.clear();
    notifyListeners();
  }

  void toggleRouteOverlay() {
    _showRouteOverlay = !_showRouteOverlay;
    notifyListeners();
  }

  // ─── Geocoding ────────────────────────────────────────────────────────────

  Future<void> searchLocations(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _geocodingError = null;
      notifyListeners();
      return;
    }
    _isSearching = true;
    _geocodingError = null;
    notifyListeners();
    try {
      _searchResults = await _geocoding.search(query);
      if (_searchResults.isEmpty) {
        _geocodingError = null; // Empty is a valid result, not an error.
      }
    } catch (e) {
      _searchResults = [];
      _geocodingError = 'Location search unavailable. Check your connection.';
    }
    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _isSearching = false;
    _geocodingError = null;
    notifyListeners();
  }

  /// Reverse-geocodes [latitude]/[longitude] to a human-readable name.
  /// Uses the geocoding repository's reverse endpoint (Nominatim, one call
  /// per user action — compliant with usage policy).
  /// Returns null on any failure; callers must handle gracefully.
  Future<MapLocation?> reverseGeocode(double latitude, double longitude) {
    return _geocoding.reverse(latitude, longitude);
  }

  // ─── Illustrative route builder ───────────────────────────────────────────

  /// Builds illustrative (demonstration) route geometries from the existing
  /// route options. These are NOT real routing calculations.
  /// Loads route geometries from a list of [RouteOption] results.
  ///
  /// Routes with [RouteOption.isFromRealRouting] = true are displayed as real
  /// road geometry ([MapRouteGeometry.isIllustrative] = false).
  /// Demo routes are always marked illustrative, regardless of waypoint count.
  void loadRoutesFromOptions(List<RouteOption> routes) {
    final geometries = <MapRouteGeometry>[];
    for (final route in routes) {
      if (route.waypoints.isEmpty) continue;
      final points = route.waypoints
          .map((wp) => LatLng(wp[0], wp[1]))
          .toList();
      geometries.add(
        MapRouteGeometry(
          id: route.id,
          points: points,
          isSelected: route.isRecommended,
          isIllustrative: !route.isFromRealRouting,
          label: route.name,
        ),
      );
    }
    loadRouteGeometries(geometries);
  }

  /// Preserved for backward compatibility — always marks geometries illustrative.
  void loadIllustrativeRoutes(List<RouteOption> routes) {
    final geometries = <MapRouteGeometry>[];
    for (final route in routes) {
      if (route.waypoints.isEmpty) continue;
      final points = route.waypoints
          .map((wp) => LatLng(wp[0], wp[1]))
          .toList();
      geometries.add(
        MapRouteGeometry(
          id: route.id,
          points: points,
          isSelected: route.isRecommended,
          isIllustrative: true,
          label: route.name,
        ),
      );
    }
    loadRouteGeometries(geometries);
  }

  /// Fits the map camera to show the full route defined by [waypoints].
  /// Each waypoint is a [lat, lng] pair. Does nothing if fewer than 2 points.
  /// Safe to call before the map is mounted — catches controller errors.
  void fitRouteGeometry(List<List<double>> waypoints) {
    if (waypoints.length < 2) return;
    try {
      final points = waypoints.map((wp) => LatLng(wp[0], wp[1])).toList();
      final bounds = LatLngBounds.fromPoints(points);
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(48),
        ),
      );
    } catch (_) {
      // MapController not yet ready — ignore silently.
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
