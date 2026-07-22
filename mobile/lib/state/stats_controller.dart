import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stats_summary.dart';
import 'providers.dart';

/// Pre-aggregated stats for a given range. Invalidated by [LogActions] whenever
/// entries change so the Stats tab stays in sync.
final statsProvider = FutureProvider.autoDispose
    .family<StatsSummary, StatsRange>((ref, range) async {
      return ref.watch(statsRepositoryProvider).getStats(range);
    });
