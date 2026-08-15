import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/trigger_tag.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatting.dart';
import '../../l10n/app_localizations.dart';
import '../../models/log_entry.dart';
import '../../state/log_controller.dart';
import '../../widgets/trigger_picker.dart';

/// Bottom sheet for creating a backdated entry ("Log earlier") or editing an
/// existing one. One widget serves both flows: [existing] null ⇒ create.
class LogEditorSheet extends ConsumerStatefulWidget {
  const LogEditorSheet({super.key, this.existing});

  final LogEntry? existing;

  static Future<void> show(BuildContext context, {LogEntry? existing}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusCard),
        ),
      ),
      builder: (_) => LogEditorSheet(existing: existing),
    );
  }

  @override
  ConsumerState<LogEditorSheet> createState() => _LogEditorSheetState();
}

class _LogEditorSheetState extends ConsumerState<LogEditorSheet> {
  late DateTime _occurredAt;
  late TriggerTag _trigger;
  late final TextEditingController _customLabel;
  late final TextEditingController _note;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _occurredAt = existing?.occurredAt ?? DateTime.now();
    _trigger = existing?.triggerTag ?? TriggerTag.none;
    _customLabel = TextEditingController(text: existing?.customTagLabel ?? '');
    _note = TextEditingController(text: existing?.note ?? '');
  }

  @override
  void dispose() {
    _customLabel.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickTimeOn(DateTime day) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_occurredAt),
    );
    if (picked == null) return;
    setState(() {
      _occurredAt =
          DateTime(day.year, day.month, day.day, picked.hour, picked.minute);
    });
  }

  Future<void> _pickFullDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    await _pickTimeOn(date);
  }

  Future<void> _save() async {
    final actions = ref.read(logActionsProvider);
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    final customLabel =
        _customLabel.text.trim().isEmpty ? null : _customLabel.text.trim();

    if (_isEdit) {
      await actions.updateLog(
        widget.existing!.copyWith(
          occurredAt: _occurredAt,
          triggerTag: _trigger,
          customTagLabel: customLabel,
          clearCustomTagLabel: customLabel == null,
          note: note,
          clearNote: note == null,
        ),
      );
    } else {
      final isNow = DateTime.now().difference(_occurredAt).abs() <
          const Duration(minutes: 2);
      await actions.logCigarette(
        occurredAt: _occurredAt,
        createdVia: isNow ? CreatedVia.quick : CreatedVia.backdated,
        trigger: _trigger,
        customTagLabel: customLabel,
        note: note,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    await ref.read(logActionsProvider).deleteLog(widget.existing!.logId);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEdit ? l10n.editEntryTitle : l10n.quickLogTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            // Time
            Text(l10n.quickLogTimeLabel, style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              Formatting.entryTimestamp(
                _occurredAt,
                yesterdayLabel: l10n.relativeYesterday,
                now: now,
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                ActionChip(
                  label: Text(l10n.quickLogEarlierToday),
                  onPressed: () => _pickTimeOn(now),
                ),
                ActionChip(
                  label: Text(l10n.quickLogYesterday),
                  onPressed: () =>
                      _pickTimeOn(now.subtract(const Duration(days: 1))),
                ),
                ActionChip(
                  label: Text(l10n.quickLogPickDateTime),
                  onPressed: _pickFullDateTime,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Trigger
            Text(l10n.quickLogTriggerLabel, style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.xs),
            TriggerPicker(
              selected: _trigger,
              customLabelController: _customLabel,
              onSelect: (tag) => setState(() => _trigger = tag),
            ),
            const SizedBox(height: AppSpacing.md),

            // Note
            Text(l10n.quickLogNoteLabel, style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _note,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.quickLogNoteHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Row(
              children: [
                if (_isEdit) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(l10n.actionDelete),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(l10n.actionSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
