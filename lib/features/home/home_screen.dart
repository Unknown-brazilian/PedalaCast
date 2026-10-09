import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../about/about_screen.dart';
import '../debug/debug_screen.dart';
import '../layout/layout_screen.dart';
import '../library/library_screen.dart';
import '../live/live_setup_screen.dart';
import '../record/record_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    void go(Widget w) =>
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));
    return Scaffold(
      appBar: AppBar(title: Text(l.appName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 96,
            child: FilledButton.icon(
              icon: const Icon(Icons.directions_bike, size: 36),
              label: Text(l.homeStart, style: const TextStyle(fontSize: 22)),
              onPressed: () => go(const RecordScreen()),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.podcasts, size: 30),
              label: Text(l.homeLive, style: const TextStyle(fontSize: 18)),
              onPressed: () => go(const LiveSetupScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _tile(
            Icons.video_library_outlined,
            l.homeLibrary,
            () => go(const LibraryScreen()),
          ),
          _tile(
            Icons.dashboard_customize_outlined,
            l.homeLayout,
            () => go(const LayoutScreen()),
          ),
          _tile(Icons.tune, l.homeSettings, () => go(const SettingsScreen())),
          _tile(
            Icons.bug_report_outlined,
            l.homeDebug,
            () => go(const DebugScreen()),
          ),
          _tile(Icons.info_outline, l.homeAbout, () => go(const AboutScreen())),
        ],
      ),
    );
  }

  Widget _tile(IconData i, String t, VoidCallback onTap) => Card(
    child: ListTile(
      leading: Icon(i),
      title: Text(t),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
