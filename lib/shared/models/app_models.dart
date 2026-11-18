import 'package:equatable/equatable.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum AccountType { individual, business }

enum VehicleCategory {
  car,
  taxi,
  motorcycle,
  deliveryVehicle,
  van,
  truck,
  other,
}

enum FuelType { petrol, diesel, electric, hybrid }

enum RouteCategory { fastest, balanced, fuelEfficient }

enum TrafficCondition { clear, light, moderate, heavy, blocked }

enum ReportCategory {
  pothole,
  flooding,
  accident,
  roadworks,
  closure,
  heavyCongestion,
  dangerousCondition,
  otherHazard,
}

enum ReportStatus {
  unverified,
  communityConfirmed,
  underReview,
  verified,
  resolved,
  expired,
}

enum NotificationCategory {
  roadCondition,
  reportConfirmation,
  routeInfo,
  accountUpdate,
  announcement,
}

enum GamificationLevel { explorer, contributor, roadGuardian, mobilityChampion }

// ─── User ─────────────────────────────────────────────────────────────────────

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
    this.avatarUrl,
    this.phone,
    this.points = 0,
    this.level = GamificationLevel.explorer,
    this.badgeIds = const [],
    this.vehicles = const [],
    this.joinedAt,
    this.businessName,
  });

  final String id;
  final String name;
  final String email;
  final AccountType accountType;
  final String? avatarUrl;
  final String? phone;
  final int points;
  final GamificationLevel level;
  final List<String> badgeIds;
  final List<VehicleModel> vehicles;
  final DateTime? joinedAt;
  final String? businessName;

  bool get isBusiness => accountType == AccountType.business;

  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? phone,
    int? points,
    GamificationLevel? level,
    List<String>? badgeIds,
    List<VehicleModel>? vehicles,
    String? businessName,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      accountType: accountType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      points: points ?? this.points,
      level: level ?? this.level,
      badgeIds: badgeIds ?? this.badgeIds,
      vehicles: vehicles ?? this.vehicles,
      joinedAt: joinedAt,
      businessName: businessName ?? this.businessName,
    );
  }

  @override
  List<Object?> get props => [id, name, email, accountType, points, level];
}

// ─── Vehicle ──────────────────────────────────────────────────────────────────

class VehicleModel extends Equatable {
  const VehicleModel({
    required this.id,
    required this.name,
    required this.category,
    required this.fuelType,
    this.consumptionPer100km = 8.0,
    this.registrationId,
    this.isPreferred = false,
  });

  final String id;
  final String name;
  final VehicleCategory category;
  final FuelType fuelType;
  final double consumptionPer100km;
  final String? registrationId;
  final bool isPreferred;

  VehicleModel copyWith({
    String? name,
    VehicleCategory? category,
    FuelType? fuelType,
    double? consumptionPer100km,
    String? registrationId,
    bool? isPreferred,
  }) {
    return VehicleModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      fuelType: fuelType ?? this.fuelType,
      consumptionPer100km: consumptionPer100km ?? this.consumptionPer100km,
      registrationId: registrationId ?? this.registrationId,
      isPreferred: isPreferred ?? this.isPreferred,
    );
  }

  @override
  List<Object?> get props => [id, name, category, fuelType];
}

// ─── Place ────────────────────────────────────────────────────────────────────

class PlaceModel extends Equatable {
  const PlaceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.type = 'place',
    this.isHome = false,
    this.isWork = false,
    this.isFavourite = false,
    this.lastUsed,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type;
  final bool isHome;
  final bool isWork;
  final bool isFavourite;
  final DateTime? lastUsed;

  @override
  List<Object?> get props => [id, latitude, longitude];
}

// ─── Route Option ─────────────────────────────────────────────────────────────

class RouteOption extends Equatable {
  const RouteOption({
    required this.id,
    required this.name,
    required this.category,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.trafficCondition,
    required this.smartScore,
    required this.recommendationReason,
    this.fuelEstimateUgx = 0,
    this.roadConditionSummary = '',
    this.hazardCount = 0,
    this.reliabilityPercent = 85,
    this.dataSource = 'Sample demonstration data',
    this.lastUpdated,
    this.waypoints = const [],
    this.isRecommended = false,
    this.isFromRealRouting = false,
  });

  final String id;
  final String name;
  final RouteCategory category;
  final double distanceKm;
  final int estimatedMinutes;
  final TrafficCondition trafficCondition;
  final double smartScore;
  final String recommendationReason;
  final double fuelEstimateUgx;
  final String roadConditionSummary;
  final int hazardCount;
  final int reliabilityPercent;
  final String dataSource;
  final DateTime? lastUpdated;
  final List<List<double>> waypoints;
  final bool isRecommended;

