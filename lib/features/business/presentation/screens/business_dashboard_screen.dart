import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/models/demo_data.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class BusinessDashboardScreen extends StatelessWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    final fleet = DemoData.fleetVehicleList;
    final active = fleet.where((f) => f.status == FleetStatus.enRoute).length;
    final idle = fleet.where((f) => f.status == FleetStatus.idle).length;
    final offline = fleet.where((f) => f.status == FleetStatus.offline).length;
    final totalDistance = fleet.fold(0.0, (sum, f) => sum + f.totalDistanceKm);

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: const Text('Fleet Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.space16),
            child: SrBadge(label: 'Demo Data', color: AppColors.cautionAmber),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // ── Business header ──────────────────────────────────────────
          SrCard(
            color: context.isDark ? AppColors.darkCard : AppColors.pureWhite,
            padding: const EdgeInsets.all(AppDimensions.space20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: AppColors.electricLime.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: AppColors.electricLime,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppDimensions.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kampala Logistics Ltd',
                        style: AppTypography.headingSmall(
                          color: context.colorText,
                        ),
                      ),
                      Text(
                        'Transport Business Account',
                        style: AppTypography.bodySmall(
                          color: context.colorMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // ── Fleet stats ─────────────────────────────────────────────
          SrSectionHeader(title: 'Fleet Overview'),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              Expanded(
                child: _FleetStat(
                  '${fleet.length}',
                  'Total Vehicles',
                  AppColors.signalCyan,
                  Icons.local_shipping_rounded,
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: _FleetStat(
                  '$active',
                  'En Route',
                  AppColors.successGreen,
                  Icons.navigation_rounded,
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: _FleetStat(
                  '$idle',
                  'Idle',
                  AppColors.cautionAmber,
                  Icons.pause_circle_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            children: [
              Expanded(
                child: _FleetStat(
                  '$offline',
                  'Offline',
                  context.colorMuted,
                  Icons.cloud_off_rounded,
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                flex: 2,
                child: _FleetStat(
                  '${(totalDistance / 1000).toStringAsFixed(1)}k km',
                  'Total Distance',
                  AppColors.electricLime,
                  Icons.straighten_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space24),

          // ── Vehicle list ─────────────────────────────────────────────
          SrSectionHeader(title: 'Vehicles'),
          const SizedBox(height: AppDimensions.space12),
          ...fleet.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
              child: _FleetVehicleCard(vehicle: v, fmt: fmt),
            ),
          ),

          const SizedBox(height: AppDimensions.space24),
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: context.colorSubtle,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Text(
              'Fleet tracking, real-time location and live journey monitoring '
              'require backend services and explicit driver consent. '
              'All data shown is sample demonstration data.',
              style: AppTypography.caption(color: context.colorMuted),
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }
}

class _FleetStat extends StatelessWidget {
  const _FleetStat(this.value, this.label, this.color, this.icon);
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: AppDimensions.space6),
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

class _FleetVehicleCard extends StatelessWidget {
  const _FleetVehicleCard({required this.vehicle, required this.fmt});
  final FleetVehicle vehicle;
  final NumberFormat fmt;

  static Color _statusColor(FleetStatus s) => switch (s) {
    FleetStatus.enRoute => AppColors.successGreen,
    FleetStatus.idle => AppColors.cautionAmber,
    FleetStatus.offline => AppColors.darkMuted,
  };

  static String _statusLabel(FleetStatus s) => switch (s) {
    FleetStatus.enRoute => 'En Route',
    FleetStatus.idle => 'Idle',
    FleetStatus.offline => 'Offline',
  };

  static IconData _categoryIcon(VehicleCategory c) => switch (c) {
    VehicleCategory.motorcycle => Icons.two_wheeler_rounded,
    VehicleCategory.truck => Icons.local_shipping_rounded,
    VehicleCategory.van => Icons.airport_shuttle_rounded,
    VehicleCategory.deliveryVehicle => Icons.delivery_dining_rounded,
    _ => Icons.directions_car_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(vehicle.status);

    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              _categoryIcon(vehicle.category),
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: AppTypography.labelLarge(color: context.colorText),
                ),
                Text(
                  '${vehicle.registrationId} · ${vehicle.driverName}',
                  style: AppTypography.bodySmall(color: context.colorMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SrBadge(label: _statusLabel(vehicle.status), color: statusColor),
              const SizedBox(height: AppDimensions.space4),
              Text(
                '${fmt.format(vehicle.totalDistanceKm.round())} km',
                style: AppTypography.caption(color: context.colorMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
