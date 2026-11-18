import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/services/app_providers.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../map/presentation/controllers/map_state_controller.dart';
import '../../../map/presentation/widgets/map_overlays.dart';
import '../../../map/presentation/widgets/smartroute_map.dart';

class RoadReportsScreen extends StatefulWidget {
  const RoadReportsScreen({super.key});

  @override
  State<RoadReportsScreen> createState() => _RoadReportsScreenState();
}

class _RoadReportsScreenState extends State<RoadReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  ReportCategory? _filter;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = context.watch<RoadReportsProvider>();
    var reports = reportsProvider.activeReports;
    if (_filter != null) {
      reports = reports.where((r) => r.category == _filter).toList();
    }

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: const Text('Road Reports'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Map View'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/create'),
        backgroundColor: AppColors.electricLime,
        foregroundColor: AppColors.obsidian,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Report'),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Feed tab ─────────────────────────────────────────────────────
          Column(
            children: [
              _FilterBar(
                selected: _filter,
                onSelected: (cat) =>
                    setState(() => _filter = _filter == cat ? null : cat),
              ),
              Expanded(
                child: reports.isEmpty
                    ? const SrEmptyState(
                        icon: Icons.report_outlined,
                        title: 'No reports',
                        message: 'No active reports match your filter. Be the first to report a road condition.',
                      )
                    : RefreshIndicator(
                        color: AppColors.electricLime,
                        onRefresh: reportsProvider.refresh,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppDimensions.space16),
                          itemCount: reports.length,
                          separatorBuilder: (_, x) =>
                              const SizedBox(height: AppDimensions.space8),
                          itemBuilder: (ctx, i) =>
                              _ReportCard(report: reports[i])
                                  .animate(
                                    delay: Duration(milliseconds: i * 55),
                                  )
                                  .fadeIn(
                                    duration: const Duration(milliseconds: 300),
                                  )
                                  .slideY(
                                    begin: 0.05,
                                    end: 0,
                                    duration:
                                        const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                  ),
                        ),
                      ),
              ),
            ],
          ),

          // ── Map view tab ──────────────────────────────────────────────────
          _ReportsMapView(reports: reports),
        ],
      ),
    );
  }
}

// ─── Filter bar ───────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});
  final ReportCategory? selected;
  final void Function(ReportCategory) onSelected;

  static const List<(ReportCategory, String, IconData)> _filters = [
    (ReportCategory.pothole, 'Pothole', Icons.warning_amber_rounded),
    (ReportCategory.flooding, 'Flooding', Icons.water_rounded),
    (ReportCategory.accident, 'Accident', Icons.car_crash_rounded),
    (ReportCategory.roadworks, 'Roadworks', Icons.construction_rounded),
    (ReportCategory.heavyCongestion, 'Congestion', Icons.traffic_rounded),
    (ReportCategory.closure, 'Closure', Icons.block_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: context.colorBackground,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space8,
        ),
        itemCount: _filters.length,
        separatorBuilder: (_, x) => const SizedBox(width: AppDimensions.space8),
        itemBuilder: (ctx, i) {
          final (cat, label, icon) = _filters[i];
          final isSelected = selected == cat;
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 12,
                  color: isSelected ? AppColors.obsidian : context.colorMuted,
                ),
                const SizedBox(width: 4),
                Text(label),
              ],
            ),
            selected: isSelected,
            onSelected: (_) => onSelected(cat),
            backgroundColor: context.colorSurface,
            selectedColor: AppColors.electricLime,
            checkmarkColor: AppColors.obsidian,
            labelStyle: AppTypography.labelSmall(
              color: isSelected ? AppColors.obsidian : context.colorText,
            ),
            side: BorderSide(color: context.colorCardBorder),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space4,
            ),
          );
        },
      ),
    );
  }
}

