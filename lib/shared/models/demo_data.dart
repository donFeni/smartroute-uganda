import '../models/app_models.dart';

/// Demonstration data for SmartRoute Uganda.
/// All data is clearly labelled as sample/demonstration data and does not
/// represent real-time traffic, live incidents or actual current road conditions.
class DemoData {
  DemoData._();

  // ─── Demo User ────────────────────────────────────────────────────────────
  static final UserModel demoUser = UserModel(
    id: 'demo_user_01',
    name: 'Alex Nakato',
    email: 'alex.nakato@demo.smartroute.ug',
    accountType: AccountType.individual,
    points: 2450,
    level: GamificationLevel.contributor,
    badgeIds: [
      'first_report',
      'road_watcher',
      'community_helper',
      'smart_commuter',
    ],
    vehicles: [defaultCar, defaultBoda],
    joinedAt: DateTime(2024, 3, 15),
  );

  static final UserModel demoBusinessUser = UserModel(
    id: 'demo_biz_01',
    name: 'Samuel Mwesiga',
    email: 'samuel@kampalalogistics.demo.ug',
    accountType: AccountType.business,
    points: 5800,
    level: GamificationLevel.roadGuardian,
    badgeIds: [
      'first_report',
      'road_watcher',
      'community_helper',
      'verified_contributor',
      'smart_commuter',
      'fuel_conscious',
      'consistent_contributor',
    ],
    vehicles: fleetVehicleList
        .map(
          (f) => VehicleModel(
            id: f.id,
            name: f.name,
            category: f.category,
            fuelType: FuelType.diesel,
          ),
        )
        .toList(),
    joinedAt: DateTime(2023, 11, 5),
    businessName: 'Kampala Logistics Ltd',
  );

  // ─── Demo Vehicles ────────────────────────────────────────────────────────
  static const VehicleModel defaultCar = VehicleModel(
    id: 'v_car_01',
    name: 'Toyota Premio',
    category: VehicleCategory.car,
    fuelType: FuelType.petrol,
    consumptionPer100km: 8.5,
    isPreferred: true,
  );

  static const VehicleModel defaultBoda = VehicleModel(
    id: 'v_boda_01',
    name: 'Honda CG 125 (Boda)',
    category: VehicleCategory.motorcycle,
    fuelType: FuelType.petrol,
    consumptionPer100km: 3.5,
  );

  // ─── Demo Places ──────────────────────────────────────────────────────────
  static const PlaceModel kampalaCity = PlaceModel(
    id: 'p_kampala_central',
    name: 'Kampala City Centre',
    address: 'Kampala Road, Kampala Central',
    latitude: 0.3476,
    longitude: 32.5825,
  );

  static const PlaceModel ntinda = PlaceModel(
    id: 'p_ntinda',
    name: 'Ntinda',
    address: 'Ntinda, Kampala',
    latitude: 0.3620,
    longitude: 32.6180,
  );

  static const PlaceModel nakawa = PlaceModel(
    id: 'p_nakawa',
    name: 'Nakawa',
    address: 'Nakawa Industrial Area, Kampala',
    latitude: 0.3374,
    longitude: 32.6200,
  );

  static const PlaceModel entebbe = PlaceModel(
    id: 'p_entebbe',
    name: 'Entebbe Town',
    address: 'Entebbe Road, Entebbe',
    latitude: 0.0612,
    longitude: 32.4628,
  );

  static const PlaceModel kyambogo = PlaceModel(
    id: 'p_kyambogo',
    name: 'Kyambogo University',
    address: 'Kyambogo Hill, Kampala',
    latitude: 0.3445,
    longitude: 32.6414,
  );

  static const PlaceModel kireka = PlaceModel(
    id: 'p_kireka',
    name: 'Kireka',
    address: 'Kireka, Wakiso District',
    latitude: 0.3584,
    longitude: 32.6512,
  );

  static const PlaceModel banda = PlaceModel(
    id: 'p_banda',
    name: 'Banda',
    address: 'Banda, Kampala',
    latitude: 0.3521,
    longitude: 32.6350,
  );

  static const PlaceModel bweyogerere = PlaceModel(
    id: 'p_bweyogerere',
    name: 'Bweyogerere',
    address: 'Jinja Road, Bweyogerere',
    latitude: 0.3740,
    longitude: 32.6850,
  );

  static const PlaceModel owino = PlaceModel(
    id: 'p_owino',
    name: 'Owino Market',
    address: 'Ben Kiwanuka St, Kampala',
    latitude: 0.3178,
    longitude: 32.5764,
  );

