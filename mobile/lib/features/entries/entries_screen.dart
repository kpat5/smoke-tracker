import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../state/log_controller.dart';
import '../quick_log/log_editor_sheet.dart';
import 'widgets/log_row.dart';

/// Entries tab: the full, scrollable log history. Tap a row to edit or delete.
class EntriesScreen extends ConsumerWidget {
  const EntriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entriesAsync = ref.watch(entriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabEntries)),
      body: SafeArea(
        child: entriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (entries) {
            if (entries.isEmpty) {
              return Center(child: Text(l10n.entriesEmpty));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: entries.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return LogRow(
                  entry: entry,
                  onTap: () =>
                      LogEditorSheet.show(context, existing: entry),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
