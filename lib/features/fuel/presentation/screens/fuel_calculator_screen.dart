import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class FuelCalculatorScreen extends StatefulWidget {
  const FuelCalculatorScreen({super.key});

  @override
  State<FuelCalculatorScreen> createState() => _FuelCalculatorScreenState();
}

class _FuelCalculatorScreenState extends State<FuelCalculatorScreen> {
  final _distanceCtrl = TextEditingController(text: '12');
  final _consumptionCtrl = TextEditingController(text: '8.5');
  final _priceCtrl = TextEditingController(text: '5600');
  FuelType _fuelType = FuelType.petrol;
  VehicleCategory _vehicleCategory = VehicleCategory.car;
  FuelEstimate? _estimate;

  static const Map<VehicleCategory, double> _defaultConsumption = {
    VehicleCategory.car: 8.5,
    VehicleCategory.taxi: 9.0,
    VehicleCategory.motorcycle: 3.5,
    VehicleCategory.van: 11.0,
    VehicleCategory.truck: 18.0,
    VehicleCategory.deliveryVehicle: 10.0,
    VehicleCategory.other: 9.0,
  };

  static const Map<VehicleCategory, String> _vehicleLabels = {
    VehicleCategory.car: 'Car',
    VehicleCategory.taxi: 'Taxi',
    VehicleCategory.motorcycle: 'Motorcycle (Boda)',
    VehicleCategory.van: 'Van',
    VehicleCategory.truck: 'Truck',
    VehicleCategory.deliveryVehicle: 'Delivery Vehicle',
    VehicleCategory.other: 'Other',
  };

  @override
  void dispose() {
    _distanceCtrl.dispose();
    _consumptionCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    final distance = double.tryParse(_distanceCtrl.text) ?? 0;
    final consumption = double.tryParse(_consumptionCtrl.text) ?? 8.5;
    final price = double.tryParse(_priceCtrl.text) ?? 5600;

    setState(() {
      _estimate = FuelEstimate(
        distanceKm: distance,
        consumptionPer100km: consumption,
        fuelPriceUgxPerLitre: price,
        fuelType: _fuelType,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    final fmtDec = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(title: const Text('Fuel Cost Estimator')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          Text(
            'Estimate your fuel cost before you travel.',
            style: AppTypography.bodyMedium(color: context.colorMuted),
          ),
          const SizedBox(height: AppDimensions.space24),

          // ── Vehicle type ────────────────────────────────────────────────
          Text(
            'Vehicle Type',
            style: AppTypography.headingSmall(color: context.colorText),
          ),
          const SizedBox(height: AppDimensions.space8),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _vehicleLabels.entries.map((e) {
                final selected = _vehicleCategory == e.key;
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.space8),
                  child: ChoiceChip(
                    label: Text(e.value),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _vehicleCategory = e.key;
                        _consumptionCtrl.text =
                            (_defaultConsumption[e.key] ?? 8.5).toString();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // ── Fuel type ────────────────────────────────────────────────────
          Text(
            'Fuel Type',
            style: AppTypography.headingSmall(color: context.colorText),
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            children: FuelType.values.map((f) {
              final label = switch (f) {
                FuelType.petrol => 'Petrol',
                FuelType.diesel => 'Diesel',
                FuelType.electric => 'Electric',
                FuelType.hybrid => 'Hybrid',
              };
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.space8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: _fuelType == f,
                  onSelected: (_) => setState(() => _fuelType = f),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.space24),

          // ── Inputs ───────────────────────────────────────────────────────
          _NumericField(
            controller: _distanceCtrl,
            label: 'Journey distance (km)',
            icon: Icons.straighten_rounded,
          ),
          const SizedBox(height: AppDimensions.space16),
          _NumericField(
            controller: _consumptionCtrl,
            label: 'Fuel consumption (L / 100 km)',
            icon: Icons.local_gas_station_rounded,
          ),
          const SizedBox(height: AppDimensions.space16),
          _NumericField(
            controller: _priceCtrl,
            label: 'Fuel price (UGX per litre)',
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: AppDimensions.space24),

          SrButton(
            label: 'Calculate',
            onPressed: _calculate,
            icon: Icons.calculate_rounded,
          ),
          const SizedBox(height: AppDimensions.space24),

          // ── Result ───────────────────────────────────────────────────────
          if (_estimate != null) ...[
            _ResultCard(estimate: _estimate!, fmt: fmt, fmtDec: fmtDec),
            const SizedBox(height: AppDimensions.space16),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: context.colorSubtle,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                'This is an estimate based on the values you entered. '
                'Actual fuel consumption varies with traffic conditions, '
                'road quality, driving style and vehicle condition.',
                style: AppTypography.caption(color: context.colorMuted),
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }
}

class _NumericField extends StatelessWidget {
  const _NumericField({
    required this.controller,
    required this.label,
    required this.icon,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.estimate,
    required this.fmt,
    required this.fmtDec,
  });
  final FuelEstimate estimate;
  final NumberFormat fmt;
  final NumberFormat fmtDec;

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
                Icons.local_gas_station_rounded,
                color: AppColors.electricLime,
              ),
              const SizedBox(width: AppDimensions.space8),
              Text(
                'Fuel Cost Estimate',
                style: AppTypography.headingSmall(color: context.colorText),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space20),

          // Big result
          Center(
            child: Column(
              children: [
                Text(
                  'UGX ${fmt.format(estimate.totalCostUgx.round())}',
                  style: AppTypography.monoLarge(color: AppColors.electricLime)
                      .copyWith(fontSize: 32, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Estimated total fuel cost',
                  style: AppTypography.caption(color: context.colorMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),
          const Divider(),
          const SizedBox(height: AppDimensions.space16),

          _ResultRow('Distance', '${estimate.distanceKm} km'),
          _ResultRow(
            'Fuel needed',
            '${fmtDec.format(estimate.litresRequired)} litres',
          ),
          _ResultRow(
            'Fuel price',
            'UGX ${fmt.format(estimate.fuelPriceUgxPerLitre.round())} / L',
          ),
          _ResultRow(
            'Cost per km',
            'UGX ${fmt.format(estimate.costPerKm.round())}',
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium(color: context.colorMuted),
          ),
          Text(
            value,
            style: AppTypography.labelLarge(color: context.colorText),
          ),
        ],
      ),
    );
  }
}
