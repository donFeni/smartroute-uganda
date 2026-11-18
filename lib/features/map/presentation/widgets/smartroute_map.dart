import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/map_config.dart';
import '../../../../core/services/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../controllers/map_state_controller.dart';
import '../../domain/map_location.dart';

/// The primary reusable SmartRoute map widget.
///
/// Wraps [FlutterMap] with OSM tiles, attribution, markers and route polylines.
/// Pass [showControls] = false for embedded preview contexts.
/// Pass [interactionEnabled] = false for static/thumbnail previews.
class SmartRouteMap extends StatelessWidget {
  const SmartRouteMap({
    super.key,
    this.showControls = true,
    this.showAttribution = true,
    this.showReportMarkers = true,
    this.showRouteOverlay = true,
    this.interactionEnabled = true,
    this.initialCenter,
    this.initialZoom,
    this.height,
    this.onMapTap,
  });

  final bool showControls;
  final bool showAttribution;
  final bool showReportMarkers;
  final bool showRouteOverlay;
  final bool interactionEnabled;
  final LatLng? initialCenter;
  final double? initialZoom;
  final double? height;
  final void Function(LatLng)? onMapTap;

  @override
  Widget build(BuildContext context) {
    final mapCtrl = context.watch<MapStateController>();
    final center = initialCenter ?? mapCtrl.center;
    final zoom = initialZoom ?? mapCtrl.zoom;

    // ── Keep report markers in sync with RoadReportsProvider ──────────────────
    // Any time the reports list changes (new report added, confirmed, refreshed),
    // the MapStateController's report markers are updated automatically.
    if (showReportMarkers) {
      final reports = context.watch<RoadReportsProvider>().activeReports;
      // Schedule the marker update after the current frame to avoid calling
      // notifyListeners() during a build pass.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          mapCtrl.loadReportMarkers(reports);
        }
      });
    }

    Widget mapWidget = FlutterMap(
      mapController: mapCtrl.mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        minZoom: MapConfig.minZoom,
        maxZoom: MapConfig.maxZoom,
        onTap: onMapTap != null
            ? (tapPos, latLng) => onMapTap!(latLng)
            : (tapPos, latLng) => mapCtrl.selectMarker(null),
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture) mapCtrl.onCameraMove(camera);
        },
        interactionOptions: InteractionOptions(
          flags: interactionEnabled
              ? InteractiveFlag.all
              : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: MapConfig.osmTileUrl,
          userAgentPackageName: 'ug.smartroute.app',
          tileDisplay: const TileDisplay.fadeIn(),
          errorTileCallback: (tile, error, trace) {
            debugPrint('Map tile load error: $error');
          },
        ),
        if (showRouteOverlay && mapCtrl.routeGeometries.isNotEmpty)
          RoutePolylineLayer(geometries: mapCtrl.routeGeometries),
        if (showReportMarkers && mapCtrl.visibleMarkers.isNotEmpty)
          MapMarkersLayer(
            markers: mapCtrl.visibleMarkers,
            onMarkerTap: mapCtrl.selectMarker,
          ),
        if (showAttribution) const MapAttributionWidget(),
      ],
    );

    if (height != null) {
      return SizedBox(height: height, child: mapWidget);
    }
    return mapWidget;
  }
}

// ─── Route polyline layer ─────────────────────────────────────────────────────

class RoutePolylineLayer extends StatelessWidget {
  const RoutePolylineLayer({super.key, required this.geometries});
  final List<MapRouteGeometry> geometries;

  @override
  Widget build(BuildContext context) {
    final polylines = geometries.map((geo) {
      return Polyline(
        points: geo.points,
        color: geo.isSelected
            ? AppColors.electricLime
            : AppColors.signalCyan.withValues(alpha: 0.7),
        strokeWidth: geo.isSelected ? 5.0 : 3.5,
        borderColor: geo.isSelected
            ? AppColors.obsidian.withValues(alpha: 0.4)
            : Colors.transparent,
        borderStrokeWidth: geo.isSelected ? 2.0 : 0,
      );
    }).toList();

    return PolylineLayer(polylines: polylines);
  }
}

// ─── Markers layer ────────────────────────────────────────────────────────────

class MapMarkersLayer extends StatelessWidget {
  const MapMarkersLayer({
    super.key,
    required this.markers,
    required this.onMarkerTap,
  });

  final List<MapMarkerModel> markers;
  final void Function(MapMarkerModel) onMarkerTap;

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: markers.map((m) {
        return Marker(
          point: m.location.latLng,
          width: 40,
          height: 40,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => onMarkerTap(m),
            child: _MarkerPin(type: m.type),
          ),
        );
      }).toList(),
    );
  }
}

class _MarkerPin extends StatelessWidget {
  const _MarkerPin({required this.type});
  final MapMarkerType type;

