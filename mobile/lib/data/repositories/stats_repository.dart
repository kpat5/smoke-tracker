import '../../models/stats_summary.dart';

/// Returns pre-aggregated stats for a range.
///
/// A future HTTP implementation maps onto `GET /stats?range=week|month|all`.
abstract interface class StatsRepository {
  Future<StatsSummary> getStats(StatsRange range);
}
