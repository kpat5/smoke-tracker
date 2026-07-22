import 'package:flutter/material.dart';

/// The large pill CTA (e.g. "I just smoked"). Styling comes from
/// `elevatedButtonTheme`, so this only wires up the label and callback.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
