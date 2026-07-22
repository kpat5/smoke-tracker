import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatting.dart';
import '../../l10n/app_localizations.dart';
import '../../models/log_entry.dart';
import '../../models/user_profile.dart';
import '../../state/log_controller.dart';
import '../../state/mascot_copy.dart';
import '../../state/user_controller.dart';
import '../quick_log/log_editor_sheet.dart';
import 'widgets/animated_mascot.dart';
import 'widgets/stat_tile.dart';

/// Home tab: the animated mascot as a hero, today's two numbers, and the
/// one-tap log CTA. Content is balanced down the full height so there is no dead
/// space; it scrolls on short screens. Per the design doc there is no
/// recent-entries list here.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _logNow(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final created = await ref.read(logActionsProvider).logCigarette(
      occurredAt: DateTime.now(),
      createdVia: CreatedVia.quick,
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.snackLogged),
          action: SnackBarAction(
            label: l10n.actionUndo,
            onPressed: () =>
                ref.read(logActionsProvider).deleteLog(created.logId),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final todayAsync = ref.watch(todayLogsProvider);

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (profile) {
            final logs = todayAsync.valueOrNull ?? const <LogEntry>[];
            final count = logs.length;
            final spend =
                logs.fold<double>(0, (sum, e) => sum + e.costSnapshot);
            return _HomeBody(
              profile: profile,
              count: count,
              spend: spend,
              onLog: () => _logNow(context, ref),
            );
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.profile,
    required this.count,
    required this.spend,
    required this.onLog,
  });

  final UserProfile profile;
  final int count;
  final double spend;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.appTitle, style: theme.textTheme.headlineMedium),
                    const Spacer(),

                    // Hero mascot + reactive line.
                    Center(
                      child: AnimatedMascot(
                        personality: profile.personality,
                        count: count,
                        size: 160,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      MascotCopy.homeLine(
                        personality: profile.personality,
                        intensity: profile.roastIntensity,
                        count: count,
                      ),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),

                    // Flat stats.
                    Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            label: l10n.statTodayLabel,
                            value: '$count',
                            flat: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: StatTile(
                            label: l10n.statSpentTodayLabel,
                            value: Formatting.cost(spend, profile.currencySymbol),
                            flat: true,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Actions anchored near the bottom.
                    ElevatedButton(
                      onPressed: onLog,
                      child: Text(l10n.ctaJustSmoked),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => LogEditorSheet.show(context),
                        child: Text(l10n.logEarlier),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
