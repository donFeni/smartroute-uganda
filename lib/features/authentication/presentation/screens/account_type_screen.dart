import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.space32),
              Text(
                'How will you use\nSmartRoute?',
                style: AppTypography.displayMedium(color: context.colorText),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                'Choose the account type that best describes your use.',
                style: AppTypography.bodyMedium(color: context.colorMuted),
              ),
              const SizedBox(height: AppDimensions.space32),
              _TypeCard(
                icon: Icons.directions_car_rounded,
                title: 'Individual Driver',
                description: 'Plan personal journeys, compare routes, report road conditions and track your travel.',
                onTap: () => context.push('/signup'),
              ),
              const SizedBox(height: AppDimensions.space16),
              _TypeCard(
                icon: Icons.local_shipping_rounded,
                title: 'Transport / Fleet Business',
                description: 'Manage fleet vehicles, track journeys, monitor fuel costs and gain operational insights.',
                onTap: () => context.push('/signup'),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Already have an account? Sign in',
                    style: AppTypography.labelMedium(
                      color: AppColors.electricLime,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SrCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: BoxDecoration(
              color: AppColors.electricLime.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              icon,
              color: AppColors.electricLime,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headingSmall(color: context.colorText),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  description,
                  style: AppTypography.bodySmall(color: context.colorMuted),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: context.colorMuted,
          ),
        ],
      ),
    );
  }
}
