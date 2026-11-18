import 'package:flutter/material.dart' hide Badge;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/models/demo_data.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = DemoData.allBadges;
    final user = DemoData.demoUser;

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(title: const Text('Badges & Achievements')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // ── Points summary ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppDimensions.space20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.deepSpaceNavy, AppColors.graphite],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.electricLime,
                  size: 40,
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  '${user.points}',
                  style: AppTypography.displayLarge(
                    color: AppColors.electricLime,
                  ),
                ),
                Text(
                  'SmartRoute Points',
                  style: AppTypography.bodyMedium(color: AppColors.cloudWhite),
                ),
                const SizedBox(height: AppDimensions.space8),
                _LevelBadge(level: user.level),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          SrSectionHeader(title: 'How to earn points'),
          const SizedBox(height: AppDimensions.space12),
          ...[
            (Icons.report_rounded, 'Submit a road report', '+50 pts'),
            (Icons.check_circle_rounded, 'Your report confirmed', '+25 pts'),
            (Icons.thumb_up_rounded, 'Confirm another\'s report', '+10 pts'),
            (Icons.local_fire_department_rounded, '7-day streak', '+200 pts'),
            (Icons.directions_car_rounded, 'Complete a journey', '+30 pts'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
              child: SrCard(
                padding: const EdgeInsets.all(AppDimensions.space12),
                child: Row(
                  children: [
                    Icon(item.$1, color: AppColors.electricLime, size: 18),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Text(
                        item.$2,
                        style: AppTypography.bodyMedium(
                          color: context.colorText,
                        ),
                      ),
                    ),
                    Text(
                      item.$3,
                      style: AppTypography.labelMedium(
                        color: AppColors.electricLime,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space24),
          SrSectionHeader(title: 'Your Badges'),
          const SizedBox(height: AppDimensions.space12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: AppDimensions.space12,
              mainAxisSpacing: AppDimensions.space12,
            ),
            itemCount: badges.length,
            itemBuilder: (ctx, i) => _BadgeCard(badge: badges[i]),
          ),

          const SizedBox(height: AppDimensions.space24),
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: context.colorSubtle,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Text(
              'SmartRoute Points and badges are engagement indicators. '
              'They encourage responsible community participation '
              'and do not carry monetary value.',
              style: AppTypography.caption(color: context.colorMuted),
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});
  final GamificationLevel level;

  String _label() => switch (level) {
    GamificationLevel.explorer => 'Explorer',
    GamificationLevel.contributor => 'Contributor',
    GamificationLevel.roadGuardian => 'Road Guardian',
    GamificationLevel.mobilityChampion => 'Mobility Champion',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: AppColors.electricLime.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: AppColors.electricLime.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        _label(),
        style: AppTypography.labelMedium(color: AppColors.electricLime),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badge});
  final Badge badge;

  @override
  Widget build(BuildContext context) {
    return SrCard(
      color: badge.isUnlocked
          ? AppColors.electricLime.withValues(alpha: 0.06)
          : null,
      borderColor: badge.isUnlocked
          ? AppColors.electricLime.withValues(alpha: 0.3)
          : context.colorCardBorder,
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.icon,
            style: TextStyle(
              fontSize: 28,
              color: badge.isUnlocked ? null : null,
            ),
          ),
          const SizedBox(height: AppDimensions.space6),
          Text(
            badge.name,
            style: AppTypography.labelMedium(
              color: badge.isUnlocked ? context.colorText : context.colorMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!badge.isUnlocked)
            Container(
              margin: const EdgeInsets.only(top: AppDimensions.space4),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space6,
                vertical: AppDimensions.space2,
              ),
              decoration: BoxDecoration(
                color: context.colorSubtle,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                'Locked',
                style: AppTypography.caption(color: context.colorMuted),
              ),
            ),
        ],
      ),
    );
  }
}
