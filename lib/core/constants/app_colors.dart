import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand teal
  static const primary = Color(0xFF4A9B8E);
  static const primaryDark = Color(0xFF3D8A7E);
  static const primaryLight = Color(0xFF7EC8BB);

  // Light mode surfaces
  static const backgroundLight = Color(0xFFF7F3EC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFF0EBE0);
  static const cardLight = Color(0xFFFFFFFF);

  // Dark mode surfaces
  static const backgroundDark = Color(0xFF0F1117);
  static const surfaceDark = Color(0xFF1A1E27);
  static const surfaceVariantDark = Color(0xFF242836);
  static const cardDark = Color(0xFF1E2530);

  // Text
  static const textPrimaryLight = Color(0xFF1A1714);
  static const textSecondaryLight = Color(0xFF6E6A65);
  static const textPrimaryDark = Color(0xFFF0EDE8);
  static const textSecondaryDark = Color(0xFF9B9690);

  // Dividers
  static const dividerLight = Color(0xFFE0D8CC);
  static const dividerDark = Color(0xFF2E3340);

  // Active prayer highlight
  static const prayerActive = Color(0xFF4A9B8E);
  static const prayerActiveDark = Color(0xFF3D8A7E);

  // Error
  static const error = Color(0xFFD32F2F);

  // Accent warm
  static const warmGold = Color(0xFFB8963E);

  // Legacy aliases used in existing code
  static const background = backgroundLight;
  static const surface = surfaceLight;
  static const textPrimary = textPrimaryLight;
  static const textSecondary = textSecondaryLight;
  static const divider = dividerLight;
  static const nextPrayer = Color(0xFFE0F5F2);
  static const onPrimary = Color(0xFFFFFFFF);
}
