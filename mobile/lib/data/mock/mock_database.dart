import '../../models/log_entry.dart';
import '../../models/user_profile.dart';
import 'mock_seed_data.dart';

/// In-memory store shared by the mock repositories so log, stats and user
/// reads all see the same data within a session. Not persisted — resets on
/// restart. Replaced wholesale by real HTTP repositories in the backend phase.
class MockDatabase {
  MockDatabase({DateTime? now}) {
    profile = buildSeedProfile(now: now);
    logs = buildSeedLogs(profile, now: now);
  }

  late UserProfile profile;
  late List<LogEntry> logs;
}
