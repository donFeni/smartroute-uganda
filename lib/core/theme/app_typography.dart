import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SmartRoute Uganda typography system.
/// Space Grotesk: headings | Inter: body | JetBrains Mono: technical values
abstract class AppTypography {
  // ─── Space Grotesk (headings / display) ──────────────────────────────────
  static TextStyle displayLarge({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: color,
  );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
    color: color,
  );

  static TextStyle headingLarge({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
    color: color,
  );

  static TextStyle headingMedium({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
    color: color,
  );

  static TextStyle headingSmall({Color? color}) => GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: color,
  );

  // ─── Inter (body / interface) ─────────────────────────────────────────────
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: color,
  );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: color,
  );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: color,
  );

  static TextStyle labelLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: color,
  );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: color,
  );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: color,
  );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: color,
  );

  // ─── JetBrains Mono (technical values) ───────────────────────────────────
  static TextStyle monoLarge({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle monoMedium({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle monoSmall({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color,
  );

  // ─── TextTheme builders ───────────────────────────────────────────────────
  static TextTheme buildTextTheme(Color textColor, Color mutedColor) {
    return TextTheme(
      displayLarge: displayLarge(color: textColor),
      displayMedium: displayMedium(color: textColor),
      displaySmall: headingLarge(color: textColor),
      headlineLarge: headingLarge(color: textColor),
      headlineMedium: headingMedium(color: textColor),
      headlineSmall: headingSmall(color: textColor),
      titleLarge: headingMedium(color: textColor),
      titleMedium: headingSmall(color: textColor),
      titleSmall: labelLarge(color: textColor),
      bodyLarge: bodyLarge(color: textColor),
      bodyMedium: bodyMedium(color: textColor),
      bodySmall: bodySmall(color: mutedColor),
      labelLarge: labelLarge(color: textColor),
      labelMedium: labelMedium(color: mutedColor),
      labelSmall: labelSmall(color: mutedColor),
    );
  }
}
