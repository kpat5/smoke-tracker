import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Builds the app's [ThemeData] from [AppColors] and [AppSpacing].
///
/// Widgets should pull styling from `Theme.of(context)` wherever possible so
/// there are no inline colours or ad-hoc text styles scattered through the UI.
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accentDeep,
      onSecondary: AppColors.onAccent,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.accentSoft,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.accent,
        side: const BorderSide(color: AppColors.divider),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        secondaryLabelStyle: const TextStyle(color: AppColors.onAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: base.bodyMedium?.copyWith(color: AppColors.textPrimary),
      // Muted, spaced-out label used for the small ALL-CAPS captions.
      labelSmall: base.labelSmall?.copyWith(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}
