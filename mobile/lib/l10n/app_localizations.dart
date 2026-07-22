import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// Application name, shown in the app bar
  ///
  /// In en, this message translates to:
  /// **'Smoke Tracker'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabEntries.
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get tabEntries;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStats;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @statTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get statTodayLabel;

  /// No description provided for @statSpentTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'SPENT TODAY'**
  String get statSpentTodayLabel;

  /// No description provided for @ctaJustSmoked.
  ///
  /// In en, this message translates to:
  /// **'I just smoked'**
  String get ctaJustSmoked;

  /// No description provided for @logEarlier.
  ///
  /// In en, this message translates to:
  /// **'Log earlier ›'**
  String get logEarlier;

  /// No description provided for @quickLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log a cigarette'**
  String get quickLogTitle;

  /// No description provided for @quickLogMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get quickLogMoreOptions;

  /// No description provided for @quickLogTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get quickLogTimeLabel;

  /// No description provided for @quickLogEarlierToday.
  ///
  /// In en, this message translates to:
  /// **'Earlier today'**
  String get quickLogEarlierToday;

  /// No description provided for @quickLogYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get quickLogYesterday;

  /// No description provided for @quickLogPickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick date & time'**
  String get quickLogPickDateTime;

  /// No description provided for @quickLogTriggerLabel.
  ///
  /// In en, this message translates to:
  /// **'Trigger'**
  String get quickLogTriggerLabel;

  /// No description provided for @quickLogNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get quickLogNoteLabel;

  /// No description provided for @quickLogNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get quickLogNoteHint;

  /// No description provided for @quickLogCustomTagHint.
  ///
  /// In en, this message translates to:
  /// **'Name your tag'**
  String get quickLogCustomTagHint;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @snackLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged.'**
  String get snackLogged;

  /// No description provided for @triggerStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get triggerStress;

  /// No description provided for @triggerBoredom.
  ///
  /// In en, this message translates to:
  /// **'Boredom'**
  String get triggerBoredom;

  /// No description provided for @triggerSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get triggerSocial;

  /// No description provided for @triggerAfterMeal.
  ///
  /// In en, this message translates to:
  /// **'After meal'**
  String get triggerAfterMeal;

  /// No description provided for @triggerCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get triggerCoffee;

  /// No description provided for @triggerAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get triggerAlcohol;

  /// No description provided for @triggerCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get triggerCustom;

  /// No description provided for @triggerNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get triggerNone;

  /// No description provided for @entriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet.'**
  String get entriesEmpty;

  /// No description provided for @editEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntryTitle;

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get relativeYesterday;

  /// No description provided for @rangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get rangeWeek;

  /// No description provided for @rangeMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get rangeMonth;

  /// No description provided for @rangeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All-time'**
  String get rangeAllTime;

  /// No description provided for @statsCigarettesPerDay.
  ///
  /// In en, this message translates to:
  /// **'CIGARETTES PER DAY'**
  String get statsCigarettesPerDay;

  /// No description provided for @statsRangeTotal.
  ///
  /// In en, this message translates to:
  /// **'RANGE TOTAL'**
  String get statsRangeTotal;

  /// No description provided for @statsRangeSpend.
  ///
  /// In en, this message translates to:
  /// **'RANGE SPEND'**
  String get statsRangeSpend;

  /// No description provided for @statsByTrigger.
  ///
  /// In en, this message translates to:
  /// **'BY TRIGGER'**
  String get statsByTrigger;

  /// No description provided for @statsWeeklyRecap.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY RECAP'**
  String get statsWeeklyRecap;

  /// No description provided for @statsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data for this range yet.'**
  String get statsEmpty;

  /// Headline number on the weekly recap card
  ///
  /// In en, this message translates to:
  /// **'{count} logged'**
  String statsRecapLogged(int count);

  /// No description provided for @settingsSectionTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get settingsSectionTracking;

  /// No description provided for @settingsSectionMascot.
  ///
  /// In en, this message translates to:
  /// **'Mascot'**
  String get settingsSectionMascot;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsPackPrice.
  ///
  /// In en, this message translates to:
  /// **'Pack price'**
  String get settingsPackPrice;

  /// No description provided for @settingsCigarettesPerPack.
  ///
  /// In en, this message translates to:
  /// **'Cigarettes per pack'**
  String get settingsCigarettesPerPack;

  /// No description provided for @settingsCostSnapshotNote.
  ///
  /// In en, this message translates to:
  /// **'Past entries keep their original cost. Changes apply to new logs only.'**
  String get settingsCostSnapshotNote;

  /// No description provided for @settingsPersonality.
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get settingsPersonality;

  /// No description provided for @settingsRoastIntensity.
  ///
  /// In en, this message translates to:
  /// **'Roast intensity'**
  String get settingsRoastIntensity;

  /// No description provided for @settingsExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export data as CSV'**
  String get settingsExportCsv;

  /// No description provided for @settingsDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get settingsDeleteData;

  /// No description provided for @settingsNeutralTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this app is neutral'**
  String get settingsNeutralTitle;

  /// No description provided for @settingsNeutralBody.
  ///
  /// In en, this message translates to:
  /// **'This app just tracks. It won\'t tell you to smoke more or less, praise you, or lecture you. It only reflects your own numbers and patterns back to you.'**
  String get settingsNeutralBody;

  /// Character name for the nonchalant personality
  ///
  /// In en, this message translates to:
  /// **'Ash'**
  String get personalityNonchalant;

  /// Character name for the caring, shy personality
  ///
  /// In en, this message translates to:
  /// **'Ember'**
  String get personalityCaring;

  /// Character name for the excited personality
  ///
  /// In en, this message translates to:
  /// **'Blaze'**
  String get personalityExcited;

  /// Character name for the angry, irritated personality
  ///
  /// In en, this message translates to:
  /// **'Cinder'**
  String get personalityIrritable;

  /// Character name for the classy gentleman personality
  ///
  /// In en, this message translates to:
  /// **'Winston'**
  String get personalityGentleman;

  /// No description provided for @roastMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get roastMild;

  /// No description provided for @roastMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get roastMedium;

  /// No description provided for @roastSavage.
  ///
  /// In en, this message translates to:
  /// **'Savage'**
  String get roastSavage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
