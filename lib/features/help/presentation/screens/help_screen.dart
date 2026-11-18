import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/models/demo_data.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorBackground,
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.space16),
        children: [
          // ── About SmartRoute ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppDimensions.space20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.deepSpaceNavy, AppColors.graphite],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Image.asset(
                    'assets/brand/smartroute_original.png.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),
                Text(
                  'SmartRoute Uganda',
                  style: AppTypography.headingLarge(
                    color: AppColors.cloudWhite,
                  ),
                ),
                Text(
                  'Beyond Navigation. Towards Smarter Mobility.',
                  style: AppTypography.bodySmall(color: AppColors.darkMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.space8),
                Text(
                  'Version 1.0.0 (Demo)',
                  style: AppTypography.caption(color: AppColors.electricLime),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space24),

          // ── Navigation ───────────────────────────────────────────────
          ...[
            (Icons.route_rounded, 'How SmartRoute Works'),
            (Icons.report_rounded, 'Reporting Road Conditions'),
            (Icons.privacy_tip_outlined, 'Privacy Information'),
            (Icons.gavel_rounded, 'Terms of Use'),
            (Icons.contact_support_rounded, 'Contact Support'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
              child: SrCard(
                onTap: () => _showInfoSheet(context, item.$2, item.$1),
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: Row(
                  children: [
                    Icon(item.$1, color: AppColors.electricLime, size: 22),
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

          const SizedBox(height: AppDimensions.space24),
          SrSectionHeader(title: 'Frequently Asked Questions'),
          const SizedBox(height: AppDimensions.space12),

          ...DemoData.faqItems.map(
            (faq) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space8),
              child: _FaqCard(question: faq['q']!, answer: faq['a']!),
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }

  void _showInfoSheet(BuildContext context, String title, IconData icon) {
    final content = switch (title) {
      'How SmartRoute Works' => 'SmartRoute Uganda helps you compare route options based on available information including community-reported road conditions, estimated journey time and distance, and fuel cost calculations.\n\nInformation is clearly labelled as live, community-reported, or sample demonstration data.',
      'Reporting Road Conditions' => 'You can report road hazards, potholes, flooding, accidents, roadworks and congestion. Your reports are shared with the community and can be confirmed by other users.\n\nAlways ensure you are stationary and safe before submitting a report. Never operate a phone while driving.',
      'Privacy Information' => 'SmartRoute collects only the information necessary to provide the service.\n\nLocation data is used only for route planning features and is not stored without your knowledge.\n\nIn the current demonstration version, no data is transmitted to external servers.',
      'Terms of Use' => 'SmartRoute Uganda is provided as a demonstration application. All road condition information should be verified independently before acting on it.\n\nDo not rely solely on this application for safety-critical navigation decisions.',
      'Contact Support' => 'For support, feature requests or to report issues:\n\nEmail: support@smartroute.ug\nWebsite: smartroute.ug\n\nThis application is in active development. Your feedback helps improve SmartRoute Uganda.',
      _ => 'Information will be available in a future update.',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (ctx, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(AppDimensions.space24),
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.electricLime),
                const SizedBox(width: AppDimensions.space12),
                Text(
                  title,
                  style: AppTypography.headingMedium(color: context.colorText),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),
            Text(
              content,
              style: AppTypography.bodyMedium(color: context.colorText),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  const _FaqCard({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  @override
  Widget build(BuildContext context) {
    return SrCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.question,
            style: AppTypography.labelLarge(color: context.colorText),
          ),
          iconColor: AppColors.electricLime,
          collapsedIconColor: context.colorMuted,
          childrenPadding: const EdgeInsets.fromLTRB(
            AppDimensions.space16,
            0,
            AppDimensions.space16,
            AppDimensions.space16,
          ),
          children: [
            Text(
              widget.answer,
              style: AppTypography.bodyMedium(color: context.colorMuted),
            ),
          ],
        ),
      ),
    );
  }
}
