import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../widgets/app_card.dart';

/// A labelled number (e.g. "TODAY / 3", "SPENT TODAY / ₹45").
///
/// [flat] drops the card chrome for the minimalist Home layout; the carded form
/// is still used on the Stats tab.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.flat = false,
  });

  final String label;
  final String value;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: (flat ? theme.textTheme.headlineLarge : theme.textTheme.headlineMedium),
        ),
      ],
    );

    if (flat) return content;
    return AppCard(child: content);
  }
}
