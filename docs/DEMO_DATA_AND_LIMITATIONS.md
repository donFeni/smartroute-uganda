# SmartRoute Uganda — Demo Data & Limitations

## Summary

This document describes which features use live data, which use demonstration data, and the known limitations of the current build.

---

## Data Status by Feature

| Feature | Data Status | Notes |
|---|---|---|
| Authentication | ✅ Demo mode | Any email + 6+ char password works. No real auth provider. |
| Route comparison | ⚠️ Sample data | 3 static demo routes. Not real routing calculations. |
| Road reports feed | ⚠️ Sample data | 6 pre-seeded demo reports. Users can add new ones locally. |
| Road report creation | ✅ Functional (local) | Reports persist in memory for the session. |
| Traffic overview | ⚠️ Sample data | 6 Kampala-area demo records. Not a live traffic feed. |
| Fuel calculator | ✅ Functional | Real formula calculations. User-adjustable inputs. |
| Saved places | ✅ Functional (local) | Persists in memory. No backend storage. |
| Journey history | ⚠️ Sample data | 4 demo journey records. |
| Notifications | ⚠️ Sample data | 5 demo notifications. |
| Gamification | ⚠️ Sample data | Points and badges from demo user profile. |
| Business dashboard | ⚠️ Sample data | 4 demo fleet vehicles. No live tracking. |
| Navigation session | ⚠️ Demo mode | Simulated navigation UI. No real GPS/turn-by-turn. |
| Map view | ⚠️ Placeholder | Map UI placeholder shown. Full map requires flutter_map integration + tile provider. |
| Settings (theme) | ✅ Functional | Real-time theme switching. Persists via SharedPreferences. |
| Help / FAQ | ✅ Functional | Static content. |

---

## APIs and Services

### Connected
- **None** in current demo build

### Ready to connect (interface exists)
- **Firebase Authentication** — `AuthProvider` interface can be replaced with a Firebase implementation
- **Cloud Firestore** — `RoadReportsProvider` and `SavedPlacesProvider` can use Firestore as the backend
- **OpenStreetMap / flutter_map** — `flutter_map` package is included. Requires tile provider URL and attribution
- **OpenRouteService** — Can be connected to `RoutePlannerProvider.searchRoutes()` for real routing

### Not connected
- Live traffic feed (no provider selected)
- Push notifications (requires FCM and backend)
- Image upload for road reports (requires Firebase Storage or equivalent)
- Fleet vehicle location tracking (requires location permission + backend)

---

## Known Limitations

1. **No real route calculations.** Route options are static demo data with sample distances and times.
2. **No live map tiles.** The map views show a placeholder. Full map requires a tile provider URL and proper attribution.
3. **No GPS navigation.** The navigation session is a UI demonstration only.
4. **No real traffic data.** All traffic conditions are demonstration data.
5. **Session persistence is memory-only** for most features. Closing and reopening the app resets road reports, notifications, and journeys.
6. **Authentication is demo mode.** No real credentials are validated.
7. **No image upload.** Report photos are not implemented in this build.
8. **No push notifications.** The notification centre is populated with static demo data.
9. **Fleet tracking is not live.** No real GPS tracking is connected.
10. **Fonts require internet on first load.** Google Fonts are used and cached locally after the first request. Subsequent loads are offline-capable.

---

## Sample Data Locations

Sample data uses verified Kampala-area place names and approximate coordinates:

| Place | Approx. Lat | Approx. Lng | Notes |
|---|---|---|---|
| Kampala City Centre | 0.3476 | 32.5825 | Approximate |
| Ntinda | 0.3620 | 32.6180 | Approximate |
| Nakawa | 0.3374 | 32.6200 | Approximate |
| Kyambogo University | 0.3445 | 32.6414 | Approximate |
| Kireka | 0.3584 | 32.6512 | Approximate |
| Banda | 0.3521 | 32.6350 | Approximate |
| Bweyogerere | 0.3740 | 32.6850 | Approximate |
| Entebbe | 0.0612 | 32.4628 | Approximate |

All locations are labelled as "Sample demonstration data" in the UI.

---

## Required for Production Readiness

### Essential
- [ ] Firebase Authentication (or equivalent) setup
- [ ] Firebase project configuration (`google-services.json`, `GoogleService-Info.plist`)
- [ ] Real routing API (OpenRouteService, Google Directions, etc.)
- [ ] Map tile provider with proper attribution (OpenStreetMap recommended)
- [ ] Firestore or equivalent for persistent road reports
- [ ] FCM for push notifications

### Recommended
- [ ] GPS permission flow with `geolocator` package
- [ ] Image upload for road reports (`firebase_storage` or similar)
- [ ] Real-time traffic data provider (if available for Uganda)
- [ ] Analytics (Firebase Analytics or equivalent)
- [ ] Backend API for fleet management

### Security
- [ ] Move API keys to environment variables or secure backend proxy
- [ ] Enable Firebase App Check
- [ ] Implement report moderation backend
- [ ] Privacy policy hosted at a real URL
