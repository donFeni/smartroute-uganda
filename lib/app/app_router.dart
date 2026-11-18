import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/auth_provider.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/signup_screen.dart';
import '../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../features/authentication/presentation/screens/account_type_screen.dart';
import '../app/app_shell.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/route_planner/presentation/screens/route_planner_screen.dart';
import '../features/road_reports/presentation/screens/road_reports_screen.dart';
import '../features/road_reports/presentation/screens/create_report_screen.dart';
import '../features/road_reports/presentation/screens/report_detail_screen.dart';
import '../features/traffic/presentation/screens/traffic_screen.dart';
import '../features/fuel/presentation/screens/fuel_calculator_screen.dart';
import '../features/saved_places/presentation/screens/saved_places_screen.dart';
import '../features/history/presentation/screens/journey_history_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/vehicle_management_screen.dart';
import '../features/profile/presentation/screens/gamification_screen.dart';
import '../features/business/presentation/screens/business_dashboard_screen.dart';
import '../features/help/presentation/screens/help_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/navigation_session/presentation/screens/navigation_session_screen.dart';
import '../features/map/presentation/screens/map_screen.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/authentication/presentation/screens/onboarding_screen.dart';
import '../shared/models/app_models.dart';

/// Builds a [CustomTransitionPage] using a fade-through transition from the
/// [animations] package — suitable for unrelated top-level destinations.
Page<T> _fadeThroughPage<T>({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (_, animation, secondaryAnimation, child) =>
        FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Colors.transparent,
          child: child,
        ),
  );
}

/// Builds a [CustomTransitionPage] using a horizontal shared-axis transition —
/// suitable for screens with a logical forward/back relationship.
Page<T> _sharedAxisPage<T>({
  required Widget child,
  required GoRouterState state,
  SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, secondaryAnimation, child) =>
        SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
          fillColor: Colors.transparent,
          child: child,
        ),
  );
}

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isAuth = authProvider.isAuthenticated;
        final isInitial = authProvider.status == AuthStatus.initial;
        final loc = state.matchedLocation;

        final isPublicRoute =
            loc.startsWith('/login') ||
            loc.startsWith('/signup') ||
            loc.startsWith('/forgot') ||
            loc.startsWith('/account-type') ||
            loc.startsWith('/splash') ||
            loc.startsWith('/onboarding');

        if (isInitial) return null;
        if (!isAuth && !isPublicRoute) return '/login';
        if (isAuth &&
            (loc.startsWith('/login') ||
                loc.startsWith('/signup') ||
                loc.startsWith('/account-type') ||
                loc.startsWith('/onboarding'))) {
          return '/home';
        }
        return null;
      },
      routes: [
        // ─── Launch routes ─────────────────────────────────────────────────
        GoRoute(
          path: '/splash',
          pageBuilder: (ctx, state) => _fadeThroughPage(
            child: const SplashScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const OnboardingScreen(),
            state: state,
          ),
        ),

        // ─── Auth routes ───────────────────────────────────────────────────
        GoRoute(
          path: '/login',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const LoginScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const SignUpScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/forgot-password',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const ForgotPasswordScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/account-type',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const AccountTypeScreen(),
            state: state,
          ),
        ),

        // ─── Main app shell ────────────────────────────────────────────────
        ShellRoute(
          builder: (ctx, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (ctx, state) => _fadeThroughPage(
                child: const HomeScreen(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/routes',
              pageBuilder: (ctx, state) => _fadeThroughPage(
                child: const RoutePlannerScreen(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/reports',
              pageBuilder: (ctx, state) => _fadeThroughPage(
                child: const RoadReportsScreen(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/reports/create',
              pageBuilder: (ctx, state) => _sharedAxisPage(
                child: const CreateReportScreen(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/reports/:id',
              pageBuilder: (ctx, state) => _sharedAxisPage(
                child: ReportDetailScreen(
                  reportId: state.pathParameters['id'] ?? '',
                ),
                state: state,
              ),
            ),
            GoRoute(
              path: '/saved',
              pageBuilder: (ctx, state) => _fadeThroughPage(
                child: const SavedPlacesScreen(),
                state: state,
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (ctx, state) => _fadeThroughPage(
                child: const ProfileScreen(),
                state: state,
              ),
            ),
          ],
        ),

        // ─── Feature screens (no shell / full screen) ──────────────────────
        GoRoute(
          path: '/traffic',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const TrafficScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/fuel',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const FuelCalculatorScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const JourneyHistoryScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const NotificationsScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/vehicles',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const VehicleManagementScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/gamification',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const GamificationScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/business',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const BusinessDashboardScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/help',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const HelpScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (ctx, state) => _sharedAxisPage(
            child: const SettingsScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/map',
          pageBuilder: (ctx, state) => _fadeThroughPage(
            child: const MapScreen(),
            state: state,
          ),
        ),
        GoRoute(
          path: '/navigate',
          pageBuilder: (ctx, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return _sharedAxisPage(
              child: NavigationSessionScreen(
                routeOption: extra?['route'] as RouteOption?,
              ),
              state: state,
              type: SharedAxisTransitionType.scaled,
            );
          },
        ),
      ],
      errorBuilder: (ctx, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text('Page not found: ${state.matchedLocation}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ctx.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
