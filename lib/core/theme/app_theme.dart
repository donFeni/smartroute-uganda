import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'app_dimensions.dart';

/// SmartRoute Uganda theme system — light and dark.
class AppTheme {
  AppTheme._();

  // ─── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get light {
    const bg = AppColors.cloudWhite;
    const surface = AppColors.lightCard;
    const text = Color(0xFF0F1A2E);
    const muted = AppColors.lightMuted;
    const border = AppColors.lightBorder;
    const primary = AppColors.electricLime;
    const onPrimary = AppColors.obsidian;

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: const Color(0xFFE8FFB3),
      onPrimaryContainer: AppColors.obsidian,
      secondary: AppColors.signalCyan,
      onSecondary: AppColors.obsidian,
      secondaryContainer: const Color(0xFFB3F5FC),
      onSecondaryContainer: AppColors.obsidian,
      tertiary: AppColors.graphite,
      onTertiary: AppColors.pureWhite,
      tertiaryContainer: const Color(0xFFDDE4EF),
      onTertiaryContainer: text,
      error: AppColors.hazardRed,
      onError: AppColors.pureWhite,
      errorContainer: const Color(0xFFFFDADA),
      onErrorContainer: const Color(0xFF5C0000),
      surface: surface,
      onSurface: text,
      onSurfaceVariant: muted,
      outline: border,
      outlineVariant: const Color(0xFFEEF2F7),
      shadow: const Color(0x0F000000),
      scrim: const Color(0x1A000000),
      inverseSurface: AppColors.deepSpaceNavy,
      onInverseSurface: AppColors.cloudWhite,
      inversePrimary: primary,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBg: bg,
      textColor: text,
      mutedColor: muted,
      brightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    );
  }

  // ─── Dark Theme ──────────────────────────────────────────────────────────
  static ThemeData get dark {
    const bg = AppColors.obsidian;
    const surface = AppColors.darkCard;
    const text = AppColors.cloudWhite;
    const muted = AppColors.darkMuted;
    const border = AppColors.darkBorder;
    const primary = AppColors.electricLime;
    const onPrimary = AppColors.obsidian;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: const Color(0xFF2A3D10),
      onPrimaryContainer: primary,
      secondary: AppColors.signalCyan,
      onSecondary: AppColors.obsidian,
      secondaryContainer: const Color(0xFF0D3D44),
      onSecondaryContainer: AppColors.signalCyan,
      tertiary: const Color(0xFF8BAAC8),
      onTertiary: AppColors.obsidian,
      tertiaryContainer: AppColors.graphite,
      onTertiaryContainer: text,
      error: AppColors.hazardRed,
      onError: AppColors.obsidian,
      errorContainer: const Color(0xFF4A0000),
      onErrorContainer: const Color(0xFFFFB4B4),
      surface: surface,
      onSurface: text,
      onSurfaceVariant: muted,
      outline: border,
      outlineVariant: const Color(0xFF1E2D40),
      shadow: const Color(0x3D000000),
      scrim: const Color(0x4D000000),
      inverseSurface: AppColors.cloudWhite,
      onInverseSurface: AppColors.obsidian,
      inversePrimary: const Color(0xFF4A6B10),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBg: bg,
      textColor: text,
      mutedColor: muted,
      brightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );
  }

  // ─── Shared builder ───────────────────────────────────────────────────────
  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color textColor,
    required Color mutedColor,
    required Brightness brightness,
    required Brightness statusBarBrightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTheme = AppTypography.buildTextTheme(textColor, mutedColor);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headingMedium(color: textColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusBarBrightness,
          statusBarBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricLime,
          foregroundColor: AppColors.obsidian,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTypography.labelLarge(),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: AppTypography.labelLarge(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.electricLime,
          textStyle: AppTypography.labelLarge(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.pureWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.electricLime, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.hazardRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.hazardRed, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium(color: mutedColor),
        hintStyle: AppTypography.bodyMedium(color: mutedColor),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: BorderSide(color: colorScheme.outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightBorder,
        selectedColor: AppColors.electricLime,
        labelStyle: AppTypography.labelMedium(color: textColor),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space12,
          vertical: AppDimensions.space4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.pureWhite,
        selectedItemColor: AppColors.electricLime,
        unselectedItemColor: mutedColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.labelSmall(),
        unselectedLabelStyle: AppTypography.labelSmall(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.pureWhite,
        indicatorColor: AppColors.electricLime.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.electricLime, size: 24);
          }
          return IconThemeData(color: mutedColor, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall(color: AppColors.electricLime);
          }
          return AppTypography.labelSmall(color: mutedColor);
        }),
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.pureWhite,
        selectedIconTheme: const IconThemeData(
          color: AppColors.electricLime,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(color: mutedColor, size: 24),
        selectedLabelTextStyle: AppTypography.labelSmall(
          color: AppColors.electricLime,
        ),
        unselectedLabelTextStyle: AppTypography.labelSmall(color: mutedColor),
        indicatorColor: AppColors.electricLime.withValues(alpha: 0.15),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.deepSpaceNavy,
        contentTextStyle: AppTypography.bodyMedium(color: AppColors.cloudWhite),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.pureWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl),
          ),
        ),
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        elevation: 8,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.obsidian;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.electricLime;
          }
          return null;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.electricLime;
          }
          return null;
        }),
        checkColor: WidgetStateProperty.all(AppColors.obsidian),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.space4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.electricLime;
          }
          return null;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.electricLime,
        linearTrackColor: Color(0x20B6FF3B),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.electricLime,
        inactiveTrackColor: AppColors.electricLime.withValues(alpha: 0.2),
        thumbColor: AppColors.electricLime,
        overlayColor: AppColors.electricLime.withValues(alpha: 0.15),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.electricLime,
        unselectedLabelColor: mutedColor,
        labelStyle: AppTypography.labelLarge(),
        unselectedLabelStyle: AppTypography.labelMedium(),
        indicatorColor: AppColors.electricLime,
        dividerColor: colorScheme.outline,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.graphite : AppColors.deepSpaceNavy,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        textStyle: AppTypography.caption(color: AppColors.cloudWhite),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: mutedColor,
        textColor: textColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space4,
        ),
      ),
      iconTheme: IconThemeData(color: mutedColor, size: AppDimensions.iconMd),
      extensions: const [],
    );
  }
}
