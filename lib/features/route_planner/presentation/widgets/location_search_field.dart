import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/map_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/map/domain/map_location.dart';
import '../../../../features/map/presentation/controllers/map_state_controller.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

/// A typed, editable location search field for the route planner.
///
/// Behaviour:
/// - The user types freely; input is debounced before querying Photon.
/// - A suggestion list appears beneath the field while results are available.
/// - Loading, empty and error states are shown inside the suggestion panel.
/// - Selecting a result converts the [MapLocation] to a [PlaceModel] and calls
///   [onLocationSelected] so the caller can update its state.
/// - "Use current location" appears as the first item when [showCurrentLocation]
///   is true and a GPS position is available on [MapStateController].
/// - The overlay is dismissed when the field loses focus or a result is tapped.
class LocationSearchField extends StatefulWidget {
  const LocationSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.onLocationSelected,
    this.showCurrentLocation = false,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color iconColor;

  /// Called when the user selects a result or taps "Use current location".
  final void Function(PlaceModel place) onLocationSelected;

  /// Whether to show a "Use current location" item at the top of suggestions.
  final bool showCurrentLocation;

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  final _focusNode = FocusNode();
  Timer? _debounce;
  OverlayEntry? _overlay;
  final _layerLink = LayerLink();

  // Track our own query so we can decide when to search vs. when the field
  // was just set programmatically after a selection.
  String _lastSearchedQuery = '';
  bool _suppressNextSearch = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  // ─── Focus ────────────────────────────────────────────────────────────────

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Delay removal so a tap on a suggestion item can register first.
      Future.delayed(const Duration(milliseconds: 150), _removeOverlay);
    } else if (widget.controller.text.trim().isNotEmpty) {
      _showOverlay();
    }
  }

  // ─── Text change + debounce ───────────────────────────────────────────────

  void _onTextChanged() {
    if (_suppressNextSearch) {
      _suppressNextSearch = false;
      return;
    }
    final text = widget.controller.text;
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      _removeOverlay();
      context.read<MapStateController>().clearSearch();
      return;
    }
    if (text == _lastSearchedQuery) return;
    _debounce = Timer(
      const Duration(milliseconds: MapConfig.geocodingDebounceMs),
      () => _runSearch(text),
    );
  }

  Future<void> _runSearch(String query) async {
    _lastSearchedQuery = query;
    final controller = context.read<MapStateController>();
    await controller.searchLocations(query);
    if (mounted && _focusNode.hasFocus) {
      _showOverlay();
    }
  }

  // ─── Overlay management ───────────────────────────────────────────────────

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlay = OverlayEntry(builder: (ctx) => _SuggestionOverlay(
      layerLink: _layerLink,
      mapController: context.read<MapStateController>(),
      showCurrentLocation: widget.showCurrentLocation,
      onSelected: _onResultSelected,
      onUseCurrentLocation: _onUseCurrentLocation,
    ));
    overlay.insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  // ─── Selection handlers ───────────────────────────────────────────────────

  void _onResultSelected(MapLocation location) {
    _removeOverlay();
    _debounce?.cancel();
    _suppressNextSearch = true;
    widget.controller.text = location.name;
    _lastSearchedQuery = location.name;
    context.read<MapStateController>().clearSearch();
    widget.onLocationSelected(_mapLocationToPlace(location));
    _focusNode.unfocus();
  }

  Future<void> _onUseCurrentLocation() async {
    final mapCtrl = context.read<MapStateController>();

    // If already acquiring, ignore the tap.
    if (mapCtrl.isLocating) return;

    _removeOverlay();
    _suppressNextSearch = true;
    widget.controller.text = 'Acquiring GPS…';
    _focusNode.unfocus();

    // Use existing position if already acquired; otherwise acquire now.
    if (mapCtrl.currentPosition == null) {
      await mapCtrl.locateMe();
    }

    if (!mounted) return;

    final position = mapCtrl.currentPosition;
    if (position == null) {
      // Permission denied or GPS unavailable — restore hint and show error.
      _suppressNextSearch = true;
      widget.controller.clear();
      _lastSearchedQuery = '';
      final error = mapCtrl.locationError ?? 'Could not get your location.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), duration: const Duration(seconds: 4)),
        );
      }
      return;
    }

    // Attempt a reverse geocode for a meaningful address label.
    final revLabel = await _reverseGeocode(mapCtrl, position.latitude, position.longitude);
    if (!mounted) return;

    final label = revLabel ?? 'Current location';
    _suppressNextSearch = true;
    widget.controller.text = label;
    _lastSearchedQuery = label;
    mapCtrl.clearSearch();

    widget.onLocationSelected(PlaceModel(
      id: 'current_location',
      name: label,
      address: 'GPS position',
      latitude: position.latitude,
      longitude: position.longitude,
    ));
  }

  /// Reverse-geocodes coordinates via [MapStateController.reverseGeocode].
  /// One single call triggered by a user action — compliant with Nominatim policy.
  /// Returns null on any failure — callers must handle gracefully.
  Future<String?> _reverseGeocode(
    MapStateController mapCtrl,
    double lat,
    double lng,
  ) async {
    try {
      final loc = await mapCtrl.reverseGeocode(lat, lng);
      return loc?.name;
    } catch (_) {
      return null;
    }
  }

  PlaceModel _mapLocationToPlace(MapLocation location) {
    return PlaceModel(
      id: 'geocoded_${location.latitude}_${location.longitude}',
      name: location.name,
      address: location.description ?? location.name,
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: Icon(widget.icon, color: widget.iconColor, size: 18),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: context.colorMuted,
                  ),
                  onPressed: () {
                    _suppressNextSearch = true;
                    widget.controller.clear();
                    _lastSearchedQuery = '';
                    context.read<MapStateController>().clearSearch();
                    _removeOverlay();
                  },
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (text) {
          if (text.trim().isNotEmpty) _runSearch(text);
        },
      ),
    );
  }
}

