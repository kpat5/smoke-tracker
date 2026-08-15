import 'package:flutter/material.dart';

import '../core/constants/trigger_tag.dart';
import '../core/localization_labels.dart';
import '../core/theme/app_spacing.dart';
import '../l10n/app_localizations.dart';

/// A row of trigger chips (plus a custom-label field when [TriggerTag.custom]
/// is picked), shared by the log editor sheet and the quick-log trigger
/// dialog so the two flows can't drift.
class TriggerPicker extends StatelessWidget {
  const TriggerPicker({
    super.key,
    required this.selected,
    required this.customLabelController,
    required this.onSelect,
  });

  final TriggerTag selected;
  final TextEditingController customLabelController;
  final ValueChanged<TriggerTag> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final tag in [TriggerTag.none, ...TriggerTag.selectable])
              ChoiceChip(
                label: Text(tag.label(l10n)),
                selected: selected == tag,
                onSelected: (_) => onSelect(tag),
              ),
          ],
        ),
        if (selected == TriggerTag.custom) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: customLabelController,
            decoration: InputDecoration(
              hintText: l10n.quickLogCustomTagHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}

/// Prompts for a trigger (+ optional custom label) via a small dialog.
/// Returns the picked `(tag, customLabel)`, or null if cancelled.
Future<(TriggerTag, String?)?> showTriggerPickerDialog(
  BuildContext context, {
  required TriggerTag initial,
  String? initialCustomLabel,
}) {
  return showDialog<(TriggerTag, String?)>(
    context: context,
    builder: (context) => _TriggerPickerDialog(
      initial: initial,
      initialCustomLabel: initialCustomLabel,
    ),
  );
}

class _TriggerPickerDialog extends StatefulWidget {
  const _TriggerPickerDialog({required this.initial, this.initialCustomLabel});

  final TriggerTag initial;
  final String? initialCustomLabel;

  @override
  State<_TriggerPickerDialog> createState() => _TriggerPickerDialogState();
}

class _TriggerPickerDialogState extends State<_TriggerPickerDialog> {
  late TriggerTag _tag = widget.initial;
  late final _customLabel =
      TextEditingController(text: widget.initialCustomLabel);

  @override
  void dispose() {
    _customLabel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.quickLogTriggerDialogTitle),
      content: TriggerPicker(
        selected: _tag,
        customLabelController: _customLabel,
        onSelect: (tag) => setState(() => _tag = tag),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () {
            final label = _customLabel.text.trim();
            Navigator.pop(
              context,
              (
                _tag,
                _tag == TriggerTag.custom && label.isNotEmpty ? label : null,
              ),
            );
          },
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
