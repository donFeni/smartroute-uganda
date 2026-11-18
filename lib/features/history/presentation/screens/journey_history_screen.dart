import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/services/app_providers.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class JourneyHistoryScreen extends StatelessWidget {
  const JourneyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journeyProvider = context.watch<JourneyProvider>();
    final journeys = journeyProvider.journeys;
    final fmt = NumberFormat('#,##0');
    final fmtDec = NumberFormat('#,##0.0');

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(title: const Text('Journey History')),
      body: journeys.isEmpty
          ? const SrEmptyState(
              icon: Icons.history_rounded,
              title: 'No journeys yet',
              message: 'Your completed journeys will appear here.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.space16),
              children: [
                // ── Summary row ─────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total distance',
                        value:
                            '${fmtDec.format(journeyProvider.totalDistanceKm)} km',
                        icon: Icons.straighten_rounded,
                        color: AppColors.signalCyan,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: _StatCard(
                        label: 'Est. fuel spend',
                        value:
                            'UGX ${fmt.format(journeyProvider.totalFuelCostUgx.round())}',
                        icon: Icons.local_gas_station_rounded,
                        color: AppColors.electricLime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space24),

                SrSectionHeader(title: 'Recent Journeys'),
                const SizedBox(height: AppDimensions.space12),

                ...journeys.map(
                  (j) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.space8,
                    ),
                    child: _JourneyCard(journey: j, fmt: fmt),
                  ),
                ),

                // Demo notice
                const SizedBox(height: AppDimensions.space16),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: context.colorSubtle,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Text(
                    'Sample demonstration journey data. '
                    'Real journey logging requires backend storage.',
                    style: AppTypography.caption(color: context.colorMuted),
                  ),
                ),
                const SizedBox(height: AppDimensions.space32),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppDimensions.space8),
          Text(
            value,
            style: AppTypography.headingSmall(color: context.colorText),
          ),
          Text(label, style: AppTypography.caption(color: context.colorMuted)),
        ],
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.journey, required this.fmt});
  final Journey journey;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('EEE, d MMM · h:mm a');

    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space10),
                decoration: BoxDecoration(
                  color: AppColors.signalCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.signalCyan,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${journey.origin.name} → ${journey.destination.name}',
                      style: AppTypography.labelLarge(color: context.colorText),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateFmt.format(journey.startedAt),
                      style: AppTypography.caption(color: context.colorMuted),
                    ),
                  ],
                ),
              ),
              if (journey.isDemo)
                SrBadge(label: 'Demo', color: context.colorMuted),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              _JourneyDetail(
                Icons.straighten_rounded,
                '${journey.distanceKm.toStringAsFixed(1)} km',
              ),
              _JourneyDetail(
                Icons.access_time_rounded,
                '${journey.durationMinutes} min',
              ),
              _JourneyDetail(
                Icons.local_gas_station_rounded,
                'UGX ${fmt.format(journey.fuelCostUgx.round())}',
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            journey.selectedRoute,
            style: AppTypography.bodySmall(color: context.colorMuted),
          ),
        ],
      ),
    );
  }
}

class _JourneyDetail extends StatelessWidget {
  const _JourneyDetail(this.icon, this.value);
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: context.colorMuted),
          const SizedBox(width: AppDimensions.space4),
          Flexible(
            child: Text(
              value,
              style: AppTypography.labelSmall(color: context.colorText),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