  Color get _color => switch (type) {
        MapMarkerType.currentPosition => AppColors.infoBlue,
        MapMarkerType.origin => AppColors.electricLime,
        MapMarkerType.destination => AppColors.hazardRed,
        MapMarkerType.pothole => AppColors.cautionAmber,
        MapMarkerType.flooding => AppColors.infoBlue,
        MapMarkerType.accident => AppColors.hazardRed,
        MapMarkerType.roadworks => AppColors.conditionRoadworks,
        MapMarkerType.closure => AppColors.conditionClosure,
        MapMarkerType.congestion => AppColors.cautionAmber,
        MapMarkerType.hazard => AppColors.hazardRed,
        MapMarkerType.savedPlace => AppColors.electricLime,
        MapMarkerType.preset => AppColors.signalCyan,
      };

  IconData get _icon => switch (type) {
        MapMarkerType.currentPosition => Icons.my_location_rounded,
        MapMarkerType.origin => Icons.radio_button_checked_rounded,
        MapMarkerType.destination => Icons.location_on_rounded,
        MapMarkerType.pothole => Icons.warning_amber_rounded,
        MapMarkerType.flooding => Icons.water_rounded,
        MapMarkerType.accident => Icons.car_crash_rounded,
        MapMarkerType.roadworks => Icons.construction_rounded,
        MapMarkerType.closure => Icons.block_rounded,
        MapMarkerType.congestion => Icons.traffic_rounded,
        MapMarkerType.hazard => Icons.report_problem_rounded,
        MapMarkerType.savedPlace => Icons.star_rounded,
        MapMarkerType.preset => Icons.place_rounded,
      };

  @override
  Widget build(BuildContext context) {
    if (type == MapMarkerType.currentPosition) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.infoBlue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.infoBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
          ),
        ],
      );
    }

    final color = _color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(_icon, color: Colors.white, size: 16),
        ),
        Container(width: 2, height: 6, color: color),
      ],
    );
  }
}

// ─── Attribution ──────────────────────────────────────────────────────────────

class MapAttributionWidget extends StatelessWidget {
  const MapAttributionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(
          right: AppDimensions.space8,
          bottom: AppDimensions.space4,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space6,
            vertical: AppDimensions.space2,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(AppDimensions.space4),
          ),
          child: Text(
            MapConfig.osmAttribution,
            style: const TextStyle(fontSize: 10, color: Color(0xFF444444)),
          ),
        ),
      ),
    );
  }
}

// ─── Map controls ─────────────────────────────────────────────────────────────

class MapControls extends StatelessWidget {
  const MapControls({
    super.key,
    this.showLocationButton = true,
    this.showLayerToggle = false,
  });

  final bool showLocationButton;
  final bool showLayerToggle;

  @override
  Widget build(BuildContext context) {
    final mapCtrl = context.watch<MapStateController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ControlButton(
          icon: Icons.add_rounded,
          onTap: mapCtrl.zoomIn,
          tooltip: 'Zoom in',
        ),
        const SizedBox(height: AppDimensions.space6),
        _ControlButton(
          icon: Icons.remove_rounded,
          onTap: mapCtrl.zoomOut,
          tooltip: 'Zoom out',
        ),
        const SizedBox(height: AppDimensions.space12),
        _ControlButton(
          icon: mapCtrl.hasCurrentPosition
              ? Icons.gps_fixed_rounded
              : Icons.home_rounded,
          onTap: mapCtrl.hasCurrentPosition
              ? mapCtrl.reCentreOnPosition
              : mapCtrl.resetToDefault,
          tooltip: mapCtrl.hasCurrentPosition
              ? 'Centre on my location'
              : 'Reset to Kampala',
        ),
        if (showLocationButton) ...[
          const SizedBox(height: AppDimensions.space6),
          _ControlButton(
            icon: mapCtrl.isLocating
                ? Icons.hourglass_top_rounded
                : Icons.my_location_rounded,
            onTap: mapCtrl.isLocating ? null : mapCtrl.locateMe,
            tooltip: 'Find my location',
            isHighlighted: mapCtrl.hasCurrentPosition,
          ),
        ],
        if (showLayerToggle) ...[
          const SizedBox(height: AppDimensions.space6),
          _ControlButton(
            icon: mapCtrl.showReportMarkers
                ? Icons.report_rounded
                : Icons.report_outlined,
            onTap: mapCtrl.toggleReportMarkers,
            tooltip: 'Toggle road reports',
            isHighlighted: mapCtrl.showReportMarkers,
          ),
        ],
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark
        ? AppColors.darkCard.withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.92);
    final iconColor = isHighlighted ? AppColors.electricLime : context.colorText;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(color: context.colorCardBorder),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
        ),
      ),
    );
  }
}
