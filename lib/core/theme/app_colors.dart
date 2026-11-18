import 'package:flutter/material.dart';

/// SmartRoute Uganda brand color palette.
/// Based on the logo: electric lime/yellow-green, signal cyan, and dark navy.
abstract class AppColors {
  // ─── Brand Core ──────────────────────────────────────────────────────────
  static const Color obsidian = Color(0xFF090E18);
  static const Color deepSpaceNavy = Color(0xFF111B2A);
  static const Color graphite = Color(0xFF273449);
  static const Color electricLime = Color(0xFFB6FF3B);
  static const Color signalCyan = Color(0xFF26D9E8);
  static const Color cloudWhite = Color(0xFFF4F7FB);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // ─── Semantic / Status ───────────────────────────────────────────────────
  static const Color hazardRed = Color(0xFFFF3B3B);
  static const Color cautionAmber = Color(0xFFFFB830);
  static const Color successGreen = Color(0xFF22C55E);
  static const Color infoBlue = Color(0xFF3B82F6);

  // ─── Dark theme surfaces ─────────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF162035);
  static const Color darkCard = Color(0xFF1C2B42);
  static const Color darkBorder = Color(0xFF2A3D57);
  static const Color darkMuted = Color(0xFF6B82A0);

  // ─── Light theme surfaces ────────────────────────────────────────────────
  static const Color lightSurface = Color(0xFFF4F7FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightMuted = Color(0xFF64748B);

  // ─── Route line colours ──────────────────────────────────────────────────
  static const Color routeSelected = electricLime;
  static const Color routeAlternative = signalCyan;
  static const Color routeDisabled = Color(0xFF4A5568);

  // ─── Map condition overlays ──────────────────────────────────────────────
  static const Color conditionHeavy = hazardRed;
  static const Color conditionModerate = cautionAmber;
  static const Color conditionClear = successGreen;
  static const Color conditionRoadworks = Color(0xFFFF8C00);
  static const Color conditionFlooding = Color(0xFF1E90FF);
  static const Color conditionClosure = Color(0xFF9B1C1C);
}
