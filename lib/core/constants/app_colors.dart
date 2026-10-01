import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Palette (Charcoal / Slate / Deep Graphite professional EdTech aesthetic)
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF161F36);
  static const Color darkCardHover = Color(0xFF1E2942);
  static const Color darkBorder = Color(0xFF222F4C);
  static const Color darkBorderSubtle = Color(0xFF172033);

  // SkillForge Brand Primary: Electric Blue
  static const Color primary = Color(0xFF2563EB); // Electric Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryGlow = Color(0x332563EB);

  // SkillForge Brand Secondary: Violet
  static const Color secondary = Color(0xFF7C3AED); // Violet
  static const Color secondaryLight = Color(0xFF8B5CF6);
  static const Color secondaryDark = Color(0xFF6D28D9);

  // SkillForge Brand Accent: Cyan
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentIndigo = Color(0xFF4F46E5);
  static const Color accentPurple = Color(0xFF9333EA);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentEmerald = Color(0xFF10B981);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF2563EB);

  // Dark Text Hierarchy
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiaryDark = Color(0xFF64748B); // Slate 500
  static const Color textMutedDark = Color(0xFF475569); // Slate 600

  // Light Theme Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF64748B);

  // Streak flame gradient
  static const LinearGradient flameGradient = LinearGradient(
    colors: [Color(0xFFFF512F), Color(0xFFF09819)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // SkillForge Brand Gradient: Electric Blue -> Violet
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Cyan to Blue Gradient
  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Subtle card gradient
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF18223B), Color(0xFF121A2D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
