# SmartRoute Uganda — Application Architecture

## Project Overview

SmartRoute Uganda is a Flutter application targeting Android and Web.
**Flutter version:** 3.47.2 stable
**Dart version:** 3.13.2

---

## Directory Structure

```
lib/
  main.dart                      Entry point — initialises Flutter bindings
  app/
    smartroute_app.dart          Root widget, MultiProvider setup
    app_router.dart              GoRouter configuration, auth-guarded routes
    app_shell.dart               Navigation shell (bottom nav + rail)
  core/
    config/
      environment.dart           --dart-define variable reader (AppEnvironment)
      map_config.dart            Map tile URL, attribution, Photon geocoding constants
    services/
      app_providers.dart         ChangeNotifier providers for features
      routing_service.dart       ORSRoutingService + DemoRoutingService factory
      location_service.dart      GPS permission + position acquisition
      service_interfaces.dart    RoutingService interface, srLog utility
    theme/
      app_colors.dart            Brand colour constants
      app_dimensions.dart        8-point spacing system, radii, component sizes
      app_theme.dart             Light + dark ThemeData builders
      app_typography.dart        Typography styles (Space Grotesk / Inter / JetBrains Mono)
      theme_provider.dart        ThemeMode state with SharedPreferences persistence
  features/
    authentication/
      presentation/
        auth_provider.dart       Demo auth state machine (AuthStatus enum)
        screens/
          login_screen.dart
          signup_screen.dart
          forgot_password_screen.dart
          account_type_screen.dart
    home/
      presentation/screens/
        home_screen.dart         Dashboard with greeting, search card, traffic, reports
    map/
      data/
        map_repository.dart      GeocodingRepository interface + LocalPresetGeocodingRepository
        photon_geocoding_repository.dart  Real geocoding via Photon (OSM) + Nominatim reverse
      domain/
        map_location.dart        MapLocation, MapRouteGeometry, MapPresets
      presentation/
        controllers/
          map_state_controller.dart  Map camera, markers, routes, geocoding orchestrator
        screens/
          map_screen.dart
        widgets/
          smartroute_map.dart    flutter_map widget with OSM tiles + overlays
    route_planner/
      presentation/
        screens/
          route_planner_screen.dart  Origin/destination search + route comparison
        widgets/
          location_search_field.dart  Typed search field with Photon suggestions
    navigation_session/
      presentation/screens/
        navigation_session_screen.dart  Demo navigation UI + arrival screen
    road_reports/
      presentation/screens/
        road_reports_screen.dart   Report feed + map view tab
        create_report_screen.dart  3-step report creation flow
        report_detail_screen.dart  Confirm / mark outdated
    traffic/
      presentation/screens/
        traffic_screen.dart        Area traffic overview (community/demo data)
    fuel/
      presentation/screens/
        fuel_calculator_screen.dart  Vehicle + fuel type + distance → UGX estimate
    saved_places/
      presentation/screens/
        saved_places_screen.dart
    history/
      presentation/screens/
        journey_history_screen.dart
    notifications/
      presentation/screens/
        notifications_screen.dart
    profile/
      presentation/screens/
        profile_screen.dart
        vehicle_management_screen.dart
        gamification_screen.dart
    business/
      presentation/screens/
        business_dashboard_screen.dart
    help/
      presentation/screens/
        help_screen.dart
    settings/
      presentation/screens/
        settings_screen.dart
  shared/
    models/
      app_models.dart            All data models + enums (RouteOption.isFromRealRouting)
      demo_data.dart             Structured demonstration data (labelled — never presented as live)
    widgets/
      shared_widgets.dart        SrCard, SrButton, SrBadge, SrEmptyState, SrLoadingCard
                                 AppSemanticColors extension, LayoutExtensions extension
```

---

## State Management

**Package:** `provider` 6.x  
**Pattern:** ChangeNotifier per feature domain

