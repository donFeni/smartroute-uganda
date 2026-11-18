import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/map_location.dart';
import '../controllers/map_state_controller.dart';
import '../widgets/map_overlays.dart';
import '../widgets/smartroute_map.dart';
import '../../data/map_repository.dart';

/// Full-screen interactive map — accessible via the `/map` route.
///
/// Provides:
/// - Interactive OSM-backed map with zoom / pan / recenter.
/// - Location selector bottom sheet.
/// - Map legend overlay.
/// - Road-report markers (loaded from controller).
/// - Location permission banner when needed.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _showLegend = false;
  bool _showLocationSheet = false;

  static bool _isReportMarker(MapMarkerType type) {
    return type == MapMarkerType.pothole ||
        type == MapMarkerType.flooding ||
        type == MapMarkerType.accident ||
        type == MapMarkerType.roadworks ||
        type == MapMarkerType.closure ||
        type == MapMarkerType.congestion ||
        type == MapMarkerType.hazard;
  }

  @override
  void initState() {
    super.initState();
    // Check permission state passively on mount — no dialog yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapStateController>().checkLocationPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapCtrl = context.watch<MapStateController>();

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Stack(
        children: [
          // ── Full-screen map ───────────────────────────────────────────────
          Positioned.fill(
            child: SmartRouteMap(
              showControls: false,
              showAttribution: true,
              showReportMarkers: true,
              showRouteOverlay: true,
              interactionEnabled: true,
              onMapTap: (latLng) {
                mapCtrl.selectMarker(null);
                setState(() => _showLocationSheet = false);
              },
            ),
          ),

          // ── Top safe-area app bar ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space12,
                  vertical: AppDimensions.space8,
                ),
                child: Row(
                  children: [
                    // Back button
                    _MapIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onTap: () => context.pop(),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    // Search bar
                    Expanded(
                      child: _MapSearchBar(
                        onTap: () => setState(
                          () => _showLocationSheet = !_showLocationSheet,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    // Legend toggle
                    _MapIconButton(
                      icon: Icons.layers_rounded,
                      tooltip: 'Map legend',
                      isActive: _showLegend,
                      onTap: () => setState(() => _showLegend = !_showLegend),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Right-side map controls ───────────────────────────────────────
          Positioned(
            right: AppDimensions.space12,
            bottom: MediaQuery.paddingOf(context).bottom + 120,
            child: const MapControls(
              showLocationButton: true,
              showLayerToggle: false,
            ),
          ),

          // ── Location permission banner ────────────────────────────────────
          if (mapCtrl.locationError != null)
            Positioned(
              top: kToolbarHeight + MediaQuery.paddingOf(context).top + 60,
              left: AppDimensions.space16,
              right: AppDimensions.space16,
              child: LocationPermissionBanner(
                message: mapCtrl.locationError!,
                onDismiss: mapCtrl.clearLocationError,
              ),
            ),

          // ── Selected marker info card ─────────────────────────────────────
          if (mapCtrl.selectedMarker != null)
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + AppDimensions.space16,
              left: AppDimensions.space16,
              right: AppDimensions.space16,
              child: MarkerInfoCard(
                marker: mapCtrl.selectedMarker!,
                onClose: () => mapCtrl.selectMarker(null),
                onViewDetail: _isReportMarker(mapCtrl.selectedMarker!.type)
                    ? () {
                        final id = mapCtrl.selectedMarker!.payload;
                        if (id != null && id.isNotEmpty) {
                          context.push('/reports/$id');
                        }
                      }
                    : null,
              ),
            ),

          // ── Map legend overlay ────────────────────────────────────────────
          if (_showLegend)
            Positioned(
              top: kToolbarHeight + MediaQuery.paddingOf(context).top + 60,
              right: AppDimensions.space16,
              child: MapLegend(
                onClose: () => setState(() => _showLegend = false),
              ),
            ),

          // ── Demo badge (only when nothing selected and chips not shown) ────
          if (mapCtrl.selectedMarker == null && _showLocationSheet)
            Positioned(
              top: kToolbarHeight + MediaQuery.paddingOf(context).top + 60,
              left: AppDimensions.space16,
              child: _DemoBadge(),
            ),

          // ── Location selector sheet ───────────────────────────────────────
          if (_showLocationSheet)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LocationSelectorSheet(
                onClose: () => setState(() => _showLocationSheet = false),
              ),
            ),

          // ── Preset quick-navigation row (only when no marker selected) ────
          if (!_showLocationSheet && mapCtrl.selectedMarker == null)
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + AppDimensions.space8,
              left: 0,
              right: 0,
              child: _PresetChipsRow(),
            ),

          // ── Demo badge on map (bottom-left, below presets) ────────────────
          if (!_showLocationSheet && mapCtrl.selectedMarker == null)
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + 60,
              left: AppDimensions.space16,
              child: _DemoBadge(),
            ),
        ],
      ),
    );
  }
}

// ─── Map search bar ────────────────────────────────────────────────────────────

class _MapSearchBar extends StatelessWidget {
  const _MapSearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.obsidian, size: 20),
            const SizedBox(width: AppDimensions.space8),
            Text(
              'Search Kampala…',
              style: AppTypography.bodySmall(color: AppColors.lightMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Icon button overlay ───────────────────────────────────────────────────────

class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip = '',
    this.isActive = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.electricLime
                : Colors.white.withValues(alpha: 0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.obsidian : AppColors.obsidian,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ─── Demo data badge ───────────────────────────────────────────────────────────

class _DemoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space10,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.deepSpaceNavy.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: AppColors.electricLime.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 12,
            color: AppColors.electricLime,
          ),
          const SizedBox(width: AppDimensions.space4),
          Text(
            'Sample demonstration data',
            style: AppTypography.caption(color: AppColors.cloudWhite),
          ),
        ],
      ),
    );
  }
}

// ─── Preset chips row ─────────────────────────────────────────────────────────

class _PresetChipsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mapCtrl = context.watch<MapStateController>();
    final presets = MapPresets.all.take(5).toList();

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
        itemCount: presets.length,
        separatorBuilder: (_, x) =>
            const SizedBox(width: AppDimensions.space8),
        itemBuilder: (ctx, i) {
          final preset = presets[i];
          final isActive = mapCtrl.activePreset?.name == preset.name;
          return GestureDetector(
            onTap: () => mapCtrl.flyToPreset(preset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space12,
                vertical: AppDimensions.space6,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.electricLime
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                preset.name,
                style: AppTypography.labelSmall(
                  color: isActive ? AppColors.obsidian : AppColors.graphite,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
