import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/map_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../controllers/map_state_controller.dart';
import '../../data/map_repository.dart';
import '../../domain/map_location.dart';

// ─── Location selector sheet ──────────────────────────────────────────────────

class LocationSelectorSheet extends StatelessWidget {
  const LocationSelectorSheet({super.key, this.onClose});
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final mapCtrl = context.watch<MapStateController>();

    return Container(
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
        border: Border(top: BorderSide(color: context.colorCardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.space12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorCardBorder,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16),
            child: Row(
              children: [
                Text('Navigate to',
                    style: AppTypography.headingMedium(
                        color: context.colorText)),
                const Spacer(),
                if (onClose != null)
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: context.colorMuted, size: 20),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space8,
            ),
            child: _LocationSearchField(mapCtrl: mapCtrl, onClose: onClose),
          ),
          if (mapCtrl.searchResults.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: mapCtrl.searchResults.length,
                itemBuilder: (ctx, i) {
                  final loc = mapCtrl.searchResults[i];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(AppDimensions.space6),
                      decoration: BoxDecoration(
                        color: AppColors.electricLime.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: const Icon(Icons.place_rounded,
                          color: AppColors.electricLime, size: 16),
                    ),
                    title: Text(loc.name,
                        style: AppTypography.labelLarge(
                            color: context.colorText)),
                    onTap: () {
                      mapCtrl.flyToPreset(MapPreset(
                        id: loc.id ?? loc.name,
                        name: loc.name,
                        location: loc,
                        zoom: MapConfig.neighbourhoodZoom,
                      ));
                      mapCtrl.clearSearch();
                      onClose?.call();
                    },
                  );
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kampala',
                      style: AppTypography.labelSmall(
                              color: context.colorMuted)
                          .copyWith(letterSpacing: 0.5)),
                  const SizedBox(height: AppDimensions.space8),
                  _PresetGrid(
                    presets: MapPresets.kampalaArea,
                    onSelect: (p) {
                      mapCtrl.flyToPreset(p);
                      onClose?.call();
                    },
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Text('Uganda',
                      style: AppTypography.labelSmall(
                              color: context.colorMuted)
                          .copyWith(letterSpacing: 0.5)),
                  const SizedBox(height: AppDimensions.space8),
                  _PresetGrid(
                    presets: [
                      MapPresets.ugandaOverview,
                      MapPresets.entebbe,
                      MapPresets.jinja,
                      MapPresets.mukono,
                      MapPresets.mbarara,
                      MapPresets.gulu,
                      MapPresets.arua,
                    ],
                    onSelect: (p) {
                      mapCtrl.flyToPreset(p);
                      onClose?.call();
                    },
                  ),
                ],
              ),
            ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
        ],
      ),
    );
  }
}

class _LocationSearchField extends StatefulWidget {
  const _LocationSearchField(
      {required this.mapCtrl, this.onClose});
  final MapStateController mapCtrl;
  final VoidCallback? onClose;

  @override
  State<_LocationSearchField> createState() =>
      _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<_LocationSearchField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: widget.mapCtrl.searchLocations,
      decoration: InputDecoration(
        hintText: 'Search locations in Uganda…',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _ctrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _ctrl.clear();
                  widget.mapCtrl.clearSearch();
                },
              )
            : null,
      ),
    );
  }
}

class _PresetGrid extends StatelessWidget {
  const _PresetGrid({required this.presets, required this.onSelect});
  final List<MapPreset> presets;
  final void Function(MapPreset) onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.space8,
      runSpacing: AppDimensions.space8,
      children: presets.map((preset) {
        return ActionChip(
          label: Text(preset.name),
          avatar: const Icon(Icons.place_rounded, size: 14),
          onPressed: () => onSelect(preset),
          backgroundColor: context.colorSurface,
          side: BorderSide(color: context.colorCardBorder),
          labelStyle: AppTypography.labelSmall(color: context.colorText),
        );
      }).toList(),
    );
  }
}

// ─── Marker info card ─────────────────────────────────────────────────────────

class MarkerInfoCard extends StatelessWidget {
  const MarkerInfoCard({
    super.key,
    required this.marker,
    required this.onClose,
    this.onViewDetail,
  });

  final MapMarkerModel marker;
  final VoidCallback onClose;
  final VoidCallback? onViewDetail;

  static Color _markerColor(MapMarkerType type) => switch (type) {
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

  @override
  Widget build(BuildContext context) {
    final color = _markerColor(marker.type);

    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  marker.title ?? marker.location.name,
                  style: AppTypography.labelLarge(
                      color: context.colorText),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded,
                    size: 16, color: context.colorMuted),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
            ],
          ),
          if (marker.subtitle != null) ...[
            const SizedBox(height: AppDimensions.space4),
            Text(
              marker.subtitle!,
              style: AppTypography.bodySmall(color: context.colorMuted),
            ),
          ],
          if (marker.isDemo) ...[
            const SizedBox(height: AppDimensions.space4),
            Text(
              'Sample demonstration data',
              style: AppTypography.caption(color: AppColors.cautionAmber),
            ),
          ],
          Row(
            children: [
              Text(
                '${marker.location.latitude.toStringAsFixed(4)}, '
                '${marker.location.longitude.toStringAsFixed(4)}',
                style: AppTypography.monoSmall(color: context.colorMuted),
              ),
              const Spacer(),
              if (onViewDetail != null)
                TextButton(
                  onPressed: onViewDetail,
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space8,
                      vertical: AppDimensions.space4,
                    ),
                  ),
                  child: Text(
                    'View details',
                    style: AppTypography.labelSmall(
                        color: AppColors.electricLime),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Map legend ───────────────────────────────────────────────────────────────

class MapLegend extends StatelessWidget {
  const MapLegend({super.key, this.onClose});
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Map Legend',
                  style: AppTypography.headingSmall(color: context.colorText)),
              const Spacer(),
              if (onClose != null)
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 16, color: context.colorMuted),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          ...[
            (AppColors.electricLime, 'Selected route'),
            (AppColors.signalCyan, 'Alternative route'),
            (AppColors.hazardRed, 'Accident / Closure'),
            (AppColors.cautionAmber, 'Pothole / Congestion'),
            (AppColors.infoBlue, 'Flooding / Your position'),
            (AppColors.conditionRoadworks, 'Roadworks'),
          ].map(
            (item) => Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.space6),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.$1,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space10),
                  Text(item.$2,
                      style: AppTypography.bodySmall(
                          color: context.colorText)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            '* Routes show illustrative demonstration geometry.',
            style: AppTypography.caption(color: context.colorMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Location permission banner ───────────────────────────────────────────────

/// Banner displayed when location permission is denied or unavailable.
/// Renders as a plain widget — wrap in Positioned at the call site.
class LocationPermissionBanner extends StatelessWidget {
  const LocationPermissionBanner({
    super.key,
    required this.message,
    required this.onDismiss,
    this.onRequest,
  });

  final String message;
  final VoidCallback onDismiss;
  final VoidCallback? onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space8,
      ),
      decoration: BoxDecoration(
        color: AppColors.deepSpaceNavy.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.cautionAmber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_off_rounded,
            color: AppColors.cautionAmber,
            size: 16,
          ),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption(color: AppColors.cloudWhite),
            ),
          ),
          if (onRequest != null)
            TextButton(
              onPressed: onRequest,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              child: Text(
                'Enable',
                style: AppTypography.labelSmall(color: AppColors.electricLime),
              ),
            ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.darkMuted,
              size: 14,
            ),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}
