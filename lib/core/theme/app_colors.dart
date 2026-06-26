import 'package:flutter/material.dart';

class AppColors {
  // ===== BRAND COLORS =====
  static const Color primary = Color(0xFF1E5BFF);
  static const Color primaryDark = Color(0xFF003CDE);
  static const Color secondary = Color(0xFF00A7FF);
  static const Color tertiary = Color(0xFFE8EDFF);
  static const Color border = Color(0xFFDDE6FF);
  static const Color neutralDark = Color(0xFF20243D);

  // Backward-compatible alias for older widgets that still reference gold.
  static const Color gold = primary;

  // ===== DARK MODE =====
  static const Color darkBackground = Color(0xFF08111F);
  static const Color darkSurface = Color(0xFF101C2E);
  static const Color darkTextPrimary = Color(0xFFF8FAFF);
  static const Color darkTextSecondary = Color(0xFFC8D1E6);

  // ===== LIGHT MODE =====
  static const Color lightBackground = Color(0xFFF8FAFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = neutralDark;
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // ===== STATES =====
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);

  // ===== NODE COLORS (FOR TREE UI) =====
  static const Color nodeLocked = Color(0xFF6B7280);
  static const Color nodeUnlocked = primary;
  static const Color nodeCompleted = secondary;
}
