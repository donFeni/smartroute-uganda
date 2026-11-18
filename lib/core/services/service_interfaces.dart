import 'package:flutter/foundation.dart';

import '../../shared/models/app_models.dart';

/// Interface for the authentication service.
///
/// Implemented by [DemoAuthService] (always available) and
/// [SupabaseAuthService] (when Supabase is configured).
abstract class AuthService {
  /// Whether the service uses real authentication.
  bool get isRealAuth;

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges;

  /// Current authenticated user, or null.
  Future<UserModel?> get currentUser;

  /// Sign in with email and password.
  /// Returns the authenticated user on success.
  /// Throws [AuthException] on failure.
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// Register a new account.
  /// Returns the authenticated user on success.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required AccountType accountType,
    String? businessName,
  });

  /// Sign out the current user.
  Future<void> signOut();

  /// Send a password reset email.
  /// Throws [AuthException] if the email is not found.
  Future<void> sendPasswordReset(String email);

  /// Update the current user's profile.
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? businessName,
    String? avatarUrl,
  });
}

/// Represents the authentication state at a point in time.
class AuthState {
  const AuthState({required this.user, required this.event});
  final UserModel? user;
  final AuthEvent event;
}

enum AuthEvent { signedIn, signedOut, tokenRefreshed, userUpdated }

/// Thrown by [AuthService] implementations on recoverable errors.
class AuthException implements Exception {
  const AuthException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AuthException($code): $message';
}

/// Interface for the road reports data source.
abstract class RoadReportsDataSource {
  Future<List<RoadReport>> fetchReports({
    double? nearLatitude,
    double? nearLongitude,
    double? radiusKm,
    int limit = 50,
  });

  Future<RoadReport> createReport(RoadReport report);

  Future<RoadReport> confirmReport(String reportId, String userId);

  Future<RoadReport> updateReportStatus(String reportId, ReportStatus status);

  Stream<List<RoadReport>> watchReports();
}

/// Interface for saved places data source.
abstract class SavedPlacesDataSource {
  Future<List<PlaceModel>> fetchSavedPlaces(String userId);
  Future<PlaceModel> savePace(PlaceModel place, String userId);
  Future<void> deletePlace(String placeId, String userId);
}

/// Interface for journeys data source.
abstract class JourneysDataSource {
  Future<List<Journey>> fetchJourneys(String userId, {int limit = 50});
  Future<Journey> saveJourney(Journey journey, String userId);
}

/// Interface for notifications data source.
abstract class NotificationsDataSource {
  Future<List<AppNotification>> fetchNotifications(String userId);
  Future<void> markAsRead(String notificationId, String userId);
  Future<void> markAllAsRead(String userId);
}

/// Interface for the routing service.
///
/// Implemented by [DemoRoutingService] and [ORSRoutingService].
abstract class RoutingService {
  /// Whether this service provides real routing calculations.
  bool get isRealRouting;

  /// Fetch route options between two points.
  Future<List<RouteOption>> fetchRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    double fuelPriceUgx = 5600,
    double consumptionPer100km = 8.5,
  });
}

/// Logging helper — logs only in debug mode.
void srLog(String tag, String message) {
  if (kDebugMode) {
    debugPrint('[$tag] $message');
  }
}
