import '../core/constants/trigger_tag.dart';

/// Time range for the Stats tab — maps to the `range` query param on
/// `GET /stats` (`week` | `month` | `all`).
enum StatsRange {
  week('week'),
  month('month'),
  all('all');

  const StatsRange(this.wireValue);

  final String wireValue;
}

/// Count of cigarettes on a single day (a bar in the per-day chart).
class DailyCount {
  const DailyCount({required this.date, required this.count});

  final DateTime date;
  final int count;
}

/// Count of cigarettes attributed to a trigger tag (a row in the breakdown).
class TriggerCount {
  const TriggerCount({required this.tag, required this.count});

  final TriggerTag tag;
  final int count;
}

/// Pre-aggregated stats for a range, mirroring what `GET /stats` returns so the
/// app never aggregates raw entries on-device.
class StatsSummary {
  const StatsSummary({
    required this.range,
    required this.totalCount,
    required this.totalSpend,
    required this.currencySymbol,
    required this.perDay,
    required this.byTrigger,
  });

  final StatsRange range;
  final int totalCount;
  final double totalSpend;
  final String currencySymbol;

  /// Ordered oldest → newest, one bucket per day in the range.
  final List<DailyCount> perDay;

  /// Ordered highest → lowest count.
  final List<TriggerCount> byTrigger;

  bool get isEmpty => totalCount == 0;
}
