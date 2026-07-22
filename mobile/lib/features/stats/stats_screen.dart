import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/trigger_tag.dart';
import '../../core/localization_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatting.dart';
import '../../l10n/app_localizations.dart';
import '../../models/stats_summary.dart';
import '../../state/stats_controller.dart';
import '../../widgets/app_card.dart';
import '../home/widgets/stat_tile.dart';

/// Stats tab: range switch, per-day chart, totals, trigger breakdown, recap.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  StatsRange _range = StatsRange.week;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(statsProvider(_range));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabStats)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SegmentedButton<StatsRange>(
              segments: [
                for (final r in StatsRange.values)
                  ButtonSegment(value: r, label: Text(r.label(l10n))),
              ],
              selected: {_range},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _range = s.first),
            ),
            const SizedBox(height: AppSpacing.md),
            statsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('$e'),
              data: (stats) => stats.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Center(child: Text(l10n.statsEmpty)),
                    )
                  : _StatsBody(stats: stats),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final StatsSummary stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PerDayChartCard(stats: stats),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: l10n.statsRangeTotal,
                value: '${stats.totalCount}',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatTile(
                label: l10n.statsRangeSpend,
                value: Formatting.cost(stats.totalSpend, stats.currencySymbol),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _ByTriggerCard(stats: stats),
        if (stats.range == StatsRange.week) ...[
          const SizedBox(height: AppSpacing.md),
          _RecapCard(count: stats.totalCount),
        ],
      ],
    );
  }
}

class _PerDayChartCard extends StatelessWidget {
  const _PerDayChartCard({required this.stats});

  final StatsSummary stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final showDayLabels = stats.perDay.length <= 10;
    final maxCount = stats.perDay
        .map((d) => d.count)
        .fold<int>(0, (m, c) => c > m ? c : m);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.statsCigarettesPerDay, style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount + 1).toDouble(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: showDayLabels,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= stats.perDay.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            Formatting.weekdayLetter(stats.perDay[i].date),
                            style: theme.textTheme.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < stats.perDay.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: stats.perDay[i].count.toDouble(),
                          color: AppColors.accent,
                          width: showDayLabels ? 16 : 6,
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ByTriggerCard extends StatelessWidget {
  const _ByTriggerCard({required this.stats});

  final StatsSummary stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final maxCount = stats.byTrigger
        .map((t) => t.count)
        .fold<int>(0, (m, c) => c > m ? c : m);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.statsByTrigger, style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          for (final row in stats.byTrigger)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        row.tag == TriggerTag.none
                            ? l10n.triggerNone
                            : row.tag.label(l10n),
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text('${row.count}', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                    child: LinearProgressIndicator(
                      value: maxCount == 0 ? 0 : row.count / maxCount,
                      minHeight: 6,
                      backgroundColor: AppColors.accentSoft,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentDeep,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsWeeklyRecap,
            style: const TextStyle(
              color: AppColors.onAccent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.statsRecapLogged(count),
            style: const TextStyle(
              color: AppColors.onAccent,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
