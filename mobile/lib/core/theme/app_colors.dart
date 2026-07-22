import 'package:flutter/material.dart';

/// Central colour palette for the app.
///
/// This is the single source of truth for every colour used in the UI.
/// Widgets must read colours from here (or, preferably, from the [ThemeData]
/// built in `app_theme.dart`) rather than hard-coding [Color] literals.
abstract final class AppColors {
  const AppColors._();

  /// Warm cream app background.
  static const Color background = Color(0xFFFBF3EC);

  /// White surface used for cards, sheets and tiles.
  static const Color card = Color(0xFFFFFFFF);

  /// Mild-orange brand accent — primary CTA, active nav, highlights.
  static const Color accent = Color(0xFFF2822C);

  /// Deeper orange used for pressed states and recap banners.
  static const Color accentDeep = Color(0xFFD9641B);

  /// Faint orange fill behind progress bars and subtle highlights.
  static const Color accentSoft = Color(0xFFF7D9C0);

  /// Primary near-black text.
  static const Color textPrimary = Color(0xFF231F1C);

  /// Muted grey text for labels and secondary content.
  static const Color textMuted = Color(0xFF8C8279);

  /// Text/icon colour placed on top of [accent].
  static const Color onAccent = Color(0xFFFFFFFF);

  /// Hairline dividers and card borders.
  static const Color divider = Color(0xFFEDE3D8);

  /// Destructive action colour (delete).
  static const Color danger = Color(0xFFC0392B);
}
