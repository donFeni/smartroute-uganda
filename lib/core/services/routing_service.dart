import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../config/environment.dart';
import '../services/service_interfaces.dart';
import '../../shared/models/app_models.dart';
import '../../shared/models/demo_data.dart';

/// Selects the appropriate routing implementation based on available credentials.
///
/// Returns [ORSRoutingService] when [AppEnvironment.orsApiKey] is configured,
/// otherwise falls back to [DemoRoutingService].
RoutingService createRoutingService() {
  if (AppEnvironment.isRoutingConfigured) {
    srLog('Routing', 'Using OpenRouteService (real routing)');
    return ORSRoutingService(apiKey: AppEnvironment.orsApiKey);
  }
  srLog('Routing', 'Using demo routing service (no ORS API key configured)');
  return DemoRoutingService();
}

// ─── Demo routing service ─────────────────────────────────────────────────────

/// Returns pre-built sample routes for demonstration purposes.
/// Does NOT perform real routing calculations.
class DemoRoutingService implements RoutingService {
  @override
  bool get isRealRouting => false;

  @override
  Future<List<RouteOption>> fetchRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    double fuelPriceUgx = 5600,
    double consumptionPer100km = 8.5,
  }) async {
    // Simulate network delay.
    await Future.delayed(const Duration(milliseconds: 1200));

    // Estimate a rough distance based on coordinates for slightly more
    // realistic values in the demo data.
    final dist = const Distance().as(
      LengthUnit.Kilometer,
      LatLng(originLat, originLng),
      LatLng(destLat, destLng),
    );
    final baseKm = dist > 0 ? dist : 12.0;

    return DemoData.sampleRoutes(
      distanceBase: baseKm,
      fuelPriceUgx: fuelPriceUgx,
      consumptionPer100km: consumptionPer100km,
    );
  }
}

// ─── OpenRouteService routing ─────────────────────────────────────────────────

/// Fetches real route options from OpenRouteService (ORS).
///
/// API documentation: https://openrouteservice.org/dev/#/api-docs
///
/// Free tier: 2,000 requests/day, up to 3 alternative routes per request.
/// Requires a free account and API key from https://openrouteservice.org
///
/// Profile used: `driving-car` — appropriate for Uganda's road network.
class ORSRoutingService implements RoutingService {
  ORSRoutingService({required this.apiKey});

  final String apiKey;

  static const String _baseUrl = AppEnvironment.orsBaseUrl;
  static const String _profile = 'driving-car';

  @override
  bool get isRealRouting => true;

  @override
  Future<List<RouteOption>> fetchRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    double fuelPriceUgx = 5600,
    double consumptionPer100km = 8.5,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/v2/directions/$_profile/json');

      final body = jsonEncode({
        'coordinates': [
          [originLng, originLat],
          [destLng, destLat],
        ],
        'alternative_routes': {
          'target_count': 3,
          'weight_factor': 1.6,
          'share_factor': 0.6,
        },
        'units': 'km',
        'instructions': false,
        'geometry': true,
      });

      final response = await http.post(
        uri,
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json, application/geo+json',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        srLog('ORS', 'Request failed: ${response.statusCode} ${response.body}');
        throw RoutingException(
          'Routing service returned ${response.statusCode}. '
          'Showing sample routes as fallback.',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseRoutes(data, fuelPriceUgx, consumptionPer100km);
    } on RoutingException {
      rethrow;
    } catch (e) {
      srLog('ORS', 'Error: $e');
      throw RoutingException(
        'Could not reach the routing service. '
        'Check your internet connection or try again.',
      );
    }
  }