  static const PlaceModel mulago = PlaceModel(
    id: 'p_mulago',
    name: 'Mulago Hospital',
    address: 'Mulago Hill, Kampala',
    latitude: 0.3374,
    longitude: 32.5764,
  );

  // ─── Saved Places ─────────────────────────────────────────────────────────
  static final List<PlaceModel> savedPlaces = [
    const PlaceModel(
      id: 'sp_home',
      name: 'Home',
      address: 'Ntinda, Kampala',
      latitude: 0.3620,
      longitude: 32.6180,
      isHome: true,
      isFavourite: true,
    ),
    const PlaceModel(
      id: 'sp_work',
      name: 'Work — Nakawa Office',
      address: 'Nakawa, Kampala',
      latitude: 0.3374,
      longitude: 32.6200,
      isWork: true,
      isFavourite: true,
    ),
    const PlaceModel(
      id: 'sp_kyambogo',
      name: 'Kyambogo University',
      address: 'Kyambogo Hill, Kampala',
      latitude: 0.3445,
      longitude: 32.6414,
      isFavourite: true,
    ),
    const PlaceModel(
      id: 'sp_owino',
      name: 'Owino Market',
      address: 'Ben Kiwanuka St, Kampala',
      latitude: 0.3178,
      longitude: 32.5764,
    ),
  ];

  // ─── Recent Places ────────────────────────────────────────────────────────
  static final List<PlaceModel> recentPlaces = [
    nakawa,
    ntinda,
    kampalaCity,
    kyambogo,
  ];

  // ─── Route Options (sample demonstration data) ────────────────────────────
  static List<RouteOption> sampleRoutes({
    double distanceBase = 12.0,
    double fuelPriceUgx = 5600,
    double consumptionPer100km = 8.5,
  }) {
    final now = DateTime.now();

    double fuelCost(double km) => km * consumptionPer100km / 100 * fuelPriceUgx;

    return [
      RouteOption(
        id: 'route_fastest',
        name: 'Via Jinja Road',
        category: RouteCategory.fastest,
        distanceKm: distanceBase * 0.95,
        estimatedMinutes: 28,
        trafficCondition: TrafficCondition.moderate,
        smartScore: 82.0,
        recommendationReason:
            'Shortest estimated journey time based on available traffic data.',
        fuelEstimateUgx: fuelCost(distanceBase * 0.95),
        roadConditionSummary: 'Moderate congestion near Nakawa junction.',
        hazardCount: 1,
        reliabilityPercent: 80,
        dataSource: 'Sample demonstration data',
        lastUpdated: now.subtract(const Duration(minutes: 12)),
        isRecommended: false,
        waypoints: [
          [0.3476, 32.5825],
          [0.3480, 32.5900],
          [0.3420, 32.6050],
          [0.3374, 32.6200],
        ],
      ),
      RouteOption(
        id: 'route_balanced',
        name: 'Via Northern Bypass',
        category: RouteCategory.balanced,
        distanceKm: distanceBase * 1.15,
        estimatedMinutes: 32,
        trafficCondition: TrafficCondition.light,
        smartScore: 88.5,
        recommendationReason: 'Best overall balance of journey time, road conditions and estimated fuel cost.',
        fuelEstimateUgx: fuelCost(distanceBase * 1.15),
        roadConditionSummary: 'Light traffic. Road condition generally good.',
        hazardCount: 0,
        reliabilityPercent: 88,
        dataSource: 'Sample demonstration data',
        lastUpdated: now.subtract(const Duration(minutes: 8)),
        isRecommended: true,
        waypoints: [
          [0.3476, 32.5825],
          [0.3550, 32.5960],
          [0.3590, 32.6100],
          [0.3374, 32.6200],
        ],
      ),
      RouteOption(
        id: 'route_fuel',
        name: 'Via Portbell Road',
        category: RouteCategory.fuelEfficient,
        distanceKm: distanceBase * 0.88,
        estimatedMinutes: 38,
        trafficCondition: TrafficCondition.heavy,
        smartScore: 74.0,
        recommendationReason: 'Shortest distance route. Longer estimated time due to reported congestion.',
        fuelEstimateUgx: fuelCost(distanceBase * 0.88),
        roadConditionSummary:
            'Community-reported heavy congestion. Pothole reported near Banda.',
        hazardCount: 2,
        reliabilityPercent: 68,
        dataSource: 'Sample demonstration data',
        lastUpdated: now.subtract(const Duration(minutes: 22)),
        isRecommended: false,
        waypoints: [
          [0.3476, 32.5825],
          [0.3400, 32.5960],
          [0.3310, 32.6150],
          [0.3374, 32.6200],
        ],
      ),
    ];
  }

