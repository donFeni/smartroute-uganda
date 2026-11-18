import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/services/app_providers.dart';
import '../../../../shared/models/app_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _descCtrl = TextEditingController();
  ReportCategory? _category;
  int _step = 0; // 0=category, 1=details, 2=success
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  static const List<(ReportCategory, String, IconData, Color)> _categories = [
    (
      ReportCategory.pothole,
      'Pothole',
      Icons.warning_amber_rounded,
      AppColors.cautionAmber,
    ),
    (
      ReportCategory.flooding,
      'Flooding',
      Icons.water_rounded,
      AppColors.infoBlue,
    ),
    (
      ReportCategory.accident,
      'Accident / Breakdown',
      Icons.car_crash_rounded,
      AppColors.hazardRed,
    ),
    (
      ReportCategory.roadworks,
      'Roadworks',
      Icons.construction_rounded,
      AppColors.conditionRoadworks,
    ),
    (
      ReportCategory.closure,
      'Road Closure',
      Icons.block_rounded,
      AppColors.hazardRed,
    ),
    (
      ReportCategory.heavyCongestion,
      'Heavy Congestion',
      Icons.traffic_rounded,
      AppColors.cautionAmber,
    ),
    (
      ReportCategory.dangerousCondition,
      'Dangerous Condition',
      Icons.dangerous_rounded,
      AppColors.hazardRed,
    ),
    (
      ReportCategory.otherHazard,
      'Other Hazard',
      Icons.report_problem_rounded,
      AppColors.cautionAmber,
    ),
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_category == null || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final report = RoadReport(
      id: const Uuid().v4(),
      category: _category!,
      description: _descCtrl.text.trim(),
      latitude: 0.3476,
      longitude: 32.5825,
      locationName: 'Kampala (demo location)',
      reportedAt: DateTime.now(),
      status: ReportStatus.unverified,
      confirmations: 0,
      isAnonymous: _isAnonymous,
    );

    if (mounted) {
      context.read<RoadReportsProvider>().addReport(report);
      setState(() {
        _isSubmitting = false;
        _step = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(
        title: const Text('Report Road Condition'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: _step == 0
            ? _CategoryStep(
                categories: _categories,
                onSelected: (cat) => setState(() {
                  _category = cat;
                  _step = 1;
                }),
              )
            : _step == 1
            ? _DetailsStep(
                category: _category!,
                descCtrl: _descCtrl,
                isAnonymous: _isAnonymous,
                onAnonymousChanged: (v) => setState(() => _isAnonymous = v),
                onBack: () => setState(() => _step = 0),
                onSubmit: _submit,
                isSubmitting: _isSubmitting,
              )
            : _SuccessStep(
                category: _category!,
                onDone: () => context.go('/reports'),
              ),
      ),
    );
  }
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({required this.categories, required this.onSelected});

  final List<(ReportCategory, String, IconData, Color)> categories;
  final void Function(ReportCategory) onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      children: [
        Text(
          'What are you reporting?',
          style: AppTypography.headingLarge(color: context.colorText),
        ),
        const SizedBox(height: AppDimensions.space4),
        Text(
          'Select the category that best describes the issue.',
          style: AppTypography.bodyMedium(color: context.colorMuted),
        ),
        const SizedBox(height: AppDimensions.space24),
        ...categories.map((item) {
          final (cat, label, icon, color) = item;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.space8),
            child: SrCard(
              onTap: () => onSelected(cat),
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.space16),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.labelLarge(color: context.colorText),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: context.colorMuted,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.category,
    required this.descCtrl,
    required this.isAnonymous,
    required this.onAnonymousChanged,
    required this.onBack,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final ReportCategory category;
  final TextEditingController descCtrl;
  final bool isAnonymous;
  final void Function(bool) onAnonymousChanged;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Describe the issue',
            style: AppTypography.headingLarge(color: context.colorText),
          ),
          const SizedBox(height: AppDimensions.space4),
          Text(
            'Help others by describing what you observed.',
            style: AppTypography.bodyMedium(color: context.colorMuted),
          ),
          const SizedBox(height: AppDimensions.space24),
          TextField(
            controller: descCtrl,
            maxLines: 4,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Describe the road condition — location, severity, what you observed…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          SrCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space8,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.electricLime,
                  size: 18,
                ),
                const SizedBox(width: AppDimensions.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: AppTypography.labelMedium(
                          color: context.colorText,
                        ),
                      ),
                      Text(
                        'Using demo location — Kampala Central',
                        style: AppTypography.caption(color: context.colorMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              Switch(value: isAnonymous, onChanged: onAnonymousChanged),
              const SizedBox(width: AppDimensions.space8),
              Expanded(
                child: Text(
                  'Submit anonymously',
                  style: AppTypography.bodyMedium(color: context.colorText),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: SrButton(
                  label: 'Back',
                  onPressed: onBack,
                  isSecondary: true,
                ),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: SrButton(
                  label: 'Submit Report',
                  onPressed: onSubmit,
                  isLoading: isSubmitting,
                  icon: Icons.send_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space8),
        ],
      ),
    );
  }
}

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({required this.category, required this.onDone});
  final ReportCategory category;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.successGreen.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.successGreen,
                size: 56,
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            Text(
              'Report submitted!',
              style: AppTypography.headingLarge(color: context.colorText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              'Thank you for helping the SmartRoute community.\nYour report is now visible to other motorists.',
              style: AppTypography.bodyMedium(color: context.colorMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              '+50 SmartRoute points awarded.',
              style: AppTypography.labelMedium(color: AppColors.electricLime),
            ),
            const SizedBox(height: AppDimensions.space32),
            SrButton(label: 'View All Reports', onPressed: onDone),
          ],
        ),
      ),
    );
  }
}