  List<RouteOption> _parseRoutes(
    Map<String, dynamic> data,
    double fuelPriceUgx,
    double consumptionPer100km,
  ) {
    final routes = (data['routes'] as List?)?.cast<Map<String, dynamic>>();
    if (routes == null || routes.isEmpty) {
      throw RoutingException('No routes found for this journey.');
    }

    final now = DateTime.now();
    final results = <RouteOption>[];

    for (var i = 0; i < routes.length && i < 3; i++) {
      final route = routes[i];
      final summary = route['summary'] as Map<String, dynamic>?;
      final distKm = ((summary?['distance'] as num?) ?? 0).toDouble();
      final durationSec = ((summary?['duration'] as num?) ?? 0).toDouble();
      final durationMin = (durationSec / 60).round();

      // Decode the encoded polyline geometry.
      final geometryStr = route['geometry'] as String?;
      final waypoints = geometryStr != null
          ? _decodePolyline(geometryStr)
          : <List<double>>[];

      // Determine category and scores by route order from ORS.
      // ORS returns the primary route first, then alternatives by weight.
      final category = i == 0
          ? RouteCategory.balanced
          : i == 1
          ? RouteCategory.fastest
          : RouteCategory.fuelEfficient;

      final fuelCost = distKm * consumptionPer100km / 100 * fuelPriceUgx;
      final smartScore = _calculateSmartScore(
        distKm: distKm,
        durationMin: durationMin,
        fuelCost: fuelCost,
        hazardCount: 0, // Would require road condition overlay for real data
        trafficCondition: TrafficCondition.moderate,
      );

      results.add(RouteOption(
        id: 'ors_route_$i',
        name: _routeName(i),
        category: category,
        distanceKm: distKm,
        estimatedMinutes: durationMin,
        trafficCondition: i == 0 ? TrafficCondition.moderate : TrafficCondition.light,
        smartScore: smartScore,
        recommendationReason: _recommendationReason(category, distKm, durationMin),
        fuelEstimateUgx: fuelCost,
        roadConditionSummary: 'Route calculated by OpenRouteService. '
            'No live traffic feed — conditions may differ.',
        hazardCount: 0,
        reliabilityPercent: 90 - (i * 5),
        dataSource: 'OpenRouteService · driving-car profile',
        lastUpdated: now,
        waypoints: waypoints,
        isRecommended: i == 0,
        isFromRealRouting: true,
      ));
    }

    return results;
  }

  String _routeName(int index) {
    return switch (index) {
      0 => 'Recommended Route',
      1 => 'Alternative Route 1',
      _ => 'Alternative Route 2',
    };
  }

  String _recommendationReason(
    RouteCategory category,
    double distKm,
    int durationMin,
  ) {
    return switch (category) {
      RouteCategory.balanced =>
        'Best overall route based on distance and estimated travel time.',
      RouteCategory.fastest =>
        'Faster estimated travel time — ${durationMin}min for ${distKm.toStringAsFixed(1)}km.',
      RouteCategory.fuelEfficient =>
        'Shorter distance route — ${distKm.toStringAsFixed(1)}km. May take longer.',
    };
  }

  double _calculateSmartScore({
    required double distKm,
    required int durationMin,
    required double fuelCost,
    required int hazardCount,
    required TrafficCondition trafficCondition,
  }) {
    // Weighted score: time 35%, condition 25%, reliability 15%, fuel 15%, hazards 10%
    final timeScore = (1 - (durationMin / 60).clamp(0, 1)) * 35;
    final conditionScore = switch (trafficCondition) {
      TrafficCondition.clear => 25.0,
      TrafficCondition.light => 22.0,
      TrafficCondition.moderate => 15.0,
      TrafficCondition.heavy => 8.0,
      TrafficCondition.blocked => 0.0,
    };
    const reliabilityScore = 15.0; // Default when no historical data available
    final fuelScore = (1 - (fuelCost / 20000).clamp(0, 1)) * 15;
    final hazardScore = (1 - (hazardCount / 5).clamp(0, 1)) * 10;
    return (timeScore + conditionScore + reliabilityScore + fuelScore + hazardScore)
        .clamp(0.0, 100.0);
  }

  /// Decodes an ORS/Google encoded polyline to a list of [lat, lng] pairs.
  List<List<double>> _decodePolyline(String encoded) {
    final result = <List<double>>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result_ = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result_ |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result_ & 1) != 0 ? ~(result_ >> 1) : result_ >> 1);
      lat += dlat;

      shift = 0;
      result_ = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result_ |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result_ & 1) != 0 ? ~(result_ >> 1) : result_ >> 1);
      lng += dlng;

      result.add([lat / 1e5, lng / 1e5]);
    }

    return result;
  }
}

/// Thrown by routing services on recoverable errors.
class RoutingException implements Exception {
  const RoutingException(this.message);
  final String message;

  @override
  String toString() => 'RoutingException: $message';
}
