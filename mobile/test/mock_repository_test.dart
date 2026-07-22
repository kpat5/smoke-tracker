import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/trigger_tag.dart';
import 'package:mobile/data/mock/mock_database.dart';
import 'package:mobile/data/mock/mock_log_repository.dart';
import 'package:mobile/data/mock/mock_seed_data.dart';
import 'package:mobile/data/mock/mock_stats_repository.dart';
import 'package:mobile/models/log_entry.dart';
import 'package:mobile/models/stats_summary.dart';

void main() {
  // Fixed clock so seed data and range boundaries line up deterministically.
  final now = DateTime(2026, 7, 20, 18, 0);

  group('MockLogRepository', () {
    test('seeds three entries for today', () async {
      final repo = MockLogRepository(MockDatabase(now: now));
      final start = DateTime(2026, 7, 20);
      final end = DateTime(2026, 7, 20, 23, 59, 59);
      final today = await repo.getLogs(from: start, to: end);
      expect(today, hasLength(3));
    });

    test('create, update and delete round-trip', () async {
      final db = MockDatabase(now: now);
      final repo = MockLogRepository(db);
      final entry = LogEntry(
        logId: 'test-1',
        userId: mockUserId,
        occurredAt: DateTime(2026, 7, 20, 12),
        loggedAt: DateTime(2026, 7, 20, 12),
        costSnapshot: 15,
        currencySnapshot: '₹',
        triggerTag: TriggerTag.stress,
      );

      await repo.createLog(entry);
      expect(db.logs.where((e) => e.logId == 'test-1'), hasLength(1));

      await repo.updateLog(entry.copyWith(triggerTag: TriggerTag.coffee));
      expect(
        db.logs.firstWhere((e) => e.logId == 'test-1').triggerTag,
        TriggerTag.coffee,
      );

      await repo.deleteLog('test-1');
      expect(db.logs.where((e) => e.logId == 'test-1'), isEmpty);
    });
  });

  group('MockStatsRepository', () {
    test('week range aggregates the seeded 21 entries', () async {
      final db = MockDatabase(now: now);
      final repo = MockStatsRepository(db, clock: () => now);
      final stats = await repo.getStats(StatsRange.week);

      expect(stats.totalCount, 21);
      expect(stats.totalSpend, 21 * 15);
      expect(stats.perDay, hasLength(7));
      // Trigger breakdown is sorted highest-first.
      expect(stats.byTrigger.first.count, greaterThanOrEqualTo(
        stats.byTrigger.last.count,
      ));
    });
  });
}
