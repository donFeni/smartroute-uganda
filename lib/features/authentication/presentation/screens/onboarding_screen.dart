import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/shared_widgets.dart';

/// Onboarding screen — introduces SmartRoute Uganda to new users.
///
/// Shown once on first launch before login. Skippable.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.alt_route_rounded,
      iconColor: AppColors.electricLime,
      accentColor: AppColors.electricLime,
      title: 'Compare Your Routes',
      subtitle:
          'See multiple route options side by side. Compare estimated time, fuel cost and road conditions — before you set off.',
    ),
    _OnboardingPage(
      icon: Icons.report_problem_rounded,
      iconColor: AppColors.cautionAmber,
      accentColor: AppColors.cautionAmber,
      title: 'Community Road Reports',
      subtitle:
          'Report potholes, accidents, flooding and congestion. Your observations help the entire SmartRoute community make safer journeys.',
    ),
    _OnboardingPage(
      icon: Icons.local_gas_station_rounded,
      iconColor: AppColors.signalCyan,
      accentColor: AppColors.signalCyan,
      title: 'Estimate Your Fuel Cost',
      subtitle:
          'Enter your vehicle type and fuel price. SmartRoute calculates the estimated UGX cost for every route option.',
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      iconColor: AppColors.electricLime,
      accentColor: AppColors.electricLime,
      title: 'SmartRoute Intelligence',
      subtitle:
          'Our SmartScore weighs journey time, road conditions, reliability and fuel cost to recommend the best route for your trip.',
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() => context.go('/login');

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space16,
                AppDimensions.space16,
                AppDimensions.space16,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand mark
                  Opacity(
                    opacity: 0.6,
                    child: Image.asset(
                      'assets/brand/smartroute_original.png.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: AppTypography.labelMedium(
                        color: AppColors.cloudWhite.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(
                  duration: const Duration(milliseconds: 400),
                ),

            // ── Page view ─────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _OnboardingPageView(
                  page: _pages[i],
                  isActive: i == _currentPage,
                ),
              ),
            ),

            // ── Indicators ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.space16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space4,
                    ),
                    width: i == _currentPage ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? AppColors.electricLime
                          : AppColors.cloudWhite.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                ),
              ),
            ),

            // ── Action buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space24,
                0,
                AppDimensions.space24,
                AppDimensions.space32,
              ),
              child: Column(
                children: [
                  SrButton(
                    label: isLastPage ? 'Get Started' : 'Next',
                    onPressed: _next,
                    icon: Icons.arrow_forward_rounded,
                  ),
                  if (!isLastPage) ...[
                    const SizedBox(height: AppDimensions.space12),
                    SrButton(
                      label: 'Sign In',
                      onPressed: _finish,
                      isSecondary: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page, required this.isActive});
  final _OnboardingPage page;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with layered ring design
          _IconRings(icon: page.icon, color: page.iconColor),
          const SizedBox(height: AppDimensions.space40),

          Text(
            page.title,
            style: AppTypography.displayMedium(color: AppColors.cloudWhite),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('title_${page.title}'))
              .fadeIn(duration: const Duration(milliseconds: 350))
              .slideY(
                begin: 0.08,
                end: 0,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: AppDimensions.space16),

          Text(
            page.subtitle,
            style: AppTypography.bodyLarge(
              color: AppColors.cloudWhite.withValues(alpha: 0.68),
            ),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('sub_${page.title}'))
              .fadeIn(
                delay: const Duration(milliseconds: 80),
                duration: const Duration(milliseconds: 350),
              )
              .slideY(
                begin: 0.08,
                end: 0,
                delay: const Duration(milliseconds: 80),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              ),
        ],
      ),
    );
  }
}

/// Layered concentric ring icon display.
class _IconRings extends StatelessWidget {
  const _IconRings({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          // Middle ring
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
              color: color.withValues(alpha: 0.04),
            ),
          ),
          // Inner fill
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(icon, size: 38, color: color),
          ),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.82, 0.82),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: const Duration(milliseconds: 400));
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final String title;
  final String subtitle;
}
