// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smoke Tracker';

  @override
  String get tabHome => 'Home';

  @override
  String get tabEntries => 'Entries';

  @override
  String get tabStats => 'Stats';

  @override
  String get tabSettings => 'Settings';

  @override
  String get statTodayLabel => 'TODAY';

  @override
  String get statSpentTodayLabel => 'SPENT TODAY';

  @override
  String get ctaJustSmoked => 'I just smoked';

  @override
  String get logEarlier => 'Log earlier ›';

  @override
  String get quickLogTitle => 'Log a cigarette';

  @override
  String get quickLogMoreOptions => 'More options';

  @override
  String get quickLogTimeLabel => 'Time';

  @override
  String get quickLogEarlierToday => 'Earlier today';

  @override
  String get quickLogYesterday => 'Yesterday';

  @override
  String get quickLogPickDateTime => 'Pick date & time';

  @override
  String get quickLogTriggerLabel => 'Trigger';

  @override
  String get quickLogNoteLabel => 'Note';

  @override
  String get quickLogNoteHint => 'Add a note (optional)';

  @override
  String get quickLogCustomTagHint => 'Name your tag';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionUndo => 'Undo';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get snackLogged => 'Logged.';

  @override
  String get triggerStress => 'Stress';

  @override
  String get triggerBoredom => 'Boredom';

  @override
  String get triggerSocial => 'Social';

  @override
  String get triggerAfterMeal => 'After meal';

  @override
  String get triggerCoffee => 'Coffee';

  @override
  String get triggerAlcohol => 'Alcohol';

  @override
  String get triggerCustom => 'Custom';

  @override
  String get triggerNone => 'None';

  @override
  String get entriesEmpty => 'Nothing logged yet.';

  @override
  String get editEntryTitle => 'Edit entry';

  @override
  String get relativeYesterday => 'Yesterday';

  @override
  String get rangeWeek => 'Week';

  @override
  String get rangeMonth => 'Month';

  @override
  String get rangeAllTime => 'All-time';

  @override
  String get statsCigarettesPerDay => 'CIGARETTES PER DAY';

  @override
  String get statsRangeTotal => 'RANGE TOTAL';

  @override
  String get statsRangeSpend => 'RANGE SPEND';

  @override
  String get statsByTrigger => 'BY TRIGGER';

  @override
  String get statsWeeklyRecap => 'WEEKLY RECAP';

  @override
  String get statsEmpty => 'No data for this range yet.';

  @override
  String statsRecapLogged(int count) {
    return '$count logged';
  }

  @override
  String get settingsSectionTracking => 'Tracking';

  @override
  String get settingsSectionMascot => 'Mascot';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsPackPrice => 'Pack price';

  @override
  String get settingsCigarettesPerPack => 'Cigarettes per pack';

  @override
  String get settingsCostSnapshotNote => 'Past entries keep their original cost. Changes apply to new logs only.';

  @override
  String get settingsPersonality => 'Personality';

  @override
  String get settingsRoastIntensity => 'Roast intensity';

  @override
  String get settingsExportCsv => 'Export data as CSV';

  @override
  String get settingsDeleteData => 'Delete all data';

  @override
  String get settingsNeutralTitle => 'Why this app is neutral';

  @override
  String get settingsNeutralBody => 'This app just tracks. It won\'t tell you to smoke more or less, praise you, or lecture you. It only reflects your own numbers and patterns back to you.';

  @override
  String get personalityNonchalant => 'Ash';

  @override
  String get personalityCaring => 'Ember';

  @override
  String get personalityExcited => 'Blaze';

  @override
  String get personalityIrritable => 'Cinder';

  @override
  String get personalityGentleman => 'Winston';

  @override
  String get roastMild => 'Mild';

  @override
  String get roastMedium => 'Medium';

  @override
  String get roastSavage => 'Savage';
}
