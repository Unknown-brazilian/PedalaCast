import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../settings/app_settings.dart';
import 'layout_editor_screen.dart';

class LayoutScreen extends ConsumerWidget {
  const LayoutScreen({super.key});

  static const _sensors = ['hr', 'cadence', 'power'];
  static const _phone = ['phone_status'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final names = {
      'speed_gauge': l.blk_speed_gauge,
      'distance_climb': l.blk_distance_climb,
      'minimap': l.blk_minimap,
      'elevation_profile': l.blk_elevation_profile,
      'grade_badge': l.blk_grade_badge,
      'hr': l.blk_hr,
      'cadence': l.blk_cadence,
      'power': l.blk_power,
      'phone_status': l.blk_phone_status,
      'live_badge': l.blk_live_badge,
    };
    Widget toggle(String t) => SwitchListTile(
      title: Text(names[t]!),
      value: !s.disabled.contains(t),
      onChanged: (on) {
        final d = {...s.disabled};
        on ? d.remove(t) : d.add(t);
        n.update(s.copyWith(disabled: d));
      },
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.layoutTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  l.layoutSize,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'small', label: Text(l.layoutSmall)),
                    ButtonSegment(value: 'medium', label: Text(l.layoutMedium)),
                    ButtonSegment(value: 'large', label: Text(l.layoutLarge)),
                  ],
                  selected: {s.sizePreset},
                  onSelectionChanged: (v) =>
                      n.update(s.copyWith(sizePreset: v.first)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.open_with),
              label: Text(l.editOpen),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LayoutEditorScreen(),
                ),
              ),
            ),
          ),
          _header(context, l.layoutBlocks),
          for (final t in [
            'speed_gauge',
            'distance_climb',
            'minimap',
            'elevation_profile',
            'grade_badge',
            'live_badge',
          ])
            toggle(t),
          SwitchListTile(
            title: Text(l.layoutFullTrack),
            value: s.minimapFullTrack,
            onChanged: (v) => n.update(s.copyWith(minimapFullTrack: v)),
          ),
          for (final t in _sensors)
            ListTile(
              title: Text(names[t]!),
              subtitle: Text(l.layoutNoDevice),
              trailing: const Icon(Icons.bluetooth_disabled),
              onTap: () => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l.layoutNoDeviceHint))),
            ),
          _header(context, l.layoutPhone),
          for (final t in _phone) toggle(t),
        ],
      ),
    );
  }

  Widget _header(BuildContext c, String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(t, style: Theme.of(c).textTheme.titleMedium),
  );
}
