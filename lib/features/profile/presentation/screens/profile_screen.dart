import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../features/authentication/presentation/auth_provider.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _levelLabel(GamificationLevel level) => switch (level) {
    GamificationLevel.explorer => 'Explorer',
    GamificationLevel.contributor => 'Contributor',
    GamificationLevel.roadGuardian => 'Road Guardian',
    GamificationLevel.mobilityChampion => 'Mobility Champion',
  };

  int _nextLevelThreshold(GamificationLevel level) => switch (level) {
    GamificationLevel.explorer => 1000,
    GamificationLevel.contributor => 5000,
    GamificationLevel.roadGuardian => 12000,
    GamificationLevel.mobilityChampion => 25000,
  };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) return const SizedBox.shrink();

    final nextThreshold = _nextLevelThreshold(user.level);
    final progress = (user.points / nextThreshold).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // ── Profile header ───────────────────────────────────────────
          SrEntranceAnimation(
            delayMs: 60,
            child: SrCard(
            padding: const EdgeInsets.all(AppDimensions.space20),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: AppDimensions.avatarLg,
                      height: AppDimensions.avatarLg,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.electricLime.withValues(alpha: 0.15),
                        border: Border.all(
                          color: AppColors.electricLime.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user.name.substring(0, 1).toUpperCase(),
                          style: AppTypography.displayLarge(
                            color: AppColors.electricLime,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  user.name,
                  style: AppTypography.headingLarge(color: context.colorText),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  user.email,
                  style: AppTypography.bodySmall(color: context.colorMuted),
                ),
                const SizedBox(height: AppDimensions.space8),
                SrBadge(
                  label: user.isBusiness
                      ? 'Transport Business'
                      : 'Individual Driver',
                  color: AppColors.signalCyan,
                ),
                if (user.businessName != null) ...[
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    user.businessName!,
                    style: AppTypography.bodySmall(color: context.colorMuted),
                  ),
                ],
              ],
            ),
          ),
          ), // SrEntranceAnimation
          const SizedBox(height: AppDimensions.space16),

          // ── SmartRoute level & points ────────────────────────────────
          SrEntranceAnimation(
            delayMs: 120,
            child: SrCard(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SmartRoute Level',
                      style: AppTypography.headingSmall(
                        color: context.colorText,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/gamification'),
                      child: Text(
                        'View badges',
                        style: AppTypography.labelMedium(
                          color: AppColors.electricLime,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                Row(
                  children: [
                    Text(
                      _levelLabel(user.level),
                      style: AppTypography.headingMedium(
                        color: AppColors.electricLime,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${user.points} pts',
                      style: AppTypography.monoMedium(color: context.colorText),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.electricLime.withValues(
                      alpha: 0.15,
                    ),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.electricLime,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  '${user.points} / $nextThreshold pts to next level',
                  style: AppTypography.caption(color: context.colorMuted),
                ),
              ],
            ),
          ),
          ), // SrEntranceAnimation
          const SizedBox(height: AppDimensions.space16),

          // ── Quick nav ────────────────────────────────────────────────
          ...[
            (
              Icons.directions_car_rounded,
              'My Vehicles',
              '/vehicles',
              AppColors.signalCyan,
            ),
            (
              Icons.history_rounded,
              'Journey History',
              '/history',
              AppColors.electricLime,
            ),
            (
              Icons.bookmark_rounded,
              'Saved Places',
              '/saved',
              AppColors.cautionAmber,
            ),
            if (user.isBusiness)
              (
                Icons.business_rounded,
                'Fleet Dashboard',
                '/business',
                AppColors.successGreen,
              ),
            (
              Icons.emoji_events_rounded,
              'Badges & Achievements',
              '/gamification',
              AppColors.electricLime,
            ),
            (
              Icons.help_outline_rounded,
              'Help & Support',
              '/help',
              AppColors.infoBlue,
            ),
            (
              Icons.settings_rounded,
              'Settings',
              '/settings',
              context.colorMuted,
            ),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
              child: SrCard(
                onTap: () => context.push(item.$3),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space16,
                  vertical: AppDimensions.space14,
                ),
                child: Row(
                  children: [
                    Icon(item.$1, color: item.$4, size: 22),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: Text(
                        item.$2,
                        style: AppTypography.labelLarge(
                          color: context.colorText,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: context.colorMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space16),

          // Sign out
          SrButton(
            label: 'Sign Out',
            onPressed: () => auth.signOut(),
            isSecondary: true,
            icon: Icons.logout_rounded,
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }
}
