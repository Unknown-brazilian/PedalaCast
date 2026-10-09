import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configurações persistidas. O layout do overlay é um JSON lido pelo Kotlin.
class AppSettings {
  const AppSettings({
    this.height = 1080,
    this.portrait = false,
    this.fps = 30,
    this.keepScreenOn = true,
    this.mic = true,
    this.autoPause = false,
    this.simulation = false,
    this.privacyRadiusM = 300,
    this.sizePreset = 'small',
    this.disabled = const {'phone_status'},
    this.minimapFullTrack = false,
    this.safetyAccepted = false,
  });

  final int height; // 1080 ou 720
  final bool portrait;
  final int fps;
  final bool keepScreenOn;
  final bool mic;
  final bool autoPause;
  final bool simulation;
  final int privacyRadiusM;
  final String sizePreset;
  final Set<String> disabled;
  final bool minimapFullTrack;
  final bool safetyAccepted;

  int get width => height == 1080 ? 1920 : 1280;
  int get bitrate => height == 1080 ? 12000000 : 6000000;

  static const blockTypes = [
    'speed_gauge',
    'distance_climb',
    'minimap',
    'elevation_profile',
    'grade_badge',
    'hr',
    'cadence',
    'power',
    'phone_status',
    'live_badge',
  ];

  String get layoutJson => jsonEncode({
    'blocks': [
      for (final t in blockTypes)
        {
          'id': t,
          'type': t,
          'enabled': !disabled.contains(t),
          'anchor': 'auto',
          'sizePreset': sizePreset,
        },
    ],
    'minimapFullTrack': minimapFullTrack,
    'privacyRadiusM': privacyRadiusM,
  });

  AppSettings copyWith({
    int? height,
    bool? portrait,
    int? fps,
    bool? keepScreenOn,
    bool? mic,
    bool? autoPause,
    bool? simulation,
    int? privacyRadiusM,
    String? sizePreset,
    Set<String>? disabled,
    bool? minimapFullTrack,
    bool? safetyAccepted,
  }) => AppSettings(
    height: height ?? this.height,
    portrait: portrait ?? this.portrait,
    fps: fps ?? this.fps,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    mic: mic ?? this.mic,
    autoPause: autoPause ?? this.autoPause,
    simulation: simulation ?? this.simulation,
    privacyRadiusM: privacyRadiusM ?? this.privacyRadiusM,
    sizePreset: sizePreset ?? this.sizePreset,
    disabled: disabled ?? this.disabled,
    minimapFullTrack: minimapFullTrack ?? this.minimapFullTrack,
    safetyAccepted: safetyAccepted ?? this.safetyAccepted,
  );
}

class SettingsNotifier extends Notifier<AppSettings> {
  SharedPreferences? _prefs;

  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    final p = _prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      height: p.getInt('height') ?? 1080,
      portrait: p.getBool('portrait') ?? false,
      fps: p.getInt('fps') ?? 30,
      keepScreenOn: p.getBool('keepScreenOn') ?? true,
      mic: p.getBool('mic') ?? true,
      autoPause: p.getBool('autoPause') ?? false,
      simulation: p.getBool('simulation') ?? false,
      privacyRadiusM: p.getInt('privacyRadiusM') ?? 300,
      sizePreset: p.getString('sizePreset') ?? 'small',
      disabled: (p.getStringList('disabled') ?? const ['phone_status']).toSet(),
      minimapFullTrack: p.getBool('minimapFullTrack') ?? false,
      safetyAccepted: p.getBool('safetyAccepted') ?? false,
    );
  }

  Future<void> update(AppSettings s) async {
    state = s;
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setInt('height', s.height);
    await p.setBool('portrait', s.portrait);
    await p.setInt('fps', s.fps);
    await p.setBool('keepScreenOn', s.keepScreenOn);
    await p.setBool('mic', s.mic);
    await p.setBool('autoPause', s.autoPause);
    await p.setBool('simulation', s.simulation);
    await p.setInt('privacyRadiusM', s.privacyRadiusM);
    await p.setString('sizePreset', s.sizePreset);
    await p.setStringList('disabled', s.disabled.toList());
    await p.setBool('minimapFullTrack', s.minimapFullTrack);
    await p.setBool('safetyAccepted', s.safetyAccepted);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
