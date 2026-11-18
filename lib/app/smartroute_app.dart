import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../core/services/app_providers.dart';
import '../features/authentication/presentation/auth_provider.dart';
import '../features/map/presentation/controllers/map_state_controller.dart';
import 'app_router.dart';

class SmartRouteApp extends StatefulWidget {
  const SmartRouteApp({super.key});

  @override
  State<SmartRouteApp> createState() => _SmartRouteAppState();
}

class _SmartRouteAppState extends State<SmartRouteApp> {
  late final AuthProvider _authProvider;
  late final ThemeProvider _themeProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _themeProvider = ThemeProvider();
    // Create router once — not on every theme rebuild.
    _router = AppRouter.createRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: _themeProvider),
        ChangeNotifierProvider<RoadReportsProvider>(
          create: (_) => RoadReportsProvider(),
        ),
        ChangeNotifierProvider<TrafficProvider>(
          create: (_) => TrafficProvider(),
        ),
        ChangeNotifierProvider<RoutePlannerProvider>(
          create: (_) => RoutePlannerProvider(),
        ),
        ChangeNotifierProvider<SavedPlacesProvider>(
          create: (_) => SavedPlacesProvider(),
        ),
        ChangeNotifierProvider<NotificationsProvider>(
          create: (_) => NotificationsProvider(),
        ),
        ChangeNotifierProvider<JourneyProvider>(
          create: (_) => JourneyProvider(),
        ),
        ChangeNotifierProvider<MapStateController>(
          create: (_) => MapStateController(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'SmartRoute Uganda',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
