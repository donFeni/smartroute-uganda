import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/services/app_providers.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class TrafficScreen extends StatelessWidget {
  const TrafficScreen({super.key});

  static Color _conditionColor(TrafficCondition c) => switch (c) {
    TrafficCondition.clear || TrafficCondition.light => AppColors.successGreen,
    TrafficCondition.moderate => AppColors.cautionAmber,
    TrafficCondition.heavy || TrafficCondition.blocked => AppColors.hazardRed,
  };

  static String _conditionLabel(TrafficCondition c) => switch (c) {
    TrafficCondition.clear => 'Clear',
    TrafficCondition.light => 'Light Traffic',
    TrafficCondition.moderate => 'Moderate Congestion',
    TrafficCondition.heavy => 'Heavy Congestion',
    TrafficCondition.blocked => 'Road Blocked',
  };

  static IconData _conditionIcon(TrafficCondition c) => switch (c) {
    TrafficCondition.clear ||
    TrafficCondition.light => Icons.check_circle_rounded,
    TrafficCondition.moderate => Icons.warning_amber_rounded,
    TrafficCondition.heavy || TrafficCondition.blocked => Icons.traffic_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final traffic = context.watch<TrafficProvider>();
    final info = traffic.trafficInfo;
    final overall = traffic.overallCondition;
    final overallColor = _conditionColor(overall);

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(title: const Text('Traffic Intelligence')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // ── Overall status banner ─────────────────────────────────────
          SrEntranceAnimation(
            delayMs: 60,
            child: Container(
            padding: const EdgeInsets.all(AppDimensions.space20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  overallColor.withValues(alpha: 0.15),
                  overallColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              border: Border.all(color: overallColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: overallColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _conditionIcon(overall),
                    color: overallColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppDimensions.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kampala Area Overview',
                        style: AppTypography.headingSmall(
                          color: context.colorText,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        _conditionLabel(overall),
                        style: AppTypography.labelLarge(color: overallColor),
                      ),
                      const SizedBox(height: AppDimensions.space4),
                      Text(
                        'Sample demonstration data',
                        style: AppTypography.caption(color: context.colorMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ), // SrEntranceAnimation
          const SizedBox(height: AppDimensions.space24),

          SrSectionHeader(title: 'Area-by-Area Conditions'),
          const SizedBox(height: AppDimensions.space12),

          ...info.asMap().map(
            (i, t) => MapEntry(
              i,
              SrEntranceAnimation(
                delayMs: 180 + i * 60,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.space8),
                  child: _TrafficCard(info: t),
                ),
              ),
            ),
          ).values,

          const SizedBox(height: AppDimensions.space24),
          _ConditionLegend(),
          const SizedBox(height: AppDimensions.space24),

          // Disclaimer
          SrInfoBanner(
            message:
                'All traffic information shown is sample demonstration data. '
                'No live traffic feed is connected.',
            color: context.colorMuted,
            icon: Icons.science_outlined,
          ),
          const SizedBox(height: AppDimensions.space24),
        ],
      ),
    );
  }
}

class _TrafficCard extends StatelessWidget {
  const _TrafficCard({required this.info});
  final TrafficInfo info;

  static Color _conditionColor(TrafficCondition c) => switch (c) {
    TrafficCondition.clear || TrafficCondition.light => AppColors.successGreen,
    TrafficCondition.moderate => AppColors.cautionAmber,
    TrafficCondition.heavy || TrafficCondition.blocked => AppColors.hazardRed,
  };

  static String _conditionLabel(TrafficCondition c) => switch (c) {
    TrafficCondition.clear => 'Clear',
    TrafficCondition.light => 'Light Traffic',
    TrafficCondition.moderate => 'Moderate',
    TrafficCondition.heavy => 'Heavy',
    TrafficCondition.blocked => 'Blocked',
  };

  @override
  Widget build(BuildContext context) {
    final color = _conditionColor(info.condition);
    final diff = DateTime.now().difference(info.lastUpdated);
    final timeLabel = diff.inMinutes < 2
        ? 'Just now'
        : '${diff.inMinutes} min ago';

    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  info.areaName,
                  style: AppTypography.labelLarge(color: context.colorText),
                ),
              ),
              SrBadge(label: _conditionLabel(info.condition), color: color),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Text(
            info.description,
            style: AppTypography.bodySmall(color: context.colorMuted),
          ),
          const SizedBox(height: AppDimensions.space8),
          if (info.affectedRoads.isNotEmpty) ...[
            Wrap(
              spacing: AppDimensions.space6,
              children: info.affectedRoads
                  .map(
                    (r) => SrBadge(
                      label: r,
                      color: context.colorMuted,
                      textColor: context.colorText,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppDimensions.space8),
          ],
          Row(
            children: [
              Icon(Icons.update_rounded, size: 12, color: context.colorMuted),
              const SizedBox(width: AppDimensions.space4),
              Text(
                'Last updated: $timeLabel',
                style: AppTypography.caption(color: context.colorMuted),
              ),
              if (info.isSimulated) ...[
                const SizedBox(width: AppDimensions.space8),
                Text(
                  '· Demo data',
                  style: AppTypography.caption(color: AppColors.cautionAmber),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ConditionLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Condition Key',
            style: AppTypography.headingSmall(color: context.colorText),
          ),
          const SizedBox(height: AppDimensions.space12),
          ...[
            (AppColors.successGreen, 'Clear / Light'),
            (AppColors.cautionAmber, 'Moderate Congestion'),
            (AppColors.hazardRed, 'Heavy Congestion / Blocked'),
            (AppColors.infoBlue, 'Flooding'),
            (AppColors.conditionRoadworks, 'Roadworks'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
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
                  const SizedBox(width: AppDimensions.space12),
                  Text(
                    item.$2,
                    style: AppTypography.bodySmall(color: context.colorText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
