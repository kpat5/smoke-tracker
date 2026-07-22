/// Spacing and radius scale for the app.
///
/// All `EdgeInsets`, `SizedBox` gaps and `BorderRadius` values should reference
/// these constants instead of raw numbers, so layout stays consistent.
abstract final class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Corner radius for cards, sheets and tiles.
  static const double radiusCard = 16;

  /// Corner radius for the primary CTA and pill buttons.
  static const double radiusButton = 28;

  /// Corner radius for chips and small controls.
  static const double radiusChip = 12;
}
