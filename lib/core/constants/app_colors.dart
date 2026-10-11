import 'package:flutter/material.dart';

/// Centralized color palette for the Desa Apps (RW Scope) application.
/// Designed with a modern, civic, vibrant yet professional tone.
class AppColors {
  // Primary Palette (Emerald / Forest Green - represents community & nature)
  static const Color primary = Color(0xFF0F766E); // Teal 700
  static const Color primaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color primaryDark = Color(0xFF115E59); // Teal 800
  static const Color primaryContainer = Color(0xFFCCFBF1); // Teal 100
  static const Color onPrimaryContainer = Color(0xFF134E4A);

  // Secondary Palette (Civic Slate / Royal Indigo)
  static const Color secondary = Color(0xFF3B82F6); // Blue 500
  static const Color secondaryContainer = Color(0xFFDBEAFE);
  static const Color onSecondaryContainer = Color(0xFF1E3A8A);

  // Accent & Action Colors
  static const Color accentAmber = Color(0xFFF59E0B); // Amber 500 for warnings & badges
  static const Color accentAmberLight = Color(0xFFFEF3C7);
  static const Color accentGreen = Color(0xFF10B981); // Emerald for success
  static const Color accentGreenLight = Color(0xFFD1FAE5);

  // Emergency Alert Colors (High Priority Siren)
  static const Color emergencyRed = Color(0xFFDC2626); // Red 600
  static const Color emergencyRedLight = Color(0xFFFEE2E2); // Red 100
  static const Color emergencyRedDark = Color(0xFF991B1B);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceBorder = Color(0xFFE2E8F0); // Slate 200

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Role Badge Colors
  static const Color roleWarga = Color(0xFF0D9488);
  static const Color roleRt = Color(0xFF2563EB);
  static const Color roleRw = Color(0xFF7C3AED);
}
