import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/trigger_tag.dart';
import '../data/mock/mock_seed_data.dart';
import '../models/log_entry.dart';
import 'providers.dart';
import 'stats_controller.dart';
import 'user_controller.dart';

const _uuid = Uuid();

/// Today's log entries (newest first), used by Home.
final todayLogsProvider = FutureProvider.autoDispose<List<LogEntry>>((
  ref,
) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  return ref.watch(logRepositoryProvider).getLogs(from: start, to: end);
});

/// Full history for the Entries tab (newest first).
final entriesProvider = FutureProvider.autoDispose<List<LogEntry>>((ref) async {
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
  return ref
      .watch(logRepositoryProvider)
      .getLogs(from: DateTime(2000), to: end);
});

/// Write actions for log entries. Centralizes cost-snapshotting and refreshes
/// every dependent view (Home, Entries, Stats) after each change.
class LogActions {
  LogActions(this._ref);

  final Ref _ref;

  /// Creates a new entry using the current profile to snapshot cost/currency.
  /// Returns the created entry (used e.g. for an undo affordance).
  Future<LogEntry> logCigarette({
    required DateTime occurredAt,
    required CreatedVia createdVia,
    TriggerTag trigger = TriggerTag.none,
    String? customTagLabel,
    String? note,
  }) async {
    final profile = await _ref.read(userProfileProvider.future);
    final entry = LogEntry(
      logId: _uuid.v4(),
      userId: mockUserId,
      occurredAt: occurredAt,
      loggedAt: DateTime.now(),
      costSnapshot: profile.costPerCigarette,
      currencySnapshot: profile.currencySymbol,
      triggerTag: trigger,
      customTagLabel: trigger == TriggerTag.custom ? customTagLabel : null,
      note: note,
      createdVia: createdVia,
    );
    final created = await _ref.read(logRepositoryProvider).createLog(entry);
    _invalidate();
    return created;
  }

  Future<void> updateLog(LogEntry entry) async {
    await _ref.read(logRepositoryProvider).updateLog(entry);
    _invalidate();
  }

  Future<void> deleteLog(String logId) async {
    await _ref.read(logRepositoryProvider).deleteLog(logId);
    _invalidate();
  }

  void _invalidate() {
    _ref.invalidate(todayLogsProvider);
    _ref.invalidate(entriesProvider);
    _ref.invalidate(statsProvider);
  }
}

final logActionsProvider = Provider<LogActions>((ref) => LogActions(ref));
