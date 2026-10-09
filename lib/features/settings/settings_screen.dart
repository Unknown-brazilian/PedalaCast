import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l.setTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  l.setResolution,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 1080, label: Text(l.set1080)),
                    ButtonSegment(value: 720, label: Text(l.set720)),
                  ],
                  selected: {s.height},
                  onSelectionChanged: (v) =>
                      n.update(s.copyWith(height: v.first)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  l.setOrientation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(l.setLandscape),
                      icon: const Icon(Icons.stay_current_landscape),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(l.setPortrait),
                      icon: const Icon(Icons.stay_current_portrait),
                    ),
                  ],
                  selected: {s.portrait},
                  onSelectionChanged: (v) =>
                      n.update(s.copyWith(portrait: v.first)),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(l.setKeepScreen),
            value: s.keepScreenOn,
            onChanged: (v) => n.update(s.copyWith(keepScreenOn: v)),
          ),
          SwitchListTile(
            title: Text(l.setMic),
            value: s.mic,
            onChanged: (v) => n.update(s.copyWith(mic: v)),
          ),
          SwitchListTile(
            title: Text(l.setAutoPause),
            value: s.autoPause,
            onChanged: (v) => n.update(s.copyWith(autoPause: v)),
          ),
          ListTile(
            title: Text(l.setPrivacy(s.privacyRadiusM)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: s.privacyRadiusM.toDouble(),
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  onChanged: (v) =>
                      n.update(s.copyWith(privacyRadiusM: v.round())),
                ),
                Text(l.setPrivacyHint),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(l.setSimulation),
            subtitle: Text(l.setSimulationHint),
            value: s.simulation,
            onChanged: (v) => n.update(s.copyWith(simulation: v)),
          ),
        ],
      ),
    );
  }
}
