import 'package:flutter/foundation.dart';

import '../../shared/models/app_models.dart';
import '../../shared/models/demo_data.dart';
import 'routing_service.dart';
import 'service_interfaces.dart';

/// Manages road reports state.
class RoadReportsProvider extends ChangeNotifier {
  final List<RoadReport> _reports = List.from(DemoData.sampleReports);
  bool _isLoading = false;

  List<RoadReport> get reports => List.unmodifiable(_reports);
  bool get isLoading => _isLoading;

  List<RoadReport> get activeReports => _reports
      .where(
        (r) =>
            r.status != ReportStatus.resolved &&
            r.status != ReportStatus.expired,
      )
      .toList();

  void addReport(RoadReport report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  void confirmReport(String reportId) {
    final idx = _reports.indexWhere((r) => r.id == reportId);
    if (idx != -1) {
      final existing = _reports[idx];
      _reports[idx] = existing.copyWith(
        confirmations: existing.confirmations + 1,
        status: existing.confirmations >= 4
            ? ReportStatus.communityConfirmed
            : existing.status,
      );
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    _isLoading = false;
    notifyListeners();
  }
}

/// Manages traffic information state.
class TrafficProvider extends ChangeNotifier {
  final List<TrafficInfo> _traffic = List.from(DemoData.sampleTrafficInfo);

  List<TrafficInfo> get trafficInfo => List.unmodifiable(_traffic);

  TrafficCondition get overallCondition {
    if (_traffic.any((t) => t.condition == TrafficCondition.heavy)) {
      return TrafficCondition.heavy;
    }
    if (_traffic.any((t) => t.condition == TrafficCondition.moderate)) {
      return TrafficCondition.moderate;
    }
    return TrafficCondition.light;
  }
}

/// Manages route planning state.
class RoutePlannerProvider extends ChangeNotifier {
  RoutePlannerProvider() : _routingService = createRoutingService();

  final RoutingService _routingService;

  PlaceModel? _origin;
  PlaceModel? _destination;
  List<RouteOption> _routes = [];
  RouteOption? _selectedRoute;
  bool _isSearching = false;
  bool _isNavigating = false;
  String? _routingError;

  PlaceModel? get origin => _origin;
  PlaceModel? get destination => _destination;
  List<RouteOption> get routes => List.unmodifiable(_routes);
  RouteOption? get selectedRoute => _selectedRoute;
  bool get isSearching => _isSearching;
  bool get isNavigating => _isNavigating;
  bool get hasResults => _routes.isNotEmpty;
  String? get routingError => _routingError;
  bool get isUsingRealRouting => _routingService.isRealRouting;

  void setOrigin(PlaceModel place) {
    _origin = place;
    notifyListeners();
  }

  void setDestination(PlaceModel place) {
    _destination = place;
    notifyListeners();
  }

  void swapLocations() {
    final temp = _origin;
    _origin = _destination;
    _destination = temp;
    notifyListeners();
  }

  Future<void> searchRoutes({double fuelPriceUgx = 5600, double consumptionPer100km = 8.5}) async {
    if (_origin == null || _destination == null) return;
    _isSearching = true;
    _selectedRoute = null;
    _routingError = null;
    notifyListeners();

    try {
      _routes = await _routingService.fetchRoutes(
        originLat: _origin!.latitude,
        originLng: _origin!.longitude,
        destLat: _destination!.latitude,
        destLng: _destination!.longitude,
        fuelPriceUgx: fuelPriceUgx,
        consumptionPer100km: consumptionPer100km,
      );
    } on RoutingException catch (e) {
      _routingError = e.message;
      // Fall back to demo routes so the UI is never empty.
      _routes = DemoData.sampleRoutes(
        fuelPriceUgx: fuelPriceUgx,
        consumptionPer100km: consumptionPer100km,
      );
    } catch (e) {
      _routingError = 'Routing service unavailable. Showing sample routes.';
      _routes = DemoData.sampleRoutes(
        fuelPriceUgx: fuelPriceUgx,
        consumptionPer100km: consumptionPer100km,
      );
    }

    _isSearching = false;
    notifyListeners();
  }

  void selectRoute(RouteOption route) {
    _selectedRoute = route;
    notifyListeners();
  }

  void startNavigation() {
    _isNavigating = true;
    notifyListeners();
  }

  void endNavigation() {
    _isNavigating = false;
    notifyListeners();
  }

  void clearRoutes() {
    _routes = [];
    _selectedRoute = null;
    notifyListeners();
  }

  void clearAll() {
    _origin = null;
    _destination = null;
    _routes = [];
    _selectedRoute = null;
    _isSearching = false;
    _isNavigating = false;
    notifyListeners();
  }
}

/// Manages saved places state.
class SavedPlacesProvider extends ChangeNotifier {
  final List<PlaceModel> _savedPlaces = List.from(DemoData.savedPlaces);

  List<PlaceModel> get savedPlaces => List.unmodifiable(_savedPlaces);

  PlaceModel? get homePlace => _savedPlaces.where((p) => p.isHome).firstOrNull;

  PlaceModel? get workPlace => _savedPlaces.where((p) => p.isWork).firstOrNull;

  List<PlaceModel> get favourites =>
      _savedPlaces.where((p) => p.isFavourite).toList();

  void addPlace(PlaceModel place) {
    _savedPlaces.add(place);
    notifyListeners();
  }

  void removePlace(String placeId) {
    _savedPlaces.removeWhere((p) => p.id == placeId);
    notifyListeners();
  }
}

/// Manages notifications state.
class NotificationsProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = List.from(
    DemoData.sampleNotifications,
  );

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }
}

/// Manages journey history state.
class JourneyProvider extends ChangeNotifier {
  final List<Journey> _journeys = List.from(DemoData.sampleJourneys);

  List<Journey> get journeys => List.unmodifiable(_journeys);

  double get totalDistanceKm =>
      _journeys.fold(0, (sum, j) => sum + j.distanceKm);

  double get totalFuelCostUgx =>
      _journeys.fold(0, (sum, j) => sum + j.fuelCostUgx);

  void addJourney(Journey journey) {
    _journeys.insert(0, journey);
    notifyListeners();
  }
}
