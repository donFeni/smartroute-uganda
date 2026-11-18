import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';

/// Semantic colour helpers that adapt to the current theme.
extension AppSemanticColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get colorBackground =>
      isDark ? AppColors.obsidian : AppColors.cloudWhite;

  Color get colorSurface => isDark ? AppColors.darkCard : AppColors.lightCard;

  Color get colorCardBorder =>
      isDark ? AppColors.darkBorder : AppColors.lightBorder;

  Color get colorText =>
      isDark ? AppColors.cloudWhite : const Color(0xFF0F1A2E);

  Color get colorMuted => isDark ? AppColors.darkMuted : AppColors.lightMuted;

  Color get colorSubtle =>
      isDark ? const Color(0xFF1E2D40) : const Color(0xFFE8EEF5);

  Color get colorPrimary => AppColors.electricLime;
  Color get colorSecondary => AppColors.signalCyan;
  Color get colorError => AppColors.hazardRed;
  Color get colorSuccess => AppColors.successGreen;
  Color get colorWarning => AppColors.cautionAmber;
}

/// Quick dimension shortcuts on BuildContext.
extension LayoutExtensions on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  bool get isWide => screenWidth >= 600;
  bool get isVeryWide => screenWidth >= 900;
  EdgeInsets get safeArea => MediaQuery.paddingOf(this);
}

/// SmartRoute shared card widget with optional tap ink feedback.
class SrCard extends StatelessWidget {
  const SrCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = color ?? (isDark ? AppColors.darkCard : AppColors.lightCard);
    final border =
        borderColor ?? (isDark ? AppColors.darkBorder : AppColors.lightBorder);
    final r = radius ?? AppDimensions.radiusLg.toDouble();

    Widget inner = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: border, width: 1),
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(r),
          splashColor: AppColors.electricLime.withValues(alpha: 0.08),
          highlightColor: AppColors.electricLime.withValues(alpha: 0.04),
          child: inner,
        ),
      );
    }

    return inner;
  }
}

/// A lime accent action button with press animation.
class SrButton extends StatefulWidget {
  const SrButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.expand = true,
    this.small = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final bool expand;
  final bool small;

  @override
  State<SrButton> createState() => _SrButtonState();
}

class _SrButtonState extends State<SrButton>
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
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed != null && !widget.isLoading) {
      _pressCtrl.forward();
    }
  }

  void _onTapUp(_) => _pressCtrl.reverse();
  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final height = widget.small
        ? AppDimensions.buttonHeight * 0.78
        : AppDimensions.buttonHeight;

    final content = widget.isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.isSecondary
                    ? context.colorText
                    : AppColors.obsidian,
              ),
            ),
          )
        : Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 18,
                  color: widget.isSecondary ? context.colorText : AppColors.obsidian,
                ),
                const SizedBox(width: AppDimensions.space8),
              ],
              Text(
                widget.label,
                style: AppTypography.labelLarge(
                  color: widget.isSecondary ? context.colorText : AppColors.obsidian,
                ),
              ),
            ],
          );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: SizedBox(
          width: widget.expand ? double.infinity : null,
          height: height,
          child: widget.isSecondary
              ? OutlinedButton(
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  child: content,
                )
              : ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  child: content,
                ),
        ),
      ),
    );
  }
}

/// Small status badge widget.
class SrBadge extends StatelessWidget {
  const SrBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
  });

  final String label;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall(color: textColor ?? color),
      ),
    );
  }
}

/// Section header with optional action.
class SrSectionHeader extends StatelessWidget {
  const SrSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.headingSmall(color: context.colorText),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space8,
                vertical: AppDimensions.space4,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: AppTypography.labelMedium(color: AppColors.electricLime),
            ),
          ),
      ],
    );
  }
}

/// Shimmer-based loading placeholder using animated gradient.
class SrLoadingCard extends StatefulWidget {
  const SrLoadingCard({
    super.key,
    this.height = 80,
    this.width = double.infinity,
    this.radius,
  });

  final double height;
  final double width;
  final double? radius;

  @override
  State<SrLoadingCard> createState() => _SrLoadingCardState();
}

class _SrLoadingCardState extends State<SrLoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDark
        ? AppColors.darkCard
        : const Color(0xFFE8EDF2);
    final shimmerColor = context.isDark
        ? AppColors.darkBorder
        : const Color(0xFFF4F7FB);
    final r = widget.radius ?? AppDimensions.radiusLg.toDouble();

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          gradient: LinearGradient(
            begin: Alignment(-1 + _anim.value * 2, 0),
            end: Alignment(1 + _anim.value * 2, 0),
            colors: [baseColor, shimmerColor, shimmerColor, baseColor],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget.
class SrEmptyState extends StatelessWidget {
  const SrEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space24),
              decoration: BoxDecoration(
                color: context.colorSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppDimensions.iconXl,
                color: context.colorMuted,
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
            Text(
              title,
              style: AppTypography.headingSmall(color: context.colorText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              message,
              style: AppTypography.bodyMedium(color: context.colorMuted),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: AppDimensions.space24),
              SrButton(label: actionLabel!, onPressed: onAction, expand: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// Staggered list item entrance animation.
/// Wraps a child with a fade + upward slide that starts after [delayMs].
class SrEntranceAnimation extends StatelessWidget {
  const SrEntranceAnimation({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.durationMs = 400,
  });

  final Widget child;
  final int delayMs;
  final int durationMs;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: Duration(milliseconds: delayMs))
        .fadeIn(duration: Duration(milliseconds: durationMs), curve: Curves.easeOut)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: Duration(milliseconds: durationMs),
          curve: Curves.easeOutCubic,
        );
  }
}

/// A divider-style label for sections inside cards.
class SrCardLabel extends StatelessWidget {
  const SrCardLabel(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTypography.labelSmall(color: context.colorMuted).copyWith(
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Dot status indicator with label.
class SrStatusDot extends StatelessWidget {
  const SrStatusDot({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppDimensions.space6),
        Text(label, style: AppTypography.labelSmall(color: color)),
      ],
    );
  }
}

/// A polished info banner for status/warning messages.
class SrInfoBanner extends StatelessWidget {
  const SrInfoBanner({
    super.key,
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
