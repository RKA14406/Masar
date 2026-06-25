import 'package:flutter/material.dart';

class AppColors {
  // ===== BRAND COLORS =====
  static const Color primary = Color(0xFFD4AF37); // same as gold
  static const Color gold = Color(0xFFD4AF37);

  // ===== DARK MODE =====
  static const Color darkBackground = Color(0xFF0B1C2C);
  static const Color darkSurface = Color(0xFF11263A);
  static const Color darkTextPrimary = Color(0xFFF5EBD7);
  static const Color darkTextSecondary = Color(0xFFB8C1CC);

  // ===== LIGHT MODE =====
  static const Color lightBackground = Color(0xFFF4F1EC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1C2A39);
  static const Color lightTextSecondary = Color(0xFF5A6A7A);

  // ===== STATES =====
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB300);

  // ===== NODE COLORS (FOR TREE UI) =====
  static const Color nodeLocked = Color(0xFF6B7280);
  static const Color nodeUnlocked = gold;
  static const Color nodeCompleted = Color(0xFFFFD700);
}

