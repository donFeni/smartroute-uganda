import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../features/authentication/presentation/auth_provider.dart';

/// Animated in-app splash screen shown on launch.
///
/// Displays the SmartRoute brand identity with a polished entrance sequence,
/// waits for [AuthProvider] to resolve its initial state, then navigates.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _taglineSlide;
  late final Animation<double> _loaderOpacity;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Logo: scale + fade in quickly
    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.42, curve: Curves.easeOut),
      ),
    );

    // Soft glow halo behind logo
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.18).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.1, 0.65, curve: Curves.easeOut),
      ),
    );

    // Tagline: fade + slide up after logo settles
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 0.82, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 0.82, curve: Curves.easeOutCubic),
      ),
    );

    // Loader: appears last
    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
    // Dismiss the native splash — our in-app animation is now live.
    FlutterNativeSplash.remove();
    // Allow minimum splash time for brand presentation + auth resolution.
    Future.delayed(const Duration(milliseconds: 2000), _maybeNavigate);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _maybeNavigate() {
    if (!mounted || _navigated) return;
    final auth = context.read<AuthProvider>();
    // If still resolving, wait a bit more.
    if (auth.status == AuthStatus.initial) {
      Future.delayed(const Duration(milliseconds: 300), _maybeNavigate);
      return;
    }
    _navigated = true;
    if (auth.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Logo with glow halo ────────────────────────────────────────
              SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow halo
                    Opacity(
                      opacity: _glowOpacity.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.electricLime,
                        ),
                      ),
                    ),
                    // Logo
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Image.asset(
                          'assets/brand/smartroute_original.png.png',
                          width: 108,
                          height: 108,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space12),

              // ── Brand name ─────────────────────────────────────────────────
              Opacity(
                opacity: _logoOpacity.value,
                child: Transform.translate(
                  offset: Offset(0, _taglineSlide.value * 0.5),
                  child: Text(
                    'SmartRoute Uganda',
                    style: AppTypography.headingMedium(
                      color: AppColors.cloudWhite,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.space20),

              // ── Route line divider ─────────────────────────────────────────
              Opacity(
                opacity: _taglineOpacity.value,
                child: _RouteLineDivider(),
              ),

              const SizedBox(height: AppDimensions.space20),

              // ── Tagline ────────────────────────────────────────────────────
              Opacity(
                opacity: _taglineOpacity.value,
                child: Transform.translate(
                  offset: Offset(0, _taglineSlide.value),
                  child: Column(
                    children: [
                      Text(
                        'Beyond Navigation.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge(
                          color: AppColors.cloudWhite.withValues(alpha: 0.85),
                        ),
                      ),
                      Text(
                        'Towards Smarter Mobility.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge(
                          color: AppColors.electricLime.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.space48),

              // ── Loading indicator ──────────────────────────────────────────
              Opacity(
                opacity: _loaderOpacity.value,
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.electricLime.withValues(alpha: 0.65),
                    ),
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

/// A decorative route-line divider that animates its width.
class _RouteLineDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.cloudWhite.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.electricLime,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 3),
                Container(width: 16, height: 2, color: AppColors.electricLime),
                const SizedBox(width: 3),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.signalCyan,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.cloudWhite.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: const Duration(milliseconds: 900),
          duration: const Duration(milliseconds: 400),
        );
  }
}
