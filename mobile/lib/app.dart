import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/home_shell.dart';
import 'l10n/app_localizations.dart';

/// Root widget: wires up the theme, localization and the tabbed shell.
class SmokeTrackerApp extends StatelessWidget {
  const SmokeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeShell(),
    );
  }
}
