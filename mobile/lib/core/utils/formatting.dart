import 'package:intl/intl.dart';

/// Currency and date/time formatting helpers.
///
/// Thin wrappers over `intl` so formatting logic lives in one place and the
/// widgets stay free of ad-hoc `DateFormat`/`NumberFormat` strings.
abstract final class Formatting {
  const Formatting._();

  /// Formats a cost as `"<symbol><amount>"`, e.g. `"₹45"` or `"$4.50"`.
  ///
  /// Whole values render without decimals; fractional values keep up to two
  /// decimal places (trailing zeros trimmed).
  static String cost(double amount, String currencySymbol) {
    final isWhole = amount == amount.roundToDouble();
    final pattern = isWhole ? '#,##0' : '#,##0.##';
    final formatted = NumberFormat(pattern).format(amount);
    return '$currencySymbol$formatted';
  }

  /// Time of day only, e.g. `"4:33 PM"`.
  static String time(DateTime dateTime) => DateFormat.jm().format(dateTime);

  /// A short weekday letter, e.g. `"M"`, used for chart axis labels.
  static String weekdayLetter(DateTime date) =>
      DateFormat('EEEEE').format(date);

  /// Timestamp for an entry row, relative to [now] (defaults to `DateTime.now()`):
  /// - today   → `"4:33 PM"`
  /// - yesterday → `"Yesterday, 4:03 PM"` (using the localized [yesterdayLabel])
  /// - earlier → `"Jul 18, 4:03 PM"`
  ///
  /// [yesterdayLabel] is supplied by the caller (from `AppLocalizations`) so the
  /// relative day stays localized without this util depending on `BuildContext`.
  static String entryTimestamp(
    DateTime occurredAt, {
    required String yesterdayLabel,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final day = DateTime(occurredAt.year, occurredAt.month, occurredAt.day);
    final diffDays = today.difference(day).inDays;
    final timePart = time(occurredAt);

    if (diffDays == 0) return timePart;
    if (diffDays == 1) return '$yesterdayLabel, $timePart';
    return '${DateFormat.MMMd().format(occurredAt)}, $timePart';
  }
}
