import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../features/authentication/presentation/auth_provider.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class VehicleManagementScreen extends StatelessWidget {
  const VehicleManagementScreen({super.key});

  static String _categoryLabel(VehicleCategory c) => switch (c) {
    VehicleCategory.car => 'Car',
    VehicleCategory.taxi => 'Taxi',
    VehicleCategory.motorcycle => 'Motorcycle',
    VehicleCategory.deliveryVehicle => 'Delivery Vehicle',
    VehicleCategory.van => 'Van',
    VehicleCategory.truck => 'Truck',
    VehicleCategory.other => 'Other',
  };

  static IconData _categoryIcon(VehicleCategory c) => switch (c) {
    VehicleCategory.motorcycle => Icons.two_wheeler_rounded,
    VehicleCategory.truck => Icons.local_shipping_rounded,
    VehicleCategory.van => Icons.airport_shuttle_rounded,
    VehicleCategory.deliveryVehicle => Icons.delivery_dining_rounded,
    _ => Icons.directions_car_rounded,
  };

  static String _fuelLabel(FuelType f) => switch (f) {
    FuelType.petrol => 'Petrol',
    FuelType.diesel => 'Diesel',
    FuelType.electric => 'Electric',
    FuelType.hybrid => 'Hybrid',
  };

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final vehicles = user?.vehicles ?? [];

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(title: const Text('My Vehicles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVehicleSheet(context),
        backgroundColor: AppColors.electricLime,
        foregroundColor: AppColors.obsidian,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Vehicle'),
      ),
      body: vehicles.isEmpty
          ? const SrEmptyState(
              icon: Icons.directions_car_outlined,
              title: 'No vehicles added',
              message: 'Add your vehicle to get accurate fuel cost estimates.',
            )
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.space16),
              children: [
                ...vehicles.map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.space12,
                    ),
                    child: _VehicleCard(
                      vehicle: v,
                      categoryLabel: _categoryLabel(v.category),
                      categoryIcon: _categoryIcon(v.category),
                      fuelLabel: _fuelLabel(v.fuelType),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space80),
              ],
            ),
    );
  }

  void _showAddVehicleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a Vehicle',
              style: AppTypography.headingMedium(color: context.colorText),
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              'Vehicle management with persistent storage will be available when backend services are connected. '
              'Your demo profile already includes sample vehicles.',
              style: AppTypography.bodyMedium(color: context.colorMuted),
            ),
            const SizedBox(height: AppDimensions.space24),
            SrButton(
              label: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              isSecondary: true,
            ),
            const SizedBox(height: AppDimensions.space16),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.fuelLabel,
  });
  final VehicleModel vehicle;
  final String categoryLabel;
  final IconData categoryIcon;
  final String fuelLabel;

  @override
  Widget build(BuildContext context) {
    return SrCard(
      padding: const EdgeInsets.all(AppDimensions.space16),
      borderColor: vehicle.isPreferred
          ? AppColors.electricLime.withValues(alpha: 0.5)
          : null,
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
                child: Icon(
                  categoryIcon,
                  color: AppColors.signalCyan,
                  size: 22,
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
                      categoryLabel,
                      style: AppTypography.bodySmall(color: context.colorMuted),
                    ),
                  ],
                ),
              ),
              if (vehicle.isPreferred)
                SrBadge(label: 'Preferred', color: AppColors.electricLime),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          const Divider(height: 1),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              _VehicleDetail('Fuel', fuelLabel),
              _VehicleDetail(
                'Consumption',
                '${vehicle.consumptionPer100km} L / 100km',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleDetail extends StatelessWidget {
  const _VehicleDetail(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption(color: context.colorMuted)),
          Text(
            value,
            style: AppTypography.labelMedium(color: context.colorText),
          ),
        ],
      ),
    );
  }
}
