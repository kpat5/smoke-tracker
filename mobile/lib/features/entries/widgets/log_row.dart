import 'package:flutter/material.dart';

import '../../../core/constants/trigger_tag.dart';
import '../../../core/localization_labels.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatting.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/log_entry.dart';
import '../../../widgets/app_card.dart';

/// A single entry row: time · trigger · cost. Tapping opens the editor.
class LogRow extends StatelessWidget {
  const LogRow({super.key, required this.entry, this.onTap});

  final LogEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final triggerLabel = entry.triggerTag == TriggerTag.custom
        ? (entry.customTagLabel ?? entry.triggerTag.label(l10n))
        : entry.triggerTag.label(l10n);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatting.entryTimestamp(
                    entry.occurredAt,
                    yesterdayLabel: l10n.relativeYesterday,
                  ),
                  style: theme.textTheme.titleMedium,
                ),
                if (entry.triggerTag != TriggerTag.none) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(triggerLabel, style: theme.textTheme.labelSmall),
                ],
              ],
            ),
          ),
          Text(
            Formatting.cost(entry.costSnapshot, entry.currencySnapshot),
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