| Provider | Responsibility |
|---|---|
| `AuthProvider` | Authentication state (demo mode) |
| `ThemeProvider` | ThemeMode with SharedPreferences persistence |
| `RoadReportsProvider` | Report list, add, confirm |
| `TrafficProvider` | Traffic condition summaries |
| `RoutePlannerProvider` | Origin/destination, route search, selected route |
| `SavedPlacesProvider` | Saved locations, home/work shortcuts |
| `NotificationsProvider` | Notification list, read state |
| `JourneyProvider` | Journey history list |

All providers are registered at the root in `SmartRouteApp._SmartRouteAppState.build()`.

---

## Navigation

**Package:** `go_router` 14.x  
**Pattern:** `GoRouter` with `redirect` for auth guard

### Route Map

| Path | Screen | Auth required |
|---|---|---|
| `/login` | LoginScreen | No |
| `/signup` | SignUpScreen | No |
| `/forgot-password` | ForgotPasswordScreen | No |
| `/account-type` | AccountTypeScreen | No |
| `/home` | HomeScreen (shell) | Yes |
| `/routes` | RoutePlannerScreen (shell) | Yes |
| `/reports` | RoadReportsScreen (shell) | Yes |
| `/reports/create` | CreateReportScreen (shell) | Yes |
| `/reports/:id` | ReportDetailScreen (shell) | Yes |
| `/saved` | SavedPlacesScreen (shell) | Yes |
| `/profile` | ProfileScreen (shell) | Yes |
| `/traffic` | TrafficScreen (full) | Yes |
| `/fuel` | FuelCalculatorScreen (full) | Yes |
| `/history` | JourneyHistoryScreen (full) | Yes |
| `/notifications` | NotificationsScreen (full) | Yes |
| `/vehicles` | VehicleManagementScreen (full) | Yes |
| `/gamification` | GamificationScreen (full) | Yes |
| `/business` | BusinessDashboardScreen (full) | Yes |
| `/help` | HelpScreen (full) | Yes |
| `/settings` | SettingsScreen (full) | Yes |
| `/navigate` | NavigationSessionScreen (full) | Yes |

---

## Data Models

All models are in `lib/shared/models/app_models.dart`:

- `UserModel` — id, name, email, accountType, points, level, badges, vehicles
- `VehicleModel` — id, name, category, fuelType, consumptionPer100km
- `PlaceModel` — id, name, address, lat/lng, isHome/isWork/isFavourite
- `RouteOption` — id, name, category, distance, duration, traffic, SmartScore
- `RoadReport` — id, category, description, location, status, confirmations
- `TrafficInfo` — id, areaName, condition, description, lastUpdated
- `Journey` — origin, destination, route, distance, duration, fuelCost
- `AppNotification` — id, title, body, category, createdAt, isRead
- `FuelEstimate` — distanceKm, consumptionPer100km, fuelPriceUgxPerLitre (with computed properties)
- `Badge` — id, name, description, icon, isUnlocked
- `FleetVehicle` — id, name, registrationId, category, driverName, status

---

## Key Enums

```dart
AccountType         { individual, business }
VehicleCategory     { car, taxi, motorcycle, deliveryVehicle, van, truck, other }
FuelType            { petrol, diesel, electric, hybrid }
RouteCategory       { fastest, balanced, fuelEfficient }
TrafficCondition    { clear, light, moderate, heavy, blocked }
ReportCategory      { pothole, flooding, accident, roadworks, closure, ... }
ReportStatus        { unverified, communityConfirmed, underReview, verified, resolved, expired }
GamificationLevel   { explorer, contributor, roadGuardian, mobilityChampion }
FleetStatus         { idle, enRoute, offline }
```

---

## Fuel Calculation (Core Logic)

```
litresRequired = distanceKm × consumptionPer100km ÷ 100
totalCostUgx   = litresRequired × fuelPriceUgxPerLitre
costPerKm      = totalCostUgx ÷ distanceKm
```

Implemented as computed getters on `FuelEstimate`. Covered by unit tests.

---

## SmartScore Calculation (Demo Weights)

