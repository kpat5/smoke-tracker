import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/trigger_tag.dart';
import '../../core/localization_labels.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatting.dart';
import '../../l10n/app_localizations.dart';
import '../../models/log_entry.dart';
import '../../models/user_profile.dart';
import '../../state/log_controller.dart';
import '../../state/mascot_copy.dart';
import '../../state/user_controller.dart';
import '../../widgets/edit_number_dialog.dart';
import '../../widgets/trigger_picker.dart';
import '../quick_log/log_editor_sheet.dart';
import 'widgets/animated_mascot.dart';
import 'widgets/stat_tile.dart';

/// Home tab: the animated mascot as a hero, today's two numbers, and the
/// one-tap log CTA. Content is balanced down the full height so there is no dead
/// space; it scrolls on short screens. Per the design doc there is no
/// recent-entries list here.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
            return _HomeBody(profile: profile, count: count, spend: spend);
          },
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({
    required this.profile,
    required this.count,
    required this.spend,
  });

  final UserProfile profile;
  final int count;
  final double spend;

  Future<void> _logNow(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final priceOverride = ref.read(quickLogPriceOverrideProvider);
    final (trigger, customTagLabel) = ref.read(quickLogTriggerProvider);
    final created = await ref.read(logActionsProvider).logCigarette(
      occurredAt: DateTime.now(),
      createdVia: CreatedVia.quick,
      costOverride: priceOverride,
      trigger: trigger,
      customTagLabel: trigger == TriggerTag.custom ? customTagLabel : null,
    );
    // The overrides only ever apply to the log they were set for.
    ref.read(quickLogPriceOverrideProvider.notifier).state = null;
    ref.read(quickLogTriggerProvider.notifier).state = (TriggerTag.none, null);
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

  Future<void> _editPrice(
    BuildContext context,
    WidgetRef ref,
    double current,
  ) async {
    final l10n = AppLocalizations.of(context);
    final parsed = await showEditNumberDialog(
      context,
      title: l10n.quickLogPriceDialogTitle,
      initial: current.toString(),
    );
    if (parsed != null) {
      ref.read(quickLogPriceOverrideProvider.notifier).state = parsed;
    }
  }

  Future<void> _editTrigger(
    BuildContext context,
    WidgetRef ref,
    TriggerTag current,
    String? currentCustomLabel,
  ) async {
    final result = await showTriggerPickerDialog(
      context,
      initial: current,
      initialCustomLabel: currentCustomLabel,
    );
    if (result != null) {
      ref.read(quickLogTriggerProvider.notifier).state = result;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final priceOverride = ref.watch(quickLogPriceOverrideProvider);
    final price = priceOverride ?? profile.costPerCigarette;
    final (triggerTag, triggerCustomLabel) = ref.watch(quickLogTriggerProvider);
    final triggerLabel = triggerTag == TriggerTag.custom
        ? (triggerCustomLabel ?? triggerTag.label(l10n))
        : triggerTag.label(l10n);

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: TextButton.icon(
                            onPressed: () => _editPrice(context, ref, price),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: Text(
                              l10n.quickLogPriceLabel(
                                Formatting.cost(price, profile.currencySymbol),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: TextButton.icon(
                            onPressed: () => _editTrigger(
                              context,
                              ref,
                              triggerTag,
                              triggerCustomLabel,
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: Text(
                              triggerLabel,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _logNow(context, ref),
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
