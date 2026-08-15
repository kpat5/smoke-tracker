import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

/// Prompts for a single decimal number via a small dialog. Returns the parsed
/// value, or null if the user cancelled or entered something unparsable.
Future<double?> showEditNumberDialog(
  BuildContext context, {
  required String title,
  required String initial,
}) async {
  final controller = TextEditingController(text: initial);
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l10n.actionSave),
        ),
      ],
    ),
  );
  return double.tryParse(result ?? '');
}
