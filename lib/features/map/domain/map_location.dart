import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

// ─── Location category ────────────────────────────────────────────────────────

enum MapLocationCategory {
  custom,
  city,
  neighbourhood,
  savedPlace,
  currentPosition,
  origin,
  destination,
  roadReport,
  trafficIncident,
  preset,
}

// ─── Map location ─────────────────────────────────────────────────────────────

/// A typed geographic location used throughout the map feature.
/// Validates coordinate ranges on construction.
class MapLocation extends Equatable {
  const MapLocation._({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
    this.category = MapLocationCategory.custom,
    this.id,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String? description;
  final MapLocationCategory category;
  final String? id;

  /// Creates a validated [MapLocation].
  /// Throws [ArgumentError] if coordinates are out of valid range.
  factory MapLocation({
    required String name,
    required double latitude,
    required double longitude,
    String? description,
    MapLocationCategory category = MapLocationCategory.custom,
    String? id,
  }) {
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError(
        'Latitude must be between -90 and 90. Got: $latitude',
      );
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError(
        'Longitude must be between -180 and 180. Got: $longitude',
      );
    }
    return MapLocation._(
      name: name,
      latitude: latitude,
      longitude: longitude,
      description: description,
      category: category,
      id: id,
    );
  }

  /// Converts to a [LatLng] for use with flutter_map.
  LatLng get latLng => LatLng(latitude, longitude);

  MapLocation copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? description,
    MapLocationCategory? category,
    String? id,
  }) {
    return MapLocation(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      category: category ?? this.category,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, name, id];
}

// ─── Map marker model ─────────────────────────────────────────────────────────

enum MapMarkerType {
  currentPosition,
  origin,
  destination,
  pothole,
  flooding,
  accident,
  roadworks,
  closure,
  congestion,
  hazard,
  savedPlace,
  preset,
}

/// A typed map marker, combining a location with display and interaction data.
class MapMarkerModel extends Equatable {
  const MapMarkerModel({
    required this.id,
    required this.location,
    required this.type,
    this.title,
    this.subtitle,
    this.isDemo = false,
    this.payload,
  });

  final String id;
  final MapLocation location;
  final MapMarkerType type;
  final String? title;
  final String? subtitle;
  final bool isDemo;

  /// Optional payload — e.g. a RoadReport ID or PlaceModel ID for tap handling.
  final String? payload;

  @override
  List<Object?> get props => [id, type, location];
}

// ─── Route geometry ───────────────────────────────────────────────────────────

/// The visual geometry for a route displayed on the map.
///
/// Any geometry NOT from a real routing provider must be flagged as
/// [isIllustrative] = true so the UI can label it clearly.
class MapRouteGeometry extends Equatable {
  const MapRouteGeometry({
    required this.id,
    required this.points,
    required this.isSelected,
    this.isIllustrative = true,
    this.label,
  });

  final String id;
  final List<LatLng> points;
  final bool isSelected;

  /// True when the geometry was created manually / for demonstration purposes
  /// and does NOT represent a real routing calculation.
  final bool isIllustrative;
  final String? label;

  @override
  List<Object?> get props => [id, isSelected];
}

// ─── Location permission state ────────────────────────────────────────────────

enum LocationPermissionStatus {
  initial,
  checking,
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
  unavailable,
}

// ─── Map preset ───────────────────────────────────────────────────────────────

/// A named map navigation preset for the location selector.
class MapPreset extends Equatable {
  const MapPreset({
    required this.id,
    required this.name,
    required this.location,
    required this.zoom,
    this.region,
  });

  final String id;
  final String name;
  final MapLocation location;
  final double zoom;
  final String? region;

  @override
  List<Object?> get props => [id];
}
