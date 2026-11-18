import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/services/app_providers.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../map/domain/map_location.dart';
import '../../../map/presentation/controllers/map_state_controller.dart';
import '../../../map/presentation/widgets/smartroute_map.dart';
import '../widgets/location_search_field.dart';

class RoutePlannerScreen extends StatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen> {
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  void _search(BuildContext context) {
    final planner = context.read<RoutePlannerProvider>();
    if (planner.origin == null || planner.destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a starting location and destination.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    planner.searchRoutes();
  }

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<RoutePlannerProvider>();

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: const Text('Plan a Route'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Origin / destination inputs ──────────────────────────────────
          _RouteInputPanel(
            originCtrl: _originCtrl,
            destCtrl: _destCtrl,
            planner: planner,
            onSearch: () => _search(context),
          ),

          // ── Results area ─────────────────────────────────────────────────
          Expanded(
            child: planner.isSearching
                ? _LoadingResults()
                : planner.hasResults
                ? _RouteResultsList(routes: planner.routes)
                : _EmptySearch(),
          ),
        ],
      ),
    );
  }
}

// ─── Input panel ──────────────────────────────────────────────────────────────
class _RouteInputPanel extends StatelessWidget {
  const _RouteInputPanel({
    required this.originCtrl,
    required this.destCtrl,
    required this.planner,
    required this.onSearch,
  });

  final TextEditingController originCtrl;
  final TextEditingController destCtrl;
  final RoutePlannerProvider planner;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      color: isDark ? AppColors.darkCard : AppColors.pureWhite,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.space16,
        AppDimensions.space8,
        AppDimensions.space16,
        AppDimensions.space16,
      ),
      child: Column(
        children: [
          // Origin — typed search with "use current location"
          LocationSearchField(
            controller: originCtrl,
            hint: 'Starting location',
            icon: Icons.radio_button_checked,
            iconColor: AppColors.electricLime,
            showCurrentLocation: true,
            onLocationSelected: (place) {
              context.read<RoutePlannerProvider>().setOrigin(place);
            },
          ),
          const SizedBox(height: AppDimensions.space4),

          // Swap & connector row
          Row(
            children: [
              const SizedBox(width: AppDimensions.space20),
              Container(width: 1, height: 20, color: context.colorCardBorder),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.swap_vert_rounded,
                  color: AppColors.electricLime,
                ),
                onPressed: () {
                  planner.swapLocations();
                  final tmp = originCtrl.text;
                  originCtrl.text = destCtrl.text;
                  destCtrl.text = tmp;
                },
                tooltip: 'Swap locations',
              ),
            ],
          ),

          // Destination — typed search
          LocationSearchField(
            controller: destCtrl,
            hint: 'Destination',
            icon: Icons.location_on_rounded,
            iconColor: AppColors.hazardRed,
            showCurrentLocation: false,
            onLocationSelected: (place) {
              context.read<RoutePlannerProvider>().setDestination(place);
            },
          ),

          const SizedBox(height: AppDimensions.space12),
          SrButton(
            label: 'Compare Routes',
            onPressed: onSearch,
            icon: Icons.alt_route_rounded,
          ),
        ],
      ),
    );
  }
}

// ─── Loading results ──────────────────────────────────────────────────────────
class _LoadingResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.space24),
          const CircularProgressIndicator(color: AppColors.electricLime),
          const SizedBox(height: AppDimensions.space16),
          Text(
            'Finding available routes…',
            style: AppTypography.bodyMedium(color: context.colorMuted),
          ),
          const SizedBox(height: AppDimensions.space4),
          Text(
            'Comparing road conditions and journey times',
            style: AppTypography.caption(color: context.colorMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Empty search ─────────────────────────────────────────────────────────────
class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SrEmptyState(
      icon: Icons.alt_route_rounded,
      title: 'Compare your route options',
      message: 'Enter a starting location and destination above, then tap Compare Routes.',
    );
  }
}

