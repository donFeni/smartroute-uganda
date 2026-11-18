import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/services/app_providers.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedProvider = context.watch<SavedPlacesProvider>();
    final saved = savedProvider.savedPlaces;
    final home = savedProvider.homePlace;
    final work = savedProvider.workPlace;

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: const Text('Saved Places'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlaceSheet(context, savedProvider),
        backgroundColor: AppColors.electricLime,
        foregroundColor: AppColors.obsidian,
        child: const Icon(Icons.add_location_rounded),
      ),
      body: saved.isEmpty
          ? const SrEmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved places yet',
              message: 'Save your home, work and favourite destinations for quick access.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.space16),
              children: [
                // ── Shortcuts ───────────────────────────────────────────
                if (home != null || work != null) ...[
                  Text(
                    'Shortcuts',
                    style: AppTypography.headingSmall(color: context.colorText),
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  Row(
                    children: [
                      if (home != null)
                        Expanded(
                          child: _ShortcutCard(
                            place: home,
                            icon: Icons.home_rounded,
                            label: 'Home',
                          ),
                        ),
                      if (home != null && work != null)
                        const SizedBox(width: AppDimensions.space12),
                      if (work != null)
                        Expanded(
                          child: _ShortcutCard(
                            place: work,
                            icon: Icons.work_rounded,
                            label: 'Work',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space24),
                ],

                // ── All saved ────────────────────────────────────────────
                Text(
                  'All Saved Places',
                  style: AppTypography.headingSmall(color: context.colorText),
                ),
                const SizedBox(height: AppDimensions.space12),
                ...saved.asMap().map(
                  (i, p) => MapEntry(
                    i,
                    SrEntranceAnimation(
                      delayMs: 80 + i * 55,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.space8,
                        ),
                        child: _SavedPlaceTile(
                          place: p,
                          onNavigate: () {
                            context
                                .read<RoutePlannerProvider>()
                                .setDestination(p);
                            context.go('/routes');
                          },
                          onDelete: () => savedProvider.removePlace(p.id),
                        ),
                      ),
                    ),
                  ),
                ).values,
                const SizedBox(height: AppDimensions.space80),
              ],
            ),
    );
  }

  void _showAddPlaceSheet(
    BuildContext context,
    SavedPlacesProvider savedProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Saved Place',
                style: AppTypography.headingMedium(color: context.colorText),
              ),
              const SizedBox(height: AppDimensions.space16),
              Text(
                'In the full version, you can search and save any location. '
                'For this demo, adding "Mulago Hospital" as a sample.',
                style: AppTypography.bodyMedium(color: context.colorMuted),
              ),
              const SizedBox(height: AppDimensions.space24),
              SrButton(
                label: 'Save Demo Location',
                onPressed: () {
                  savedProvider.addPlace(
                    const PlaceModel(
                      id: 'sp_demo_added',
                      name: 'Mulago Hospital',
                      address: 'Mulago Hill, Kampala',
                      latitude: 0.3374,
                      longitude: 32.5764,
                      isFavourite: true,
                    ),
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location saved.')),
                  );
                },
                icon: Icons.add_location_rounded,
              ),
              const SizedBox(height: AppDimensions.space16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.place,
    required this.icon,
    required this.label,
  });
  final PlaceModel place;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SrCard(
      onTap: () {
        context.read<RoutePlannerProvider>().setDestination(place);
        context.go('/routes');
      },
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.electricLime, size: 24),
          const SizedBox(height: AppDimensions.space8),
          Text(
            label,
            style: AppTypography.labelLarge(color: context.colorText),
          ),
          Text(
            place.address.split(',').first,
            style: AppTypography.caption(color: context.colorMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SavedPlaceTile extends StatelessWidget {
  const _SavedPlaceTile({
    required this.place,
    required this.onNavigate,
    required this.onDelete,
  });
  final PlaceModel place;
  final VoidCallback onNavigate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final icon = place.isHome
        ? Icons.home_rounded
        : place.isWork
        ? Icons.work_rounded
        : place.isFavourite
        ? Icons.star_rounded
        : Icons.location_on_rounded;

    return SrCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space10),
            decoration: BoxDecoration(
              color: AppColors.electricLime.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, color: AppColors.electricLime, size: 20),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: AppTypography.labelLarge(color: context.colorText),
                ),
                Text(
                  place.address,
                  style: AppTypography.bodySmall(color: context.colorMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.navigation_rounded,
              color: AppColors.electricLime,
              size: 20,
            ),
            onPressed: onNavigate,
            tooltip: 'Navigate here',
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: context.colorMuted,
              size: 20,
            ),
            onPressed: onDelete,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}
