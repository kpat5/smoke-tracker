import '../../models/log_entry.dart';
import '../repositories/log_repository.dart';
import 'mock_database.dart';

/// Mock [LogRepository] backed by [MockDatabase]'s in-memory list.
class MockLogRepository implements LogRepository {
  MockLogRepository(this._db);

  final MockDatabase _db;

  @override
  Future<List<LogEntry>> getLogs({
    required DateTime from,
    required DateTime to,
  }) async {
    final result =
        _db.logs
            .where(
              (e) =>
                  !e.occurredAt.isBefore(from) && !e.occurredAt.isAfter(to),
            )
            .toList()
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return result;
  }

  @override
  Future<LogEntry> createLog(LogEntry entry) async {
    _db.logs = [..._db.logs, entry];
    return entry;
  }

  @override
  Future<LogEntry> updateLog(LogEntry entry) async {
    _db.logs = [
      for (final e in _db.logs) e.logId == entry.logId ? entry : e,
    ];
    return entry;
  }

  @override
  Future<void> deleteLog(String logId) async {
    _db.logs = _db.logs.where((e) => e.logId != logId).toList();
  }
}