// ─── Report card ──────────────────────────────────────────────────────────────
class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});
  final RoadReport report;

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

  String _timeAgo() {
    final diff = DateTime.now().difference(report.reportedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(report.category);

    return SrCard(
      onTap: () => context.push('/reports/${report.id}'),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Icon(
                    _categoryIcon(report.category),
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _categoryLabel(report.category),
                        style: AppTypography.labelLarge(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _timeAgo(),
                      style: AppTypography.caption(color: context.colorMuted),
                    ),
                    const SizedBox(height: AppDimensions.space4),
                    SrBadge(
                      label: _statusLabel(report.status),
                      color: _statusColor(report.status),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              report.description,
              style: AppTypography.bodySmall(color: context.colorMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimensions.space12),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: AppColors.signalCyan,
                ),
                const SizedBox(width: AppDimensions.space4),
                Text(
                  '${report.confirmations} confirmations',
                  style: AppTypography.labelSmall(color: AppColors.signalCyan),
                ),
                const Spacer(),
                Text(
                  report.isAnonymous ? 'Anonymous' : report.reporterName ?? '',
                  style: AppTypography.caption(color: context.colorMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Real interactive map view ────────────────────────────────────────────────
class _ReportsMapView extends StatefulWidget {
  const _ReportsMapView({required this.reports});
  final List<RoadReport> reports;

  @override
  State<_ReportsMapView> createState() => _ReportsMapViewState();
}

class _ReportsMapViewState extends State<_ReportsMapView> {
  bool _markersLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_markersLoaded) {
      _markersLoaded = true;
      // Load report markers into the shared MapStateController.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<MapStateController>().loadReportMarkers(widget.reports);
        }
      });
    }
  }

  @override
  void didUpdateWidget(_ReportsMapView old) {
    super.didUpdateWidget(old);
    if (old.reports != widget.reports) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<MapStateController>().loadReportMarkers(widget.reports);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapCtrl = context.watch<MapStateController>();

    return Stack(
      children: [
        // ── Real OSM map ──────────────────────────────────────────────────
        Positioned.fill(
          child: SmartRouteMap(
            showControls: false,
            showAttribution: true,
            showReportMarkers: true,
            showRouteOverlay: false,
            interactionEnabled: true,
            onMapTap: (_) => mapCtrl.selectMarker(null),
          ),
        ),

        // ── Zoom controls ─────────────────────────────────────────────────
        const Positioned(
          right: AppDimensions.space12,
          top: AppDimensions.space12,
          child: MapControls(showLocationButton: true),
        ),

        // ── Selected marker info ──────────────────────────────────────────
        if (mapCtrl.selectedMarker != null)
          Positioned(
            bottom: AppDimensions.space16,
            left: AppDimensions.space16,
            right: AppDimensions.space16,
            child: MarkerInfoCard(
              marker: mapCtrl.selectedMarker!,
              onClose: () => mapCtrl.selectMarker(null),
              onViewDetail: mapCtrl.selectedMarker!.payload != null
                  ? () {
                      final id = mapCtrl.selectedMarker!.payload!;
                      context.push('/reports/$id');
                    }
                  : null,
            ),
          ),

        // ── Report count badge ────────────────────────────────────────────
        if (mapCtrl.selectedMarker == null)
          Positioned(
            bottom: AppDimensions.space16,
            left: AppDimensions.space16,
            right: AppDimensions.space16,
            child: SrCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space12,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.place_rounded,
                    color: AppColors.electricLime,
                    size: 18,
                  ),
                  const SizedBox(width: AppDimensions.space8),
                  Text(
                    '${widget.reports.length} active reports · Tap a pin for details',
                    style: AppTypography.labelSmall(color: context.colorText),
                  ),
                  const Spacer(),
                  Text(
                    'Sample data',
                    style: AppTypography.caption(color: context.colorMuted),
                  ),
                ],
              ),
            ),
          ),

        // ── Location error banner ─────────────────────────────────────────
        if (mapCtrl.locationError != null)
          Positioned(
            top: AppDimensions.space12,
            left: AppDimensions.space16,
            right: AppDimensions.space16 + 56,
            child: LocationPermissionBanner(
              message: mapCtrl.locationError!,
              onDismiss: mapCtrl.clearLocationError,
            ),
          ),
      ],
    );
  }
}