| Factor | Weight |
|---|---|
| Estimated journey time | 35% |
| Road condition | 25% |
| Reliability | 15% |
| Estimated fuel cost | 15% |
| Reported hazards | 10% |

These are configurable demonstration weights, not scientifically validated measurements.

---

## Responsive Layout

- `context.isWide` (`screenWidth >= 600`): navigation rail + sidebar
- `context.isVeryWide` (`screenWidth >= 900`): extended layout available
- Mobile: bottom navigation bar (5 tabs)
- Tablet/desktop: left navigation rail with labels

---

## Platform Compatibility

- **Android**: Full support. Uses Material 3.
- **Web (Chrome)**: Full support. No `dart:io` used — all storage via `shared_preferences`.
- **No Firebase dependency** in current demo build — architecture is interface-ready for Firebase addition.

---

## Real-World Mapping & Geocoding

### Map Tiles

| Provider | URL | Status |
|---|---|---|
| OpenStreetMap | `tile.openstreetmap.org/{z}/{x}/{y}.png` | Active — free, requires attribution |

Attribution is displayed by `MapAttributionWidget` in `SmartRouteMap`. Do not remove or hide it.
Do not bulk-download tiles or bypass caching. For production scale, use a hosted tile provider
(MapTiler, Stadia Maps, or self-hosted) that complies with OSM tile usage policy.

### Geocoding

| Component | Provider | Notes |
|---|---|---|
| Forward search | Photon (photon.komoot.io) | OSM-based, free, no key, Uganda bbox bias |
| Reverse geocoding | Nominatim `/reverse` | One call per user action only — complies with OSM Nominatim ToS |
| Demo fallback | `LocalPresetGeocodingRepository` | 13 preset Uganda locations |

**Photon usage rules:**
- Requests are debounced 400ms in `LocationSearchField` — never per-keystroke.
- Uganda bounding box (`29.5,-1.5,35.1,4.3`) biases results without excluding global results.
- Requests include a `User-Agent: SmartRoute-Uganda-App/1.0` header.
- Do not scrape, bulk-query, or remove the debounce.

**Upgrade path:** Implement `MapTilerGeocodingRepository` extending `GeocodingRepository`,
inject it in `MapStateController`, and add `MAPTILER_API_KEY` via `--dart-define`.

### Routing

| Service | Condition | Route marked |
|---|---|---|
| `ORSRoutingService` | `ORS_API_KEY` set | `isFromRealRouting: true` |
| `DemoRoutingService` | No API key | `isFromRealRouting: false` |

`RouteOption.isFromRealRouting` controls whether geometry is drawn as real or illustrative on the
map. It must not be inferred from waypoint count — it is set explicitly by the service.

**Important distinctions:**
- ORS routing calculates routes from road graph data — it is **not** a live traffic feed.
- Traffic conditions shown on the traffic screen are community reports or demo data — always labelled.
- SmartScore is a weighted heuristic — not a validated real-time measurement.

### Demo Mode

When `ORS_API_KEY` is absent, the app operates in demo mode:
- All route cards show `dataSource: 'Sample demonstration data'`
- The `_DataSourceBanner` shows an amber "Sample demonstration routes" notice
- The map preview label shows "Illustrative routes only"
- Location search still uses real Photon geocoding (no key required)

The app **never silently falls back** to demo data without labelling it clearly.

---

## External Service Configuration

All external credentials are injected at build time via `--dart-define`. They are
compiled into the binary and are **not server-side secrets**. Do not use production
private keys here — use short-lived, quota-limited API keys and rotate if exposed.

| Variable | Required | Used for |
|---|---|---|
| `ORS_API_KEY` | Optional | Real routing via OpenRouteService |
| `SUPABASE_URL` | Optional | Backend (future) |
| `SUPABASE_ANON_KEY` | Optional | Backend (future) |
| `MAPTILER_API_KEY` | Optional | MapTiler geocoding upgrade path |
| `ENVIRONMENT` | Optional | Logging verbosity |

See `.env.example` for full documentation.
