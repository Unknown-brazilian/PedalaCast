import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'features/home/home_screen.dart';
import 'features/settings/app_settings.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final colors = await BrandColors.load();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: PedalaCastApp(colors: colors),
    ),
  );
}

class PedalaCastApp extends StatelessWidget {
  const PedalaCastApp({super.key, required this.colors});
  final BrandColors colors;

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (c) => AppLocalizations.of(c).appName,
    theme: colors.toTheme(),
    themeMode: ThemeMode.dark,
    localeResolutionCallback: (device, supported) {
      // Idioma do aparelho se suportado (pt, en, es, fr); senão inglês.
      for (final l in supported) {
        if (l.languageCode == device?.languageCode) return l;
      }
      return const Locale('en');
    },
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const HomeScreen(),
  );
}
