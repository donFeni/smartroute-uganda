import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/services/app_providers.dart';
import '../../../../features/authentication/presentation/auth_provider.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/models/demo_data.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../map/presentation/widgets/smartroute_map.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final notifications = context.watch<NotificationsProvider>();
    final traffic = context.watch<TrafficProvider>();
    final reports = context.watch<RoadReportsProvider>();

    final now = DateTime.now();
    final dayLabel = DateFormat('EEEE, d MMMM').format(now);

    return Scaffold(
      backgroundColor: context.colorBackground,
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: context.colorBackground,
            title: Row(
              children: [
                Image.asset(
                  'assets/brand/smartroute_original.png.png',
                  height: 32,
                  fit: BoxFit.contain,
                ).animate().fadeIn(duration: const Duration(milliseconds: 400)),
                const Spacer(),
                _NotificationBell(unread: notifications.unreadCount)
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 400)),
              ],
            ),
            automaticallyImplyLeading: false,
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ─── Greeting ──────────────────────────────────────────────
                SrEntranceAnimation(
                  delayMs: 60,
                  child: _GreetingCard(
                    greeting: _greeting(),
                    name: user?.name.split(' ').first ?? 'Traveller',
                    subtitle: dayLabel,
                    level: user?.level ?? GamificationLevel.explorer,
                    points: user?.points ?? 0,
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // ─── Route search card ──────────────────────────────────
                SrEntranceAnimation(
                  delayMs: 120,
                  child: _RouteSearchCard(),
                ),
                const SizedBox(height: AppDimensions.space24),

                // ─── Map preview ────────────────────────────────────────
                SrEntranceAnimation(
                  delayMs: 180,
                  child: SrSectionHeader(
                    title: 'Map Overview',
                    actionLabel: 'Open map',
                    onAction: () => context.push('/map'),
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                SrEntranceAnimation(
                  delayMs: 200,
                  child: _MapPreviewCard(),
                ),
                const SizedBox(height: AppDimensions.space24),

                // ─── Traffic overview ───────────────────────────────────
                SrEntranceAnimation(
                  delayMs: 240,
                  child: SrSectionHeader(
                    title: 'Traffic Overview',
                    actionLabel: 'View all',
                    onAction: () => context.push('/traffic'),
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                SrEntranceAnimation(
                  delayMs: 260,
                  child: _TrafficOverviewRow(trafficInfo: traffic.trafficInfo),
                ),
                const SizedBox(height: AppDimensions.space24),

                // ─── Quick actions ──────────────────────────────────────
                SrEntranceAnimation(
                  delayMs: 300,
                  child: _QuickActions(),
                ),
                const SizedBox(height: AppDimensions.space24),

                // ─── Recent reports ─────────────────────────────────────
                SrEntranceAnimation(
                  delayMs: 340,
                  child: SrSectionHeader(
                    title: 'Community Reports',
                    actionLabel: 'See all',
                    onAction: () => context.go('/reports'),
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                ...reports.activeReports.take(3).toList().asMap().map(
                  (i, r) => MapEntry(
                    i,
                    SrEntranceAnimation(
                      delayMs: 360 + i * 50,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.space8,
                        ),
                        child: _ReportTile(report: r),
                      ),
                    ),
                  ),
                ).values,
                const SizedBox(height: AppDimensions.space24),

                // ─── Saved places ───────────────────────────────────────
                SrEntranceAnimation(
                  delayMs: 400,
                  child: SrSectionHeader(
                    title: 'Saved Places',
                    actionLabel: 'Manage',
                    onAction: () => context.go('/saved'),
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                SrEntranceAnimation(
                  delayMs: 420,
                  child: _SavedPlacesRow(),
                ),
                const SizedBox(height: AppDimensions.space24),

                // ─── Recent journeys ────────────────────────────────────
                SrEntranceAnimation(
                  delayMs: 460,
                  child: SrSectionHeader(
                    title: 'Recent Journeys',
                    actionLabel: 'History',
                    onAction: () => context.push('/history'),
                  ),
                ),
                const SizedBox(height: AppDimensions.space12),
                ...DemoData.sampleJourneys
                    .take(2)
                    .toList()
                    .asMap()
                    .map(
                      (i, j) => MapEntry(
                        i,
                        SrEntranceAnimation(
                          delayMs: 480 + i * 50,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.space8,
                            ),
                            child: _JourneyTile(journey: j),
                          ),
                        ),
                      ),
                    )
                    .values,
                const SizedBox(height: AppDimensions.space24),

                // ─── Demo data disclaimer ───────────────────────────────
                SrEntranceAnimation(
                  delayMs: 520,
                  child: _DemoDisclaimer(),
                ),
                const SizedBox(height: AppDimensions.space32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Map preview card ─────────────────────────────────────────────────────────
class _MapPreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/map'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: SizedBox(
          height: 180,
          child: Stack(
            children: [
              // Real interactive map preview (interaction disabled)
              SmartRouteMap(
                showControls: false,
                showAttribution: true,
                showReportMarkers: true,
                showRouteOverlay: false,
                interactionEnabled: false,
              ),
              // Tap overlay
              Positioned.fill(
                child: Container(color: Colors.transparent),
              ),
              // Gradient overlay at bottom for readability
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ),
              // "Open map" chip
              Positioned(
                top: AppDimensions.space10,
                right: AppDimensions.space10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space10,
                    vertical: AppDimensions.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.obsidian.withValues(alpha: 0.82),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.open_in_full_rounded,
                        color: AppColors.electricLime,
                        size: 12,
                      ),
                      const SizedBox(width: AppDimensions.space4),
                      Text(
                        'Open map',
                        style: AppTypography.caption(
                          color: AppColors.cloudWhite,
                        ),
                      ),
                    ],
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

// ─── Greeting card ────────────────────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  const _GreetingCard({
    required this.greeting,
    required this.name,
    required this.subtitle,
    required this.level,
    required this.points,
  });

  final String greeting;
  final String name;
  final String subtitle;
  final GamificationLevel level;
  final int points;

  String _levelLabel() => switch (level) {
    GamificationLevel.explorer => 'Explorer',
    GamificationLevel.contributor => 'Contributor',
    GamificationLevel.roadGuardian => 'Road Guardian',
    GamificationLevel.mobilityChampion => 'Mobility Champion',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.deepSpaceNavy, const Color(0xFF1A2B3D)]
              : [const Color(0xFF0F1A2E), const Color(0xFF1A2B3D)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(
          color: AppColors.electricLime.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: AppTypography.caption(
                    color: AppColors.cloudWhite.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppDimensions.space4),
                RichText(
                  text: TextSpan(
                    text: '$greeting, ',
                    style: AppTypography.bodyLarge(color: AppColors.cloudWhite),
                    children: [
                      TextSpan(
                        text: name,
                        style: AppTypography.headingMedium(
                          color: AppColors.electricLime,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space8,
                        vertical: AppDimensions.space2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.electricLime.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                        border: Border.all(
                          color:
                              AppColors.electricLime.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 10,
                            color: AppColors.electricLime,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _levelLabel(),
                            style: AppTypography.labelSmall(
                              color: AppColors.electricLime,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    Text(
                      '${NumberFormat.compact().format(points)} pts',
                      style: AppTypography.labelSmall(
                        color: AppColors.cloudWhite.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          // Avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.electricLime.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.electricLime.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: AppColors.electricLime,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Route search card ────────────────────────────────────────────────────────
class _RouteSearchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                color: AppColors.electricLime,
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                'Plan your journey',
                style: AppTypography.headingSmall(color: context.colorText),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          // Origin
          _SearchInputDecoy(
            hint: 'Where are you starting from?',
            icon: Icons.radio_button_checked,
            iconColor: AppColors.electricLime,
            onTap: () => context.go('/routes'),
          ),
          // Connector with swap hint
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.space4,
              horizontal: AppDimensions.space16,
            ),
            child: Row(
              children: [
                Container(
                  width: 1,
                  height: 20,
                  color: context.colorCardBorder,
                ),
              ],
            ),
          ),
          // Destination
          _SearchInputDecoy(
            hint: 'Where would you like to go?',
            icon: Icons.location_on_rounded,
            iconColor: AppColors.hazardRed,
            onTap: () => context.go('/routes'),
          ),
          const SizedBox(height: AppDimensions.space16),
          SrButton(
            label: 'Compare Route Options',
            onPressed: () => context.go('/routes'),
            icon: Icons.alt_route_rounded,
          ),
        ],
      ),
    );
  }
}

class _SearchInputDecoy extends StatelessWidget {
  const _SearchInputDecoy({
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String hint;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space14,
        ),
        decoration: BoxDecoration(
          color: context.colorBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: context.colorCardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: AppDimensions.space12),
            Text(
              hint,
              style: AppTypography.bodyMedium(color: context.colorMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Traffic overview row ─────────────────────────────────────────────────────
class _TrafficOverviewRow extends StatelessWidget {
  const _TrafficOverviewRow({required this.trafficInfo});
  final List<TrafficInfo> trafficInfo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trafficInfo.length,
        separatorBuilder: (_, x) =>
            const SizedBox(width: AppDimensions.space8),
        itemBuilder: (ctx, i) {
          final info = trafficInfo[i];
          final color = _trafficColor(info.condition);
          return SizedBox(
            width: 160,
            child: SrCard(
              padding: const EdgeInsets.all(AppDimensions.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SrStatusDot(
                    color: color,
                    label: _conditionLabel(info.condition),
                  ),
                  const SizedBox(height: AppDimensions.space6),
                  Text(
                    info.areaName,
                    style: AppTypography.labelMedium(color: context.colorText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _trafficColor(TrafficCondition c) => switch (c) {
    TrafficCondition.clear => AppColors.successGreen,
    TrafficCondition.light => AppColors.successGreen,
    TrafficCondition.moderate => AppColors.cautionAmber,
    TrafficCondition.heavy => AppColors.hazardRed,
    TrafficCondition.blocked => AppColors.conditionClosure,
  };

  String _conditionLabel(TrafficCondition c) => switch (c) {
    TrafficCondition.clear => 'Clear',
    TrafficCondition.light => 'Light traffic',
    TrafficCondition.moderate => 'Moderate',
    TrafficCondition.heavy => 'Heavy',
    TrafficCondition.blocked => 'Blocked',
  };
}

// ─── Quick actions ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  static const List<_Action> _actions = [
    _Action(
      Icons.local_gas_station_rounded,
      'Fuel Cost',
      '/fuel',
      AppColors.cautionAmber,
    ),
    _Action(Icons.traffic_rounded, 'Traffic', '/traffic', AppColors.signalCyan),
    _Action(
      Icons.report_rounded,
      'Report',
      '/reports/create',
      AppColors.hazardRed,
    ),
    _Action(
      Icons.history_rounded,
      'History',
      '/history',
      AppColors.electricLime,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.headingSmall(color: context.colorText),
        ),
        const SizedBox(height: AppDimensions.space12),
        Row(
          children: _actions
              .asMap()
              .map(
                (i, a) => MapEntry(
                  i,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space4,
                      ),
                      child: _QuickActionButton(action: a)
                          .animate(
                            delay: Duration(milliseconds: 60 + i * 40),
                          )
                          .fadeIn(duration: const Duration(milliseconds: 300))
                          .scale(
                            begin: const Offset(0.88, 0.88),
                            end: const Offset(1.0, 1.0),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                          ),
                    ),
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ],
    );
  }
}

class _Action {
  const _Action(this.icon, this.label, this.route, this.color);
  final IconData icon;
  final String label;
  final String route;
  final Color color;
}

class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({required this.action});
  final _Action action;

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        context.push(widget.action.route);
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: SrCard(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.space16,
            horizontal: AppDimensions.space8,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space10),
                decoration: BoxDecoration(
                  color: widget.action.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.action.icon,
                  color: widget.action.color,
                  size: AppDimensions.iconMd,
                ),
              ),
              const SizedBox(height: AppDimensions.space6),
              Text(
                widget.action.label,
                style: AppTypography.labelSmall(color: context.colorText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Report tile ──────────────────────────────────────────────────────────────
class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});
  final RoadReport report;

  IconData _icon() => switch (report.category) {
    ReportCategory.pothole => Icons.warning_amber_rounded,
    ReportCategory.flooding => Icons.water_rounded,
    ReportCategory.accident => Icons.car_crash_rounded,
    ReportCategory.roadworks => Icons.construction_rounded,
    ReportCategory.closure => Icons.block_rounded,
    ReportCategory.heavyCongestion => Icons.traffic_rounded,
    ReportCategory.dangerousCondition => Icons.dangerous_rounded,
    ReportCategory.otherHazard => Icons.report_problem_rounded,
  };

  Color _color() => switch (report.category) {
    ReportCategory.flooding => AppColors.infoBlue,
    ReportCategory.accident => AppColors.hazardRed,
    ReportCategory.closure => AppColors.hazardRed,
    ReportCategory.heavyCongestion => AppColors.cautionAmber,
    ReportCategory.roadworks => AppColors.conditionRoadworks,
    _ => AppColors.cautionAmber,
  };

  String _categoryLabel() => switch (report.category) {
    ReportCategory.pothole => 'Pothole',
    ReportCategory.flooding => 'Flooding',
    ReportCategory.accident => 'Accident',
    ReportCategory.roadworks => 'Roadworks',
    ReportCategory.closure => 'Road Closure',
    ReportCategory.heavyCongestion => 'Heavy Congestion',
    ReportCategory.dangerousCondition => 'Dangerous Condition',
    ReportCategory.otherHazard => 'Hazard',
  };

  String _timeAgo() {
    final diff = DateTime.now().difference(report.reportedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return SrCard(
      onTap: () => context.push('/reports/${report.id}'),
      padding: const EdgeInsets.all(AppDimensions.space12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space10),
            decoration: BoxDecoration(
              color: _color().withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(_icon(), color: _color(), size: 20),
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
                        _categoryLabel(),
                        style: AppTypography.labelMedium(
                          color: context.colorText,
                        ),
                      ),
                    ),
                    Text(
                      _timeAgo(),
                      style: AppTypography.caption(color: context.colorMuted),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space2),
                Text(
                  report.locationName,
                  style: AppTypography.bodySmall(color: context.colorMuted),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.space4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 12,
                      color: AppColors.signalCyan,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${report.confirmations} confirmations',
                      style:
                          AppTypography.caption(color: AppColors.signalCyan),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Saved places row ─────────────────────────────────────────────────────────
class _SavedPlacesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedPlacesProvider>().savedPlaces;

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: saved.length,
        separatorBuilder: (_, x) =>
            const SizedBox(width: AppDimensions.space8),
        itemBuilder: (ctx, i) {
          final place = saved[i];
          final icon = place.isHome
              ? Icons.home_rounded
              : place.isWork
              ? Icons.work_rounded
              : Icons.star_rounded;

          return SrCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space12,
              vertical: AppDimensions.space12,
            ),
            onTap: () => ctx.go('/routes'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space6),
                  decoration: BoxDecoration(
                    color: AppColors.electricLime.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.electricLime,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppDimensions.space8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      place.name,
                      style: AppTypography.labelMedium(
                        color: ctx.colorText,
                      ),
                    ),
                    Text(
                      place.address.split(',').first,
                      style: AppTypography.caption(color: ctx.colorMuted),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Journey tile ─────────────────────────────────────────────────────────────
class _JourneyTile extends StatelessWidget {
  const _JourneyTile({required this.journey});
  final Journey journey;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    final dateFmt = DateFormat('EEE d MMM');

    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space12),
      child: Row(
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
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${journey.origin.name} → ${journey.destination.name}',
                  style: AppTypography.labelMedium(color: context.colorText),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.space2),
                Text(
                  dateFmt.format(journey.startedAt),
                  style: AppTypography.caption(color: context.colorMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${journey.distanceKm.toStringAsFixed(1)} km',
                style: AppTypography.labelMedium(color: context.colorText),
              ),
              Text(
                'UGX ${fmt.format(journey.fuelCostUgx)}',
                style: AppTypography.caption(color: context.colorMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Demo disclaimer ──────────────────────────────────────────────────────────
class _DemoDisclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: context.colorSubtle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: context.colorCardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.science_outlined, size: 15, color: context.colorMuted),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Text(
              'Sample demonstration data. Traffic, reports and routes shown are not live or real-time.',
              style: AppTypography.caption(color: context.colorMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notification bell ────────────────────────────────────────────────────────
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unread});
  final int unread;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => context.push('/notifications'),
          color: context.colorText,
        ),
        if (unread > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.hazardRed,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                .animate()
                .scale(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                ),
          ),
      ],
    );
  }
}
