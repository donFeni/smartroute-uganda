import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../map/presentation/controllers/map_state_controller.dart';
import '../../../map/presentation/widgets/smartroute_map.dart';

class NavigationSessionScreen extends StatefulWidget {
  const NavigationSessionScreen({super.key, this.routeOption});
  final RouteOption? routeOption;

  @override
  State<NavigationSessionScreen> createState() =>
      _NavigationSessionScreenState();
}

class _NavigationSessionScreenState extends State<NavigationSessionScreen>
    with SingleTickerProviderStateMixin {
  bool _arrived = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Load illustrative route geometry for nav session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.routeOption != null) {
        context.read<MapStateController>()
            .loadIllustrativeRoutes([widget.routeOption!]);
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _simulateArrival() {
    setState(() => _arrived = true);
    _pulseCtrl.stop();
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.routeOption;

    if (_arrived) {
      return _ArrivalScreen(route: route, onDone: () => context.go('/home'));
    }

    return Scaffold(
      backgroundColor: AppColors.deepSpaceNavy,
      body: Stack(
        children: [
          // ── Real OSM map (dark navigation view) ─────────────────────────
          Positioned.fill(
            child: SmartRouteMap(
              showControls: false,
              showAttribution: true,
              showReportMarkers: false,
              showRouteOverlay: true,
              interactionEnabled: false,
            ),
          ),
          // Darkening overlay for nav readability
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.deepSpaceNavy.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.transparent,
                      AppColors.deepSpaceNavy.withValues(alpha: 0.5),
                    ],
                    stops: const [0.0, 0.25, 0.65, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Demo mode indicator (pulsing)
          Positioned(
            top: kToolbarHeight + MediaQuery.paddingOf(context).top + 16,
            left: 0,
            right: 0,
            child: Center(
              child: ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space12,
                    vertical: AppDimensions.space6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepSpaceNavy.withValues(alpha: 0.8),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(
                      color: AppColors.electricLime.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.navigation_rounded,
                        color: AppColors.electricLime,
                        size: 14,
                      ),
                      const SizedBox(width: AppDimensions.space6),
                      Text(
                        'Demo Navigation · Illustrative route',
                        style: AppTypography.labelSmall(
                          color: AppColors.cloudWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Top bar ─────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: Row(
                  children: [
                    _NavPill(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Head north on Jinja Road',
                      distance: '0.3 km',
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.cloudWhite,
                      ),
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.darkCard.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom panel ─────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _NavBottomPanel(route: route, onArrival: _simulateArrival),
          ),
        ],
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.icon,
    required this.label,
    required this.distance,
  });
  final IconData icon;
  final String label;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.deepSpaceNavy.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: AppColors.electricLime.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.electricLime, size: 18),
          const SizedBox(width: AppDimensions.space8),
          Text(
            label,
            style: AppTypography.labelMedium(color: AppColors.cloudWhite),
          ),
          const SizedBox(width: AppDimensions.space8),
          Text(
            distance,
            style: AppTypography.labelMedium(color: AppColors.electricLime),
          ),
        ],
      ),
    );
  }
}

class _NavBottomPanel extends StatelessWidget {
  const _NavBottomPanel({this.route, required this.onArrival});
  final RouteOption? route;
  final VoidCallback onArrival;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.space20,
        AppDimensions.space20,
        AppDimensions.space20,
        AppDimensions.space20 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.deepSpaceNavy,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
        border: Border(
          top: BorderSide(color: AppColors.electricLime.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '~${route?.estimatedMinutes ?? 30} min remaining',
                      style: AppTypography.headingMedium(
                        color: AppColors.electricLime,
                      ),
                    ),
                    Text(
                      '${route?.distanceKm.toStringAsFixed(1) ?? '12.0'} km · ${route?.name ?? 'Demo Route'}',
                      style: AppTypography.bodySmall(
                        color: AppColors.darkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space12,
                  vertical: AppDimensions.space6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: AppColors.successGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'On route',
                  style: AppTypography.labelSmall(
                    color: AppColors.successGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          SrButton(
            label: 'Simulate Arrival',
            onPressed: onArrival,
            icon: Icons.flag_rounded,
          ),
        ],
      ),
    );
  }
}

class _ArrivalScreen extends StatelessWidget {
  const _ArrivalScreen({this.route, required this.onDone});
  final RouteOption? route;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSpaceNavy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.successGreen.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.successGreen.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.successGreen,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
              Text(
                'You\'ve arrived!',
                style: AppTypography.displayMedium(color: AppColors.cloudWhite),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space12),
              Text(
                'Demo journey completed.',
                style: AppTypography.bodyMedium(color: AppColors.darkMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.space48),
              if (route != null) ...[
                _SummaryStat('Route', route!.name, AppColors.cloudWhite),
                _SummaryStat(
                  'Distance',
                  '${route!.distanceKm.toStringAsFixed(1)} km',
                  AppColors.electricLime,
                ),
                _SummaryStat(
                  'Est. journey time',
                  '${route!.estimatedMinutes} min',
                  AppColors.signalCyan,
                ),
                _SummaryStat(
                  'Est. fuel cost',
                  'UGX ${(route!.fuelEstimateUgx / 1000).toStringAsFixed(1)}k',
                  AppColors.cautionAmber,
                ),
                const SizedBox(height: AppDimensions.space24),
              ],
              ElevatedButton(
                onPressed: onDone,
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.space6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium(color: AppColors.darkMuted),
          ),
          Text(value, style: AppTypography.labelLarge(color: color)),
        ],
      ),
    );
  }
}
