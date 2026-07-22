import '../../core/constants/trigger_tag.dart';
import '../../models/log_entry.dart';
import '../../models/stats_summary.dart';
import '../repositories/stats_repository.dart';
import 'mock_database.dart';

/// Mock [StatsRepository] that aggregates [MockDatabase]'s logs in memory,
/// standing in for the pre-aggregation the backend `GET /stats` will do.
class MockStatsRepository implements StatsRepository {
  MockStatsRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final MockDatabase _db;
  final DateTime Function() _clock;

  @override
  Future<StatsSummary> getStats(StatsRange range) async {
    final now = _clock();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final fromDay = switch (range) {
      StatsRange.week => startOfToday.subtract(const Duration(days: 6)),
      StatsRange.month => startOfToday.subtract(const Duration(days: 29)),
      StatsRange.all => _earliestDay(startOfToday),
    };

    final inRange =
        _db.logs
            .where((e) => !e.occurredAt.isBefore(fromDay))
            .toList();

    return StatsSummary(
      range: range,
      totalCount: inRange.length,
      totalSpend: inRange.fold(0.0, (sum, e) => sum + e.costSnapshot),
      currencySymbol: _db.profile.currencySymbol,
      perDay: _perDay(inRange, fromDay, startOfToday),
      byTrigger: _byTrigger(inRange),
    );
  }

  DateTime _earliestDay(DateTime fallback) {
    if (_db.logs.isEmpty) return fallback;
    final earliest = _db.logs
        .map((e) => e.occurredAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    return DateTime(earliest.year, earliest.month, earliest.day);
  }

  List<DailyCount> _perDay(
    List<LogEntry> entries,
    DateTime fromDay,
    DateTime lastDay,
  ) {
    final counts = <DateTime, int>{};
    for (final e in entries) {
      final day = DateTime(
        e.occurredAt.year,
        e.occurredAt.month,
        e.occurredAt.day,
      );
      counts[day] = (counts[day] ?? 0) + 1;
    }

    final buckets = <DailyCount>[];
    for (
      var day = fromDay;
      !day.isAfter(lastDay);
      day = day.add(const Duration(days: 1))
    ) {
      buckets.add(DailyCount(date: day, count: counts[day] ?? 0));
    }
    return buckets;
  }

  List<TriggerCount> _byTrigger(List<LogEntry> entries) {
    final counts = <TriggerTag, int>{};
    for (final e in entries) {
      counts[e.triggerTag] = (counts[e.triggerTag] ?? 0) + 1;
    }
    final rows =
        counts.entries
            .map((e) => TriggerCount(tag: e.key, count: e.value))
            .toList()
          ..sort((a, b) => b.count.compareTo(a.count));
    return rows;
  }
}