  // ─── Road Reports ─────────────────────────────────────────────────────────
  static final List<RoadReport> sampleReports = [
    RoadReport(
      id: 'rr_001',
      category: ReportCategory.pothole,
      description: 'Large pothole on Jinja Road near Banda junction. Road is damaged after recent rains.',
      latitude: 0.3521,
      longitude: 32.6350,
      locationName: 'Jinja Road, Banda',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: ReportStatus.communityConfirmed,
      confirmations: 7,
      isAnonymous: false,
      reporterName: 'James K.',
    ),
    RoadReport(
      id: 'rr_002',
      category: ReportCategory.heavyCongestion,
      description: 'Heavy traffic building from Nakawa junction towards Kampala City. Moving slowly.',
      latitude: 0.3374,
      longitude: 32.6200,
      locationName: 'Nakawa Junction',
      reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: ReportStatus.verified,
      confirmations: 14,
      isAnonymous: false,
      reporterName: 'Mary N.',
    ),
    RoadReport(
      id: 'rr_003',
      category: ReportCategory.roadworks,
      description: 'Road resurfacing works on Northern Bypass near Ntinda flyover. One lane closed.',
      latitude: 0.3620,
      longitude: 32.6180,
      locationName: 'Northern Bypass, Ntinda',
      reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: ReportStatus.verified,
      confirmations: 21,
      isAnonymous: false,
      reporterName: 'Peter O.',
    ),
    RoadReport(
      id: 'rr_004',
      category: ReportCategory.flooding,
      description: 'Water logging at Bweyogerere intersection after morning rains. Motorists advised to avoid.',
      latitude: 0.3740,
      longitude: 32.6850,
      locationName: 'Bweyogerere Intersection',
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: ReportStatus.communityConfirmed,
      confirmations: 5,
      isAnonymous: true,
    ),
    RoadReport(
      id: 'rr_005',
      category: ReportCategory.accident,
      description: 'Vehicle breakdown blocking right lane on Entebbe Road near Kibuye roundabout.',
      latitude: 0.2900,
      longitude: 32.5600,
      locationName: 'Entebbe Road, Kibuye',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 35)),
      status: ReportStatus.unverified,
      confirmations: 2,
      isAnonymous: false,
      reporterName: 'Grace A.',
    ),
    RoadReport(
      id: 'rr_006',
      category: ReportCategory.pothole,
      description: 'Multiple potholes on Kyambogo Road near the university gate. Caution advised.',
      latitude: 0.3445,
      longitude: 32.6414,
      locationName: 'Kyambogo Road',
      reportedAt: DateTime.now().subtract(const Duration(hours: 24)),
      status: ReportStatus.verified,
      confirmations: 32,
      isAnonymous: false,
      reporterName: 'Sarah K.',
    ),
  ];

  // ─── Traffic Information ──────────────────────────────────────────────────
  static final List<TrafficInfo> sampleTrafficInfo = [
    TrafficInfo(
      id: 'tr_001',
      areaName: 'Kampala Central',
      condition: TrafficCondition.heavy,
      description:
          'Heavy congestion across Kampala Central during morning peak hours.',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
      affectedRoads: ['Kampala Road', 'Ben Kiwanuka St', 'William Street'],
      isSimulated: true,
    ),
    TrafficInfo(
      id: 'tr_002',
      areaName: 'Nakawa',
      condition: TrafficCondition.moderate,
      description: 'Moderate congestion around Nakawa junction.',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 20)),
      affectedRoads: ['Jinja Road', 'Nakawa Link Road'],
      isSimulated: true,
    ),
    TrafficInfo(
      id: 'tr_003',
      areaName: 'Northern Bypass',
      condition: TrafficCondition.light,
      description: 'Light traffic on Northern Bypass. Roadworks zone near Ntinda requires caution.',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
      affectedRoads: ['Northern Bypass'],
      isSimulated: true,
    ),
    TrafficInfo(
      id: 'tr_004',
      areaName: 'Entebbe Road',
      condition: TrafficCondition.moderate,
      description: 'Moderate traffic on Entebbe Road. Allow extra time during peak hours.',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
      affectedRoads: ['Entebbe Road', 'Kibuye Road'],
      isSimulated: true,
    ),
    TrafficInfo(
      id: 'tr_005',
      areaName: 'Bweyogerere / Jinja Road East',
      condition: TrafficCondition.moderate,
      description: 'Moderate congestion on Jinja Road approaching Bweyogerere.',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 18)),
      affectedRoads: ['Jinja Road', 'Bweyogerere Link'],
      isSimulated: true,
    ),
    TrafficInfo(
      id: 'tr_006',
      areaName: 'Kyambogo / Kireka',
      condition: TrafficCondition.clear,
      description: 'Clear conditions reported on Kyambogo Road.',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      affectedRoads: ['Kyambogo Road'],
      isSimulated: true,
    ),
  ];

  // ─── Journey History ──────────────────────────────────────────────────────
  static final List<Journey> sampleJourneys = [
    Journey(
      id: 'j_001',
      origin: kampalaCity,
      destination: ntinda,
      startedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      completedAt: DateTime.now().subtract(
        const Duration(days: 1, hours: 1, minutes: 28),
      ),
      selectedRoute: 'Via Northern Bypass',
      distanceKm: 9.4,
      durationMinutes: 32,
      fuelCostUgx: 4500,
      status: JourneyStatus.completed,
      isDemo: true,
    ),
    Journey(
      id: 'j_002',
      origin: ntinda,
      destination: nakawa,
      startedAt: DateTime.now().subtract(const Duration(days: 2, hours: 8)),
      completedAt: DateTime.now().subtract(
        const Duration(days: 2, hours: 7, minutes: 45),
      ),
      selectedRoute: 'Via Jinja Road',
      distanceKm: 5.6,
      durationMinutes: 15,
      fuelCostUgx: 2680,
      status: JourneyStatus.completed,
      isDemo: true,
    ),
    Journey(
      id: 'j_003',
      origin: kampalaCity,
      destination: kyambogo,
      startedAt: DateTime.now().subtract(const Duration(days: 3, hours: 17)),
      completedAt: DateTime.now().subtract(
        const Duration(days: 3, hours: 16, minutes: 22),
      ),
      selectedRoute: 'Via Portbell Road',
      distanceKm: 11.2,
      durationMinutes: 38,
      fuelCostUgx: 5350,
      status: JourneyStatus.completed,
      isDemo: true,
    ),
    Journey(
      id: 'j_004',
      origin: nakawa,
      destination: kireka,
      startedAt: DateTime.now().subtract(const Duration(days: 5, hours: 9)),
      completedAt: DateTime.now().subtract(
        const Duration(days: 5, hours: 8, minutes: 50),
      ),
      selectedRoute: 'Via Northern Bypass',
      distanceKm: 7.8,
      durationMinutes: 20,
      fuelCostUgx: 3730,
      status: JourneyStatus.completed,
      isDemo: true,
    ),
  ];

  // ─── Notifications ─────────────────────────────────────────────────────────
  static final List<AppNotification> sampleNotifications = [
    AppNotification(
      id: 'n_001',
      title: 'Road Report Confirmed',
      body: 'Your pothole report on Jinja Road has been confirmed by 5 other community members.',
      category: NotificationCategory.reportConfirmation,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    AppNotification(
      id: 'n_002',
      title: 'Heavy Congestion — Kampala Central',
      body: 'Community members report heavy congestion on Kampala Road. Consider alternative routes.',
      category: NotificationCategory.roadCondition,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
    ),
    AppNotification(
      id: 'n_003',
      title: 'You\'ve earned a new badge!',
      body: 'Congratulations! You\'ve unlocked the "Road Watcher" badge for 5 confirmed reports.',
      category: NotificationCategory.accountUpdate,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    AppNotification(
      id: 'n_004',
      title: 'Roadworks on Northern Bypass',
      body: 'Active roadworks near Ntinda flyover. One lane closed. Allow extra travel time.',
      category: NotificationCategory.roadCondition,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    AppNotification(
      id: 'n_005',
      title: 'Welcome to SmartRoute Uganda',
      body: 'Start planning smarter journeys. Report road conditions to help your community.',
      category: NotificationCategory.announcement,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
    ),
  ];

  // ─── Badges ───────────────────────────────────────────────────────────────
  static final List<Badge> allBadges = [
    const Badge(
      id: 'first_report',
      name: 'First Report',
      description: 'Submitted your first road condition report.',
      icon: '🗺️',
      isUnlocked: true,
    ),
    const Badge(
      id: 'road_watcher',
      name: 'Road Watcher',
      description: '5 of your reports confirmed by the community.',
      icon: '👁️',
      isUnlocked: true,
    ),
    const Badge(
      id: 'community_helper',
      name: 'Community Helper',
      description: 'Confirmed 20 road reports from other users.',
      icon: '🤝',
      isUnlocked: true,
    ),
    const Badge(
      id: 'verified_contributor',
      name: 'Verified Contributor',
      description: '3 reports officially verified by SmartRoute.',
      icon: '✅',
      isUnlocked: false,
    ),
    const Badge(
      id: 'smart_commuter',
      name: 'Smart Commuter',
      description: 'Completed 10 planned journeys using SmartRoute.',
      icon: '🚗',
      isUnlocked: true,
    ),
    const Badge(
      id: 'fuel_conscious',
      name: 'Fuel Conscious',
      description:
          'Estimated UGX 50,000 in fuel savings using route comparison.',
      icon: '⛽',
      isUnlocked: false,
    ),
    const Badge(
      id: 'consistent_contributor',
      name: 'Consistent Contributor',
      description: '7-day contribution streak on SmartRoute.',
      icon: '🔥',
      isUnlocked: false,
    ),
  ];

  // ─── Fleet Vehicles ───────────────────────────────────────────────────────
  static final List<FleetVehicle> fleetVehicleList = [
    FleetVehicle(
      id: 'fv_001',
      name: 'Delivery Truck 01',
      registrationId: 'UAX 123B',
      category: VehicleCategory.truck,
      driverName: 'Robert Ssali',
      lastJourneyDate: DateTime.now().subtract(const Duration(hours: 2)),
      totalDistanceKm: 1240,
      isActive: true,
      status: FleetStatus.enRoute,
    ),
    FleetVehicle(
      id: 'fv_002',
      name: 'Van 02',
      registrationId: 'UBE 456C',
      category: VehicleCategory.van,
      driverName: 'Catherine Amoit',
      lastJourneyDate: DateTime.now().subtract(const Duration(hours: 5)),
      totalDistanceKm: 875,
      isActive: true,
      status: FleetStatus.idle,
    ),
    FleetVehicle(
      id: 'fv_003',
      name: 'Delivery Van 03',
      registrationId: 'UCC 789D',
      category: VehicleCategory.deliveryVehicle,
      driverName: 'Moses Otim',
      lastJourneyDate: DateTime.now().subtract(const Duration(days: 1)),
      totalDistanceKm: 632,
      isActive: false,
      status: FleetStatus.offline,
    ),
    FleetVehicle(
      id: 'fv_004',
      name: 'Pickup 04',
      registrationId: 'UDA 012E',
      category: VehicleCategory.deliveryVehicle,
      driverName: 'Fatima Nabukenya',
      lastJourneyDate: DateTime.now().subtract(const Duration(hours: 8)),
      totalDistanceKm: 1580,
      isActive: true,
      status: FleetStatus.idle,
    ),
  ];

  // ─── FAQ items ─────────────────────────────────────────────────────────────
  static const List<Map<String, String>> faqItems = [
    {
      'q': 'What is SmartRoute Uganda?',
      'a': 'SmartRoute Uganda is a locally informed mobility intelligence platform designed to help motorists in Uganda make smarter route decisions by comparing available route options, understanding road conditions, and estimating fuel costs.',
    },
    {
      'q': 'Is the traffic information live?',
      'a': 'In the current demonstration version, traffic and road condition information is based on community reports and sample data. Features clearly labelled "Sample demonstration data" or "Community-reported" are not from a live traffic feed.',
    },
    {
      'q': 'How is the SmartScore calculated?',
      'a': 'The SmartScore is calculated using a weighted model: estimated journey time (35%), road condition (25%), reliability (15%), estimated fuel cost (15%), and reported hazards (10%). These weights are configurable demonstration assumptions, not scientifically validated measurements.',
    },
    {
      'q': 'How do I report a road condition?',
      'a': 'Tap "Road Reports" in the bottom navigation, then tap the "+" button to submit a new report. Choose a category, describe what you observed, confirm your location, and submit. Your report helps the entire SmartRoute community.',
    },
    {
      'q': 'Are my location details shared?',
      'a': 'Location is only used to show nearby road conditions and calculate route options. In the current demonstration version, no location data is stored or transmitted to any server. Review our Privacy Information for details.',
    },
    {
      'q': 'What does the fuel estimate include?',
      'a': 'The fuel estimate is based on your selected vehicle\'s average consumption per 100 km, the estimated route distance, and the fuel price you enter. It is an estimate and will vary with actual driving conditions, traffic and vehicle state.',
    },
    {
      'q': 'How do gamification points work?',
      'a': 'SmartRoute Points are awarded for submitting road reports, having your reports confirmed, and maintaining contribution streaks. Points are engagement indicators and do not carry any monetary value.',
    },
  ];
}
