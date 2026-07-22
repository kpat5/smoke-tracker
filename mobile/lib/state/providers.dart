import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_database.dart';
import '../data/mock/mock_log_repository.dart';
import '../data/mock/mock_stats_repository.dart';
import '../data/mock/mock_user_repository.dart';
import '../data/repositories/log_repository.dart';
import '../data/repositories/stats_repository.dart';
import '../data/repositories/user_repository.dart';

/// Single in-memory store shared across the mock repositories.
///
/// When the backend lands, only the three repository providers below need to
/// switch to HTTP implementations — nothing else in the app changes.
final mockDatabaseProvider = Provider<MockDatabase>((ref) => MockDatabase());

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => MockUserRepository(ref.watch(mockDatabaseProvider)),
);

final logRepositoryProvider = Provider<LogRepository>(
  (ref) => MockLogRepository(ref.watch(mockDatabaseProvider)),
);

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => MockStatsRepository(ref.watch(mockDatabaseProvider)),
);