// ─── Route results list ───────────────────────────────────────────────────────
class _RouteResultsList extends StatelessWidget {
  const _RouteResultsList({required this.routes});
  final List<RouteOption> routes;

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<RoutePlannerProvider>();
    final selectedId = planner.selectedRoute?.id;

    // Load route geometries and place origin/destination markers.
    // Re-runs whenever selectedRoute changes to update the highlighted polyline.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final mapCtrl = context.read<MapStateController>();

      // Build geometries with correct isSelected flag from planner state.
      final geometries = routes.where((r) => r.waypoints.isNotEmpty).map((r) {
        final points =
            r.waypoints.map((wp) => LatLng(wp[0], wp[1])).toList();
        final isSelected = selectedId != null
            ? r.id == selectedId
            : r.isRecommended;
        return MapRouteGeometry(
          id: r.id,
          points: points,
          isSelected: isSelected,
          isIllustrative: !r.isFromRealRouting,
          label: r.name,
        );
      }).toList();

      mapCtrl.loadRouteGeometries(geometries);

      // Place origin/destination markers.
      if (planner.origin != null) {
        mapCtrl.setOriginMarker(_placeToMapLocation(planner.origin!));
      }
      if (planner.destination != null) {
        mapCtrl.setDestinationMarker(_placeToMapLocation(planner.destination!));
      }

      // Fit map to show full selected route geometry.
      final displayRoute = planner.selectedRoute ??
          (routes.isNotEmpty ? routes.first : null);
      if (displayRoute != null &&
          displayRoute.waypoints.length >= 2 &&
          displayRoute.isFromRealRouting) {
        mapCtrl.fitRouteGeometry(displayRoute.waypoints);
      }
    });

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      children: [
        // ── Map preview showing route polylines ──────────────────────────
        _RouteMapPreview(hasRealRouting: planner.isUsingRealRouting),
        const SizedBox(height: AppDimensions.space16),

        // Data source banner
        _DataSourceBanner(planner: planner),
        const SizedBox(height: AppDimensions.space12),
        Text(
          '${routes.length} route options found',
          style: AppTypography.headingSmall(color: context.colorText),
        ),
        const SizedBox(height: AppDimensions.space4),
        Text(
          '${planner.origin?.name ?? ''} → ${planner.destination?.name ?? ''}',
          style: AppTypography.bodySmall(color: context.colorMuted),
        ),
        const SizedBox(height: AppDimensions.space16),
        ...routes.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.space12),
            child: _RouteCard(
              route: r,
              isSelected: planner.selectedRoute?.id == r.id,
              onTap: () => context.read<RoutePlannerProvider>().selectRoute(r),
              onNavigate: () => context.push('/navigate', extra: {'route': r}),
            ),
          ),
        ),
        // SmartScore explanation
        _SmartScoreInfo(),
        const SizedBox(height: AppDimensions.space24),
      ],
    );
  }
}

