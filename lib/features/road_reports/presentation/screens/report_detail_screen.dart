import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/services/app_providers.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.reportId});
  final String reportId;

  static Color _categoryColor(ReportCategory c) => switch (c) {
    ReportCategory.flooding => AppColors.infoBlue,
    ReportCategory.accident => AppColors.hazardRed,
    ReportCategory.closure => AppColors.hazardRed,
    ReportCategory.heavyCongestion => AppColors.cautionAmber,
    ReportCategory.roadworks => AppColors.conditionRoadworks,
    _ => AppColors.cautionAmber,
  };

  static IconData _categoryIcon(ReportCategory c) => switch (c) {
    ReportCategory.pothole => Icons.warning_amber_rounded,
    ReportCategory.flooding => Icons.water_rounded,
    ReportCategory.accident => Icons.car_crash_rounded,
    ReportCategory.roadworks => Icons.construction_rounded,
    ReportCategory.closure => Icons.block_rounded,
    ReportCategory.heavyCongestion => Icons.traffic_rounded,
    ReportCategory.dangerousCondition => Icons.dangerous_rounded,
    ReportCategory.otherHazard => Icons.report_problem_rounded,
  };

  static String _categoryLabel(ReportCategory c) => switch (c) {
    ReportCategory.pothole => 'Pothole',
    ReportCategory.flooding => 'Flooding',
    ReportCategory.accident => 'Accident / Breakdown',
    ReportCategory.roadworks => 'Roadworks',
    ReportCategory.closure => 'Road Closure',
    ReportCategory.heavyCongestion => 'Heavy Congestion',
    ReportCategory.dangerousCondition => 'Dangerous Condition',
    ReportCategory.otherHazard => 'Hazard',
  };

  static String _statusLabel(ReportStatus s) => switch (s) {
    ReportStatus.unverified => 'Unverified',
    ReportStatus.communityConfirmed => 'Community confirmed',
    ReportStatus.underReview => 'Under review',
    ReportStatus.verified => 'Verified',
    ReportStatus.resolved => 'Resolved',
    ReportStatus.expired => 'Expired',
  };

  static Color _statusColor(ReportStatus s) => switch (s) {
    ReportStatus.unverified => AppColors.cautionAmber,
    ReportStatus.communityConfirmed => AppColors.signalCyan,
    ReportStatus.underReview => AppColors.cautionAmber,
    ReportStatus.verified => AppColors.successGreen,
    ReportStatus.resolved => AppColors.lightMuted,
    ReportStatus.expired => AppColors.lightMuted,
  };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<RoadReportsProvider>();
    final report = reportsProvider.reports.cast<RoadReport?>().firstWhere(
      (r) => r?.id == reportId,
      orElse: () => null,
    );

    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report')),
        body: const SrEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Report not found',
          message: 'This report may have expired or been removed.',
        ),
      );
    }

    final color = _categoryColor(report.category);

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: Text(_categoryLabel(report.category)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // Header
          SrCard(
            padding: const EdgeInsets.all(AppDimensions.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                      ),
                      child: Icon(
                        _categoryIcon(report.category),
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _categoryLabel(report.category),
                            style: AppTypography.headingMedium(
                              color: context.colorText,
                            ),
                          ),
                          Text(
                            report.locationName,
                            style: AppTypography.bodySmall(
                              color: context.colorMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),
                SrBadge(
                  label: _statusLabel(report.status),
                  color: _statusColor(report.status),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Description
          SrCard(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What was reported',
                  style: AppTypography.headingSmall(color: context.colorText),
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  report.description,
                  style: AppTypography.bodyMedium(color: context.colorText),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Stats
          Row(
            children: [
              Expanded(
                child: SrCard(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Column(
                    children: [
                      Text(
                        '${report.confirmations}',
                        style: AppTypography.monoLarge(
                          color: AppColors.signalCyan,
                        ),
                      ),
                      Text(
                        'Confirmations',
                        style: AppTypography.caption(color: context.colorMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: SrCard(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  child: Column(
                    children: [
                      Text(
                        _timeAgo(report.reportedAt),
                        style: AppTypography.labelLarge(
                          color: context.colorText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Reported',
                        style: AppTypography.caption(color: context.colorMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // Reporter
          SrCard(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Row(
              children: [
                Container(
                  width: AppDimensions.avatarSm,
                  height: AppDimensions.avatarSm,
                  decoration: BoxDecoration(
                    color: context.colorSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: context.colorMuted,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.isAnonymous
                            ? 'Anonymous contributor'
                            : report.reporterName ?? 'Community member',
                        style: AppTypography.labelMedium(
                          color: context.colorText,
                        ),
                      ),
                      Text(
                        'Community reporter',
                        style: AppTypography.caption(color: context.colorMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // Confirm button
          SrButton(
            label: 'Confirm — Still Accurate',
            onPressed: () {
              context.read<RoadReportsProvider>().confirmReport(reportId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for confirming this report.'),
                ),
              );
            },
            icon: Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: AppDimensions.space12),
          SrButton(
            label: 'Mark as Outdated',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback recorded. Thank you.')),
              );
            },
            isSecondary: true,
            icon: Icons.remove_circle_outline_rounded,
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }
}
