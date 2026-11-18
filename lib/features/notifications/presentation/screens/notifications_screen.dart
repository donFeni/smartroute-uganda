import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/services/app_providers.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationsProvider>();
    final notifications = notifProvider.notifications;

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifProvider.unreadCount > 0)
            TextButton(
              onPressed: notifProvider.markAllAsRead,
              child: Text(
                'Mark all read',
                style: AppTypography.labelMedium(color: AppColors.electricLime),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const SrEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications',
              message: 'You\'re all caught up.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.space16),
              itemCount: notifications.length,
              separatorBuilder: (_, x) =>
                  const SizedBox(height: AppDimensions.space8),
              itemBuilder: (ctx, i) {
                final n = notifications[i];
                return _NotificationTile(
                  notification: n,
                  onTap: () => notifProvider.markAsRead(n.id),
                )
                    .animate(delay: Duration(milliseconds: i * 50))
                    .fadeIn(duration: const Duration(milliseconds: 300))
                    .slideY(
                      begin: 0.05,
                      end: 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});
  final AppNotification notification;
  final VoidCallback onTap;

  static IconData _categoryIcon(NotificationCategory c) => switch (c) {
    NotificationCategory.roadCondition => Icons.traffic_rounded,
    NotificationCategory.reportConfirmation =>
      Icons.check_circle_outline_rounded,
    NotificationCategory.routeInfo => Icons.alt_route_rounded,
    NotificationCategory.accountUpdate => Icons.person_rounded,
    NotificationCategory.announcement => Icons.campaign_rounded,
  };

  static Color _categoryColor(NotificationCategory c) => switch (c) {
    NotificationCategory.roadCondition => AppColors.cautionAmber,
    NotificationCategory.reportConfirmation => AppColors.successGreen,
    NotificationCategory.routeInfo => AppColors.electricLime,
    NotificationCategory.accountUpdate => AppColors.signalCyan,
    NotificationCategory.announcement => AppColors.infoBlue,
  };

  String _timeAgo() {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final color = _categoryColor(notification.category);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.space16),
        decoration: BoxDecoration(
          color: AppColors.hazardRed.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.hazardRed,
        ),
      ),
      onDismissed: (_) => onTap(),
      child: SrCard(
        onTap: onTap,
        color: isUnread ? color.withValues(alpha: 0.04) : null,
        borderColor: isUnread
            ? color.withValues(alpha: 0.25)
            : context.colorCardBorder,
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _categoryIcon(notification.category),
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTypography.labelLarge(
                            color: context.colorText,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.electricLime,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    notification.body,
                    style: AppTypography.bodySmall(color: context.colorMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Text(
                    _timeAgo(),
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