// ─── Route card ───────────────────────────────────────────────────────────────
class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.isSelected,
    required this.onTap,
    required this.onNavigate,
  });

  final RouteOption route;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onNavigate;

  Color _categoryColor() => switch (route.category) {
    RouteCategory.fastest => AppColors.electricLime,
    RouteCategory.balanced => AppColors.signalCyan,
    RouteCategory.fuelEfficient => AppColors.cautionAmber,
  };

  String _categoryLabel() => switch (route.category) {
    RouteCategory.fastest => 'Fastest',
    RouteCategory.balanced => 'Recommended',
    RouteCategory.fuelEfficient => 'Shortest Distance',
  };

  IconData _categoryIcon() => switch (route.category) {
    RouteCategory.fastest => Icons.speed_rounded,
    RouteCategory.balanced => Icons.auto_awesome_rounded,
    RouteCategory.fuelEfficient => Icons.local_gas_station_rounded,
  };

  Color _trafficColor() => switch (route.trafficCondition) {
    TrafficCondition.clear || TrafficCondition.light => AppColors.successGreen,
    TrafficCondition.moderate => AppColors.cautionAmber,
    TrafficCondition.heavy || TrafficCondition.blocked => AppColors.hazardRed,
  };

  String _trafficLabel() => switch (route.trafficCondition) {
    TrafficCondition.clear => 'Clear',
    TrafficCondition.light => 'Light traffic',
    TrafficCondition.moderate => 'Moderate congestion',
    TrafficCondition.heavy => 'Heavy congestion',
    TrafficCondition.blocked => 'Road blocked',
  };

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: isSelected
            ? catColor.withValues(alpha: 0.06)
            : context.colorSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isSelected ? catColor : context.colorCardBorder,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space8,
                      vertical: AppDimensions.space4,
                    ),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_categoryIcon(), color: catColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          _categoryLabel(),
                          style: AppTypography.labelSmall(color: catColor),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (route.isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space8,
                        vertical: AppDimensions.space2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.electricLime,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Text(
                        '✦ SmartRoute Pick',
                        style: AppTypography.labelSmall(
                          color: AppColors.obsidian,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Route name
              Text(
                route.name,
                style: AppTypography.headingSmall(color: context.colorText),
              ),
              const SizedBox(height: AppDimensions.space12),

              // Key stats row
              Row(
                children: [
                  _Stat(
                    icon: Icons.access_time_rounded,
                    label: 'Est. time',
                    value: '~${route.estimatedMinutes} min',
                    color: context.colorText,
                  ),
                  _StatDivider(),
                  _Stat(
                    icon: Icons.straighten_rounded,
                    label: 'Distance',
                    value: '${route.distanceKm.toStringAsFixed(1)} km',
                    color: context.colorText,
                  ),
                  _StatDivider(),
                  _Stat(
                    icon: Icons.local_gas_station_rounded,
                    label: 'Est. fuel',
                    value:
                        'UGX ${(route.fuelEstimateUgx / 1000).toStringAsFixed(1)}k',
                    color: context.colorText,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Traffic & conditions
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _trafficColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space6),
                  Expanded(
                    child: Text(
                      _trafficLabel(),
                      style: AppTypography.labelSmall(color: _trafficColor()),
                    ),
                  ),
                  if (route.hazardCount > 0)
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 12,
                          color: AppColors.cautionAmber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${route.hazardCount} hazard${route.hazardCount > 1 ? 's' : ''}',
                          style: AppTypography.labelSmall(
                            color: AppColors.cautionAmber,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                route.roadConditionSummary,
                style: AppTypography.bodySmall(color: context.colorMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.space12),

              // SmartScore bar
              _SmartScoreBar(score: route.smartScore),
              const SizedBox(height: AppDimensions.space4),
              Text(
                route.recommendationReason,
                style: AppTypography.caption(color: context.colorMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.space12),

              // Footer
              Row(
                children: [
                  Icon(
                    Icons.update_rounded,
                    size: 11,
                    color: context.colorMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      route.dataSource,
                      style: AppTypography.caption(color: context.colorMuted),
                    ),
                  ),
                  if (isSelected)
                    TextButton.icon(
                      onPressed: onNavigate,
                      icon: const Icon(Icons.navigation_rounded, size: 14),
                      label: const Text('Start'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.electricLime,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space8,
                          vertical: AppDimensions.space4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: context.colorMuted),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.labelSmall(color: color),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTypography.caption(color: context.colorMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: context.colorCardBorder,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.space4),
    );
  }
}

class _SmartScoreBar extends StatelessWidget {
  const _SmartScoreBar({required this.score});
  final double score;

  Color _scoreColor() {
    if (score >= 85) return AppColors.successGreen;
    if (score >= 70) return AppColors.cautionAmber;
    return AppColors.hazardRed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SmartScore',
              style: AppTypography.caption(color: context.colorMuted),
            ),
            Text(
              score.toStringAsFixed(0),
              style: AppTypography.monoSmall(color: _scoreColor()),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: context.colorSubtle,
            valueColor: AlwaysStoppedAnimation(_scoreColor()),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

class _SmartScoreInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.signalCyan,
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                'How SmartScore works',
                style: AppTypography.labelMedium(color: context.colorText),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          ...[
            ('Estimated journey time', '35%', AppColors.electricLime),
            ('Road condition', '25%', AppColors.signalCyan),
            ('Reliability', '15%', AppColors.cautionAmber),
            ('Estimated fuel cost', '15%', AppColors.successGreen),
            ('Reported hazards', '10%', AppColors.hazardRed),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.$3,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: AppTypography.bodySmall(color: context.colorMuted),
                    ),
                  ),
                  Text(
                    item.$2,
                    style: AppTypography.labelSmall(color: context.colorText),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'These are configurable demonstration weights, not scientifically validated measurements.',
            style: AppTypography.caption(color: context.colorMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

MapLocation _placeToMapLocation(PlaceModel place) {
  return MapLocation(
    name: place.name,
    latitude: place.latitude,
    longitude: place.longitude,
    description: place.address,
    category: MapLocationCategory.custom,
  );
}

// ─── Route map preview ────────────────────────────────────────────────────────

class _RouteMapPreview extends StatelessWidget {
  const _RouteMapPreview({required this.hasRealRouting});
  final bool hasRealRouting;

  @override
  Widget build(BuildContext context) {
    final mapLabel = hasRealRouting
        ? 'Route from OpenRouteService'
        : 'Illustrative routes only';

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            SmartRouteMap(
              showControls: false,
              showAttribution: true,
              showReportMarkers: false,
              showRouteOverlay: true,
              interactionEnabled: true,
            ),
            // Route legend
            Positioned(
              top: AppDimensions.space10,
              left: AppDimensions.space10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space10,
                  vertical: AppDimensions.space4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.deepSpaceNavy.withValues(alpha: 0.85),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 3,
                      color: AppColors.electricLime,
                    ),
                    const SizedBox(width: AppDimensions.space4),
                    Text(
                      'Primary',
                      style: AppTypography.caption(color: AppColors.cloudWhite),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    Container(
                      width: 12,
                      height: 3,
                      color: AppColors.signalCyan,
                    ),
                    const SizedBox(width: AppDimensions.space4),
                    Text(
                      'Alternative',
                      style: AppTypography.caption(color: AppColors.cloudWhite),
                    ),
                  ],
                ),
              ),
            ),
            // Data source label — always honest
            Positioned(
              bottom: AppDimensions.space8,
              right: AppDimensions.space8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                  vertical: AppDimensions.space2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  mapLabel,
                  style: AppTypography.caption(color: AppColors.cloudWhite),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─── Data source banner ────────────────────────────────────────────────────────

class _DataSourceBanner extends StatelessWidget {
  const _DataSourceBanner({required this.planner});
  final RoutePlannerProvider planner;

  @override
  Widget build(BuildContext context) {
    // Routing error — shown when real routing failed and demo fallback used
    if (planner.routingError != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space12,
          vertical: AppDimensions.space8,
        ),
        decoration: BoxDecoration(
          color: AppColors.cautionAmber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.cautionAmber.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.cautionAmber),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: Text(
                planner.routingError!,
                style: AppTypography.caption(color: AppColors.cautionAmber),
              ),
            ),
          ],
        ),
      );
    }

    // Real routing in use
    if (planner.isUsingRealRouting) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space12,
          vertical: AppDimensions.space8,
        ),
        decoration: BoxDecoration(
          color: AppColors.successGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.successGreen),
            const SizedBox(width: AppDimensions.space8),
            Expanded(
              child: Text(
                'Route calculated by OpenRouteService · no live traffic feed.',
                style: AppTypography.caption(color: AppColors.successGreen),
              ),
            ),
          ],
        ),
      );
    }

    // Demo mode
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.cautionAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.cautionAmber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, size: 14, color: AppColors.cautionAmber),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Text(
              'Sample demonstration routes — not live calculations.',
              style: AppTypography.caption(color: AppColors.cautionAmber),
            ),
          ),
        ],
      ),
    );
  }
}
