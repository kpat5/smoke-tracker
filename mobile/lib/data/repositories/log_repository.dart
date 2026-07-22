import '../../models/log_entry.dart';

/// Creates, reads, edits and deletes log entries.
///
/// Method shapes mirror the documented API routes so a future HTTP
/// implementation is a drop-in replacement:
///   - [createLog]  → `POST /logs`
///   - [getLogs]    → `GET /logs?from=&to=`
///   - [updateLog]  → `PATCH /logs/{logId}`
///   - [deleteLog]  → `DELETE /logs/{logId}`
abstract interface class LogRepository {
  /// Fetches entries with `occurredAt` in [from, to], newest first.
  Future<List<LogEntry>> getLogs({required DateTime from, required DateTime to});

  Future<LogEntry> createLog(LogEntry entry);

  Future<LogEntry> updateLog(LogEntry entry);

  Future<void> deleteLog(String logId);
}
