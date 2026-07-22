import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/personality.dart';
import '../../core/constants/roast_intensity.dart';
import '../../core/localization_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatting.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_profile.dart';
import '../../state/user_controller.dart';
import '../../widgets/app_card.dart';

/// Settings tab: tracking config, mascot config, data actions, neutral note.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _save(WidgetRef ref, UserProfile profile) =>
      ref.read(userProfileProvider.notifier).save(profile);

  Future<void> _editNumber(
    BuildContext context, {
    required String title,
    required String initial,
    required ValueChanged<double> onSubmit,
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
    final parsed = double.tryParse(result ?? '');
    if (parsed != null) onSubmit(parsed);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSettings)),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (profile) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _Section(title: l10n.settingsSectionTracking),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(l10n.settingsPackPrice),
                      trailing: Text(
                        Formatting.cost(profile.packPrice, profile.currencySymbol),
                      ),
                      onTap: () => _editNumber(
                        context,
                        title: l10n.settingsPackPrice,
                        initial: profile.packPrice.toString(),
                        onSubmit: (v) =>
                            _save(ref, profile.copyWith(packPrice: v)),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(l10n.settingsCigarettesPerPack),
                      trailing: Text('${profile.cigarettesPerPack}'),
                      onTap: () => _editNumber(
                        context,
                        title: l10n.settingsCigarettesPerPack,
                        initial: profile.cigarettesPerPack.toString(),
                        onSubmit: (v) => _save(
                          ref,
                          profile.copyWith(cigarettesPerPack: v.round()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.settingsCostSnapshotNote,
                style: Theme.of(context).textTheme.labelSmall,
              ),

              const SizedBox(height: AppSpacing.lg),
              _Section(title: l10n.settingsSectionMascot),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsPersonality,
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final p in Personality.values)
                          ChoiceChip(
                            label: Text(p.label(l10n)),
                            selected: profile.personality == p,
                            onSelected: (_) =>
                                _save(ref, profile.copyWith(personality: p)),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(l10n.settingsRoastIntensity,
                        style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<RoastIntensity>(
                      segments: [
                        for (final r in RoastIntensity.values)
                          ButtonSegment(value: r, label: Text(r.label(l10n))),
                      ],
                      selected: {profile.roastIntensity},
                      showSelectedIcon: false,
                      onSelectionChanged: (s) =>
                          _save(ref, profile.copyWith(roastIntensity: s.first)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              _Section(title: l10n.settingsSectionData),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(l10n.settingsExportCsv),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _comingSoon(context, l10n),
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(
                        l10n.settingsDeleteData,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                      trailing:
                          const Icon(Icons.chevron_right, color: AppColors.danger),
                      onTap: () => _comingSoon(context, l10n),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              _Section(title: l10n.settingsNeutralTitle),
              Text(
                l10n.settingsNeutralBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
