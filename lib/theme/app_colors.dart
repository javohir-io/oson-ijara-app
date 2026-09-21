import 'package:flutter/material.dart';

/// Premium color palette — deep navy, ocean & dark blue tones with a
/// subtle gold accent for a high-end real-estate feel.
class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF071A34); // primary / deepest navy
  static const Color darkBlue = Color(0xFF0E2A55); // dark blue
  static const Color oceanBlue = Color(0xFF15487D); // ocean blue
  static const Color skyBlue = Color(0xFF2E76B6); // lighter accent blue
  static const Color gold = Color(0xFFC6A15B); // premium accent (icons/fills)
  static const Color goldDark = Color(0xFFA9812E); // premium accent (text-safe)
  static const Color goldLight = Color(0xFFEAD9AE);

  static const Color cream = Color(0xFFF3F6FB); // app background (cool ivory-blue)
  static const Color ivory = Color(0xFFFFFFFF); // card background
  static const Color mist = Color(0xFFE9EFF7); // subtle fill
  static const Color navyTint = Color(0xFFE3EAF4); // selected-state tint

  static const Color textPrimary = Color(0xFF0B1F3A);
  static const Color textSecondary = Color(0xFF57647A);
  static const Color textMuted = Color(0xFF8D98AC);
  static const Color divider = Color(0xFFDEE4EE);

  static const List<Color> heroGradient = [navy, oceanBlue];
  static const List<Color> cardPlaceholderGradient = [darkBlue, oceanBlue, skyBlue];
}