  /// True when this route was calculated by a real routing service (e.g. ORS).
  /// False for demonstration / fallback data.
  /// Used to decide whether to display route geometry as real or illustrative.
  final bool isFromRealRouting;

  @override
  List<Object?> get props => [id, name, category];
}

// ─── Road Report ─────────────────────────────────────────────────────────────

class RoadReport extends Equatable {
  const RoadReport({
    required this.id,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.reportedAt,
    required this.status,
    this.confirmations = 0,
    this.photoUrl,
    this.reporterName,
    this.isAnonymous = false,
    this.expiresAt,
  });

  final String id;
  final ReportCategory category;
  final String description;
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime reportedAt;
  final ReportStatus status;
  final int confirmations;
  final String? photoUrl;
  final String? reporterName;
  final bool isAnonymous;
  final DateTime? expiresAt;

  RoadReport copyWith({ReportStatus? status, int? confirmations}) {
    return RoadReport(
      id: id,
      category: category,
      description: description,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      reportedAt: reportedAt,
      status: status ?? this.status,
      confirmations: confirmations ?? this.confirmations,
      photoUrl: photoUrl,
      reporterName: reporterName,
      isAnonymous: isAnonymous,
      expiresAt: expiresAt,
    );
  }

  @override
  List<Object?> get props => [id];
}

// ─── Traffic Condition Info ──────────────────────────────────────────────────

class TrafficInfo extends Equatable {
  const TrafficInfo({
    required this.id,
    required this.areaName,
    required this.condition,
    required this.description,
    required this.lastUpdated,
    this.affectedRoads = const [],
    this.isSimulated = true,
  });

  final String id;
  final String areaName;
  final TrafficCondition condition;
  final String description;
  final DateTime lastUpdated;
  final List<String> affectedRoads;
  final bool isSimulated;

  @override
  List<Object?> get props => [id];
}

// ─── Journey ──────────────────────────────────────────────────────────────────

class Journey extends Equatable {
  const Journey({
    required this.id,
    required this.origin,
    required this.destination,
    required this.startedAt,
    required this.selectedRoute,
    this.completedAt,
    this.distanceKm = 0,
    this.durationMinutes = 0,
    this.fuelCostUgx = 0,
    this.status = JourneyStatus.completed,
    this.isDemo = true,
  });

  final String id;
  final PlaceModel origin;
  final PlaceModel destination;
  final DateTime startedAt;
  final String selectedRoute;
  final DateTime? completedAt;
  final double distanceKm;
  final int durationMinutes;
  final double fuelCostUgx;
  final JourneyStatus status;
  final bool isDemo;

  @override
  List<Object?> get props => [id];
}

enum JourneyStatus { active, completed, cancelled }

// ─── Notification ─────────────────────────────────────────────────────────────

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    this.isRead = false,
    this.actionRoute,
  });

  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final DateTime createdAt;
  final bool isRead;
  final String? actionRoute;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      category: category,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute,
    );
  }

  @override
  List<Object?> get props => [id];
}

// ─── Fuel Estimate ────────────────────────────────────────────────────────────

class FuelEstimate extends Equatable {
  const FuelEstimate({
    required this.distanceKm,
    required this.consumptionPer100km,
    required this.fuelPriceUgxPerLitre,
    required this.fuelType,
  });

  final double distanceKm;
  final double consumptionPer100km;
  final double fuelPriceUgxPerLitre;
  final FuelType fuelType;

  /// Fuel required in litres.
  double get litresRequired => distanceKm * consumptionPer100km / 100;

  /// Total estimated cost in UGX.
  double get totalCostUgx => litresRequired * fuelPriceUgxPerLitre;

  /// Cost per kilometre in UGX.
  double get costPerKm => distanceKm > 0 ? totalCostUgx / distanceKm : 0;

  @override
  List<Object?> get props => [
    distanceKm,
    consumptionPer100km,
    fuelPriceUgxPerLitre,
  ];
}

// ─── Gamification ─────────────────────────────────────────────────────────────

class Badge extends Equatable {
  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  @override
  List<Object?> get props => [id];
}

// ─── Fleet Vehicle (Business) ─────────────────────────────────────────────────

class FleetVehicle extends Equatable {
  const FleetVehicle({
    required this.id,
    required this.name,
    required this.registrationId,
    required this.category,
    required this.driverName,
    this.lastJourneyDate,
    this.totalDistanceKm = 0,
    this.isActive = true,
    this.status = FleetStatus.idle,
  });

  final String id;
  final String name;
  final String registrationId;
  final VehicleCategory category;
  final String driverName;
  final DateTime? lastJourneyDate;
  final double totalDistanceKm;
  final bool isActive;
  final FleetStatus status;

  @override
  List<Object?> get props => [id];
}

enum FleetStatus { idle, enRoute, offline }
