import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../features/map/domain/map_location.dart';

/// Wraps the Geolocator package with platform-safe error handling.
///
/// Design principles:
/// - Never requests permission automatically on startup.
/// - Only requests permission when a user explicitly triggers a location action.
/// - Handles all permission and service failure states gracefully.
/// - Web: uses browser geolocation in secure contexts only.
/// - Android: requires INTERNET + ACCESS_FINE_LOCATION in AndroidManifest.xml.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  // ─── Permission handling ──────────────────────────────────────────────────

  /// Checks the current permission state without requesting it.
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }
      final permission = await Geolocator.checkPermission();
      return _mapPermission(permission);
    } catch (e) {
      return LocationPermissionStatus.unavailable;
    }
  }

  /// Requests location permission from the user.
  /// Must only be called after the user has explicitly initiated a
  /// location-dependent action and been shown an explanation.
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return _mapPermission(permission);
    } catch (e) {
      return LocationPermissionStatus.unavailable;
    }
  }

  // ─── Position retrieval ───────────────────────────────────────────────────

  /// Returns the current device position.
  ///
  /// Returns null on any failure — callers must handle null gracefully.
  /// Only call after confirming permission is [LocationPermissionStatus.granted].
  Future<LatLng?> getCurrentPosition() async {
    try {
      // Web has limited geolocation support; wrap in a timeout.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } on TimeoutException {
      debugPrint('LocationService: Position request timed out.');
      return null;
    } catch (e) {
      debugPrint('LocationService: Failed to get position — $e');
      return null;
    }
  }

  /// Returns the last known position without triggering a fresh fix.
  /// Faster and less battery-intensive; may return null or a stale position.
  Future<LatLng?> getLastKnownPosition() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  LocationPermissionStatus _mapPermission(LocationPermission p) {
    return switch (p) {
      LocationPermission.always ||
      LocationPermission.whileInUse =>
        LocationPermissionStatus.granted,
      LocationPermission.denied => LocationPermissionStatus.denied,
      LocationPermission.deniedForever =>
        LocationPermissionStatus.permanentlyDenied,
      LocationPermission.unableToDetermine =>
        LocationPermissionStatus.unavailable,
    };
  }

  /// Opens the device location settings screen on Android/iOS.
  /// Not supported on Web — returns false.
  Future<bool> openLocationSettings() async {
    if (kIsWeb) return false;
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      return false;
    }
  }

  /// Opens the app settings screen on Android/iOS.
  /// Not supported on Web — returns false.
  Future<bool> openAppSettings() async {
    if (kIsWeb) return false;
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      return false;
    }
  }
}
