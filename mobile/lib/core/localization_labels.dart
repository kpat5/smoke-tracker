import '../l10n/app_localizations.dart';
import 'constants/personality.dart';
import 'constants/roast_intensity.dart';
import 'constants/trigger_tag.dart';
import '../models/stats_summary.dart';

/// Maps enum values to their localized display labels. Kept in the UI layer so
/// the enums themselves stay free of `AppLocalizations` / `BuildContext`.
extension TriggerTagLabel on TriggerTag {
  String label(AppLocalizations l10n) => switch (this) {
    TriggerTag.stress => l10n.triggerStress,
    TriggerTag.boredom => l10n.triggerBoredom,
    TriggerTag.social => l10n.triggerSocial,
    TriggerTag.afterMeal => l10n.triggerAfterMeal,
    TriggerTag.coffee => l10n.triggerCoffee,
    TriggerTag.alcohol => l10n.triggerAlcohol,
    TriggerTag.custom => l10n.triggerCustom,
    TriggerTag.none => l10n.triggerNone,
  };
}

extension PersonalityLabel on Personality {
  String label(AppLocalizations l10n) => switch (this) {
    Personality.nonchalant => l10n.personalityNonchalant,
    Personality.caring => l10n.personalityCaring,
    Personality.excited => l10n.personalityExcited,
    Personality.irritable => l10n.personalityIrritable,
    Personality.gentleman => l10n.personalityGentleman,
  };
}

extension RoastIntensityLabel on RoastIntensity {
  String label(AppLocalizations l10n) => switch (this) {
    RoastIntensity.mild => l10n.roastMild,
    RoastIntensity.medium => l10n.roastMedium,
    RoastIntensity.savage => l10n.roastSavage,
  };
}

extension StatsRangeLabel on StatsRange {
  String label(AppLocalizations l10n) => switch (this) {
    StatsRange.week => l10n.rangeWeek,
    StatsRange.month => l10n.rangeMonth,
    StatsRange.all => l10n.rangeAllTime,
  };
}