// ─── Suggestion overlay ───────────────────────────────────────────────────────

/// A positioned overlay that renders the suggestion list below the field.
/// Uses [ListenableBuilder] so it rebuilds when [MapStateController] changes.
class _SuggestionOverlay extends StatelessWidget {
  const _SuggestionOverlay({
    required this.layerLink,
    required this.mapController,
    required this.showCurrentLocation,
    required this.onSelected,
    required this.onUseCurrentLocation,
  });

  final LayerLink layerLink;
  final MapStateController mapController;
  final bool showCurrentLocation;
  final void Function(MapLocation) onSelected;
  final VoidCallback onUseCurrentLocation;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: 0,
      child: CompositedTransformFollower(
        link: layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, AppDimensions.inputHeight + AppDimensions.space4),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          color: Colors.transparent,
          child: ListenableBuilder(
            listenable: mapController,
            builder: (ctx, _) {
              return _SuggestionPanel(
                mapController: mapController,
                showCurrentLocation: showCurrentLocation,
                onSelected: onSelected,
                onUseCurrentLocation: onUseCurrentLocation,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SuggestionPanel extends StatelessWidget {
  const _SuggestionPanel({
    required this.mapController,
    required this.showCurrentLocation,
    required this.onSelected,
    required this.onUseCurrentLocation,
  });

  final MapStateController mapController;
  final bool showCurrentLocation;
  final void Function(MapLocation) onSelected;
  final VoidCallback onUseCurrentLocation;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = isDark ? AppColors.darkCard : AppColors.pureWhite;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final isSearching = mapController.isSearching;
    final results = mapController.searchResults;
    final error = mapController.geocodingError;

    final items = <Widget>[];

    // "Use current location" always appears first when enabled.
    if (showCurrentLocation) {
      items.add(_CurrentLocationItem(
        hasPosition: mapController.hasCurrentPosition,
        onTap: onUseCurrentLocation,
      ));
    }

    if (isSearching) {
      items.add(_LoadingItem());
    } else if (error != null) {
      items.add(_ErrorItem(message: error));
    } else if (results.isEmpty && !showCurrentLocation) {
      // Don't show the empty panel if we haven't searched yet.
      return const SizedBox.shrink();
    } else if (results.isEmpty) {
      items.add(_EmptyItem());
    } else {
      for (final loc in results) {
        items.add(_ResultItem(location: loc, onTap: () => onSelected(loc)));
      }
      // Attribution for Photon / OSM data.
      items.add(_AttributionFooter());
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: items,
        ),
      ),
    );
  }
}

// ─── Individual list items ────────────────────────────────────────────────────

class _CurrentLocationItem extends StatelessWidget {
  const _CurrentLocationItem({
    required this.hasPosition,
    required this.onTap,
  });

  final bool hasPosition;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space12,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.electricLime.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: const Icon(
                Icons.my_location_rounded,
                color: AppColors.electricLime,
                size: 16,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Use current location',
                    style: AppTypography.labelMedium(color: context.colorText),
                  ),
                  Text(
                    hasPosition ? 'GPS position available' : 'Tap to enable GPS',
                    style: AppTypography.caption(color: context.colorMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  const _ResultItem({required this.location, required this.onTap});

  final MapLocation location;
  final VoidCallback onTap;

  IconData _icon() => switch (location.category) {
        MapLocationCategory.city => Icons.location_city_rounded,
        MapLocationCategory.neighbourhood => Icons.holiday_village_rounded,
        MapLocationCategory.savedPlace => Icons.bookmark_rounded,
        _ => Icons.location_on_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space10,
        ),
        child: Row(
          children: [
            Icon(_icon(), size: 16, color: context.colorMuted),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    location.name,
                    style: AppTypography.labelMedium(color: context.colorText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (location.description != null &&
                      location.description!.isNotEmpty)
                    Text(
                      location.description!,
                      style: AppTypography.caption(color: context.colorMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space14,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.electricLime,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Text(
            'Searching for places…',
            style: AppTypography.bodySmall(color: context.colorMuted),
          ),
        ],
      ),
    );
  }
}

class _EmptyItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space14,
      ),
      child: Text(
        'No places found. Try a different search term.',
        style: AppTypography.bodySmall(color: context.colorMuted),
      ),
    );
  }
}

class _ErrorItem extends StatelessWidget {
  const _ErrorItem({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 14,
            color: AppColors.cautionAmber,
          ),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption(color: AppColors.cautionAmber),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributionFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space8,
      ),
      child: Text(
        'Geocoding © OpenStreetMap contributors via Photon',
        style: AppTypography.caption(
          color: context.colorMuted.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
