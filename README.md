# SmartRoute Uganda

### Beyond Navigation. Towards Smarter Mobility.

SmartRoute Uganda is a Flutter-based mobility intelligence platform designed to help motorists and transport businesses make informed travel decisions in Uganda — beginning with Kampala and Jinja.

---

## Table of Contents

- [Project Status](#project-status)
- [Quick Start](#quick-start)
- [Environment Configuration](#environment-configuration)
- [Backend Setup (Supabase)](#backend-setup-supabase)
- [Routing Service (OpenRouteService)](#routing-service-openrouteservice)
- [Features](#features)
- [Architecture](#architecture)
- [Testing](#testing)
- [Android Build](#android-build)
- [Deployment Checklist](#deployment-checklist)
- [Known Limitations](#known-limitations)

---

## Project Status

| Feature | Status |
|---|---|
| Authentication (demo mode) | ✅ Fully functional |
| Splash screen + onboarding | ✅ Fully functional |
| Session persistence | ✅ Functional (SharedPreferences) |
| Interactive OSM map | ✅ Functional |
| Location permission handling | ✅ Functional |
| Route planning (demo data) | ✅ Functional |
| Route planning (real ORS routing) | ✅ Available — requires ORS API key |
| Road reports (in-memory) | ✅ Functional |
| Traffic overview | ⚠️ Sample data only |
| Fuel calculator | ✅ Functional (real formula) |
| Journey history | ⚠️ Demo data only |
| Saved places | ✅ Functional (in-memory) |
| Notifications | ⚠️ Demo data only |
| Profile management | ⚠️ Demo data only |
| Vehicle management | ⚠️ Demo data only |
| Business dashboard | ⚠️ Demo data only |
| Gamification | ⚠️ Demo data only |
| Settings (theme) | ✅ Functional (persisted) |
| Help / FAQ | ✅ Functional |
| Real authentication (Supabase) | ⏳ Requires Supabase project setup |
| Persistent backend (Supabase) | ⏳ Requires Supabase project setup |
| Push notifications (FCM) | 🔴 Not implemented |
| Live traffic data | 🔴 Not implemented |
| GPS turn-by-turn navigation | 🔴 Not implemented |

**Legend:**  ✅ Done  ⚠️ Demo/partial  ⏳ Ready when configured  🔴 Not yet implemented

---

## Quick Start

### Prerequisites

- Flutter 3.47.2+ (stable)
- Dart 3.13.2+
- Android SDK (for Android builds)
- Chrome (for web testing)

### Run in demo mode (no external credentials needed)

```bash
git clone <repository>
cd smartroute_uganda
flutter pub get
flutter run -d chrome          # Web
flutter run -d <android_id>    # Android device/emulator
```

Demo mode uses sample data and requires no backend configuration.

---

## Environment Configuration

All external credentials are passed via `--dart-define` flags. **Never commit credentials.**

Copy `.env.example` to `.env` (git-ignored) and fill in your values.

### Run with real services

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=ORS_API_KEY=your_ors_api_key \
  --dart-define=ENVIRONMENT=development
```

### Build release APK with real services

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ... \
  --dart-define=ORS_API_KEY=your_ors_api_key \
  --dart-define=ENVIRONMENT=production
```

---

## Backend Setup (Supabase)

The complete database schema and setup instructions are in [`lib/core/config/supabase_schema.dart`](lib/core/config/supabase_schema.dart).

### Steps

1. Create a project at [supabase.com](https://supabase.com)
2. Open **SQL Editor** and run the migration SQL from `supabase_schema.dart`
3. Enable **Email** authentication in Auth > Providers
4. Copy your Project URL and anon key from Project Settings > API
5. Pass them as `--dart-define` flags (see above)

### Tables created

| Table | Purpose |
|---|---|
| `profiles` | User profile data (extends auth.users) |
| `vehicles` | User-owned vehicles |
| `saved_places` | User-saved locations |
| `road_reports` | Community road hazard reports |
| `report_confirmations` | Community confirmation votes |
| `journeys` | Journey history records |
| `notifications` | In-app notifications |
| `fleet_vehicles` | Business fleet records |
| `gamification_events` | Points and achievement events |

All tables have Row Level Security (RLS) enabled. Users can only access their own data.

---

## Routing Service (OpenRouteService)

SmartRoute uses [OpenRouteService](https://openrouteservice.org) for real routing when configured.

- **Free tier:** 2,000 requests/day, 3 alternative routes per request
- **Profile:** `driving-car` (appropriate for Uganda's road network)
- **Fallback:** If no API key is provided or the request fails, demo routes are shown with a clear banner

### Get an API key

1. Register at [openrouteservice.org](https://openrouteservice.org)
2. Create an API key in your dashboard
3. Pass it via `--dart-define=ORS_API_KEY=your_key`

---

## Features

### Authentication
- Email/password login (demo mode or Supabase)
- Guest / demo mode access
- Account type selection (Individual / Business)
- Session persistence across app restarts
- Password reset flow
- Onboarding for new users

### Maps
- Interactive OpenStreetMap via `flutter_map`
- Location permission handling (all states)
- Current location via `geolocator`
- Road report markers
- Route polyline overlays
- Location search (preset-based in demo; Nominatim/other in production)
- Quick-navigate presets for Kampala and Uganda

### Route Planning
- Origin and destination selection
- Real routing via OpenRouteService (when configured)
- Demo route comparison (always available as fallback)
- SmartScore calculation (time 35% / condition 25% / reliability 15% / fuel 15% / hazards 10%)
- Estimated fuel cost per route
- Route polylines on map

### Road Reports
- Community report feed (feed + map view)
- Category filters
- Report creation flow
- Community confirmation
- Verification status
- Report detail view

### Core Features
- Fuel cost calculator (real formula — distance × consumption × price)
- Journey history
- Saved places (home / work / custom)
- Notifications centre
- User profile and vehicle management
- Business fleet dashboard
- Gamification (points, badges, levels)
- Theme switching (light / dark / system)
- Help and FAQ

---

## Architecture

```
lib/
  main.dart                    Entry point
  app/
    smartroute_app.dart        Root widget, providers, router (created once)
    app_router.dart            GoRouter — splash, onboarding, auth, shell routes
    app_shell.dart             Adaptive navigation shell (bottom bar / rail)
  core/
    config/
      environment.dart         --dart-define credential reading + feature flags
      map_config.dart          Map tile and zoom configuration
      supabase_schema.dart     Database schema documentation + SQL migrations
    services/
      app_providers.dart       ChangeNotifier providers (all features)
      location_service.dart    Geolocator wrapper with permission states
      routing_service.dart     Routing service — ORS (real) + Demo (fallback)
      service_interfaces.dart  Abstract interfaces (auth, repos, routing)
    theme/                     Light/dark themes, typography, colours, dimensions
  features/                    Feature modules (authentication, map, routes, etc.)
  shared/
    models/
      app_models.dart          All data models and enums
      demo_data.dart           Centralised demo/sample data
    widgets/
      shared_widgets.dart      SrCard, SrButton, SrBadge, SrEmptyState, etc.
```

**State management:** Provider 6.x (ChangeNotifier)  
**Navigation:** GoRouter 14.x (auth-guarded routes, shell route)  
**Maps:** flutter_map 7.x + OpenStreetMap tiles  
**HTTP:** http 1.x (routing API calls)  
**Storage:** SharedPreferences (theme, session persistence)

---

## Testing

```bash
# Run all unit tests
flutter test

# Run with verbose output
flutter test test/core_logic_test.dart --reporter=expanded
```

### Test results (last run)

```
✅  20 tests passed — 0 failures — 0 errors

FuelEstimate:        5 tests — fuel calculations, zero-distance, motorcycle comparison
RouteOption:         4 tests — SmartScore range, recommended route, category ordering
RoadReport:          2 tests — copyWith, sample data validity
DemoData:            5 tests — user, routes, saved places, notifications, fleet
Form validation:     2 tests — email, password
ReportStatus:        2 tests — distinct values, active/inactive classification
```

---

## Android Build

### Debug build (no signing needed)

```bash
flutter build apk --debug
```

### Release build for testing (debug-signed — not for Play Store)

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Release build for Google Play (requires keystore)

1. Generate a keystore (one-time):
   ```bash
   keytool -genkey -v -keystore smartroute-release.jks \
     -alias smartroute -keyalg RSA -keysize 2048 -validity 10000
   ```

2. Create `android/key.properties` (git-ignored):
   ```
   storePassword=<your_password>
   keyPassword=<your_password>
   keyAlias=smartroute
   storeFile=<path_to>/smartroute-release.jks
   ```

3. Update `android/app/build.gradle.kts` to reference the keystore.

4. Build:
   ```bash
   flutter build appbundle --release \
     --dart-define=ENVIRONMENT=production \
     --dart-define=SUPABASE_URL=... \
     --dart-define=SUPABASE_ANON_KEY=... \
     --dart-define=ORS_API_KEY=...
   ```

### App details

| Field | Value |
|---|---|
| Application ID | `ug.smartroute.app` |
| App name | SmartRoute Uganda |
| Min SDK | 23 (Android 6.0) |
| Target SDK | Flutter default |
| Version | 1.0.0+1 |

---

## Deployment Checklist

### Before academic demonstration

- [x] Demo mode works without external credentials
- [x] All screens render without errors
- [x] Navigation between all screens works
- [x] Fuel calculator gives correct results
- [x] Road reports can be created and confirmed
- [x] Light and dark themes work
- [x] Session persists across app restart
- [x] Map loads OSM tiles
- [x] Splash screen and onboarding display

### Before pilot deployment (real users)

- [ ] Supabase project created and SQL migrations run
- [ ] Authentication tested with real email accounts
- [ ] `SUPABASE_URL` and `SUPABASE_ANON_KEY` configured in build
- [ ] ORS API key obtained and tested (optional but recommended)
- [ ] Custom app icon added (replace `ic_launcher` assets)
- [ ] App name verified in `AndroidManifest.xml`
- [ ] Release keystore generated and configured
- [ ] Privacy policy hosted at a real URL
- [ ] Terms and conditions reviewed

### Before Google Play submission

- [ ] All above pilot items complete
- [ ] Release AAB built with production credentials
- [ ] App tested on multiple Android devices and screen sizes
- [ ] Google Play developer account set up
- [ ] Store listing prepared (screenshots, description, icon)
- [ ] Content rating completed
- [ ] Data safety form completed
- [ ] Privacy policy URL added to Play Store listing

---

## Known Limitations

1. **No real authentication by default.** Demo mode accepts any valid email + 6-character password. Supabase authentication is architecture-ready but requires external configuration.

2. **No live traffic data.** All traffic conditions are demonstration data. A live traffic provider for Uganda was not available at time of development.

3. **Route geometry is illustrative in demo mode.** When OpenRouteService is not configured, route polylines are drawn between sample waypoints, not real calculated paths.

4. **No turn-by-turn navigation.** The navigation session screen demonstrates the UI but does not provide real GPS-guided navigation.

5. **Map tile caching.** Standard OSM tiles are used. For production at scale, a hosted tile provider (MapTiler, Stadia Maps, or self-hosted) should be evaluated to comply with OSM tile usage policy.

6. **Location search is preset-only in demo mode.** A geocoding service (Nominatim, MapTiler Geocoding) should be integrated for production search.

7. **No image upload.** Road report photo submission is not yet implemented.

8. **No push notifications.** The notifications centre uses static data. FCM integration is required for production push notifications.

9. **Session is demo-only.** Closing the app resets road reports and notifications in demo mode. Supabase integration provides persistent storage.

10. **Flutter 3.47.2 / Dart 3.13.2 baseline.** Package versions are pinned for stability. Consider reviewing for updates before production deployment.

---

## Academic Project

IST2106 – Entrepreneurship Principles  
Makerere University
