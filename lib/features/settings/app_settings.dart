import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Posição/tamanho próprio de um bloco do overlay. x,y = canto superior esquerdo (0..1 do quadro).
/// x/y nulos = posição automática; scale nulo = tamanho do preset.
class BlockPos {
  const BlockPos({this.x, this.y, this.scale});
  final double? x;
  final double? y;
  final double? scale;

  bool get isEmpty => x == null && y == null && scale == null;

  Map<String, dynamic> toJson() => {
    if (x != null && y != null) 'x': x,
    if (x != null && y != null) 'y': y,
    if (scale != null) 'scale': scale,
  };

  factory BlockPos.fromJson(Map<String, dynamic> j) => BlockPos(
    x: (j['x'] as num?)?.toDouble(),
    y: (j['y'] as num?)?.toDouble(),
    scale: (j['scale'] as num?)?.toDouble(),
  );
}

Map<String, BlockPos> decodePos(String? raw) {
  if (raw == null || raw.isEmpty) return const {};
  try {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final e in m.entries)
        e.key: BlockPos.fromJson(e.value as Map<String, dynamic>),
    };
  } catch (_) {
    return const {};
  }
}

String encodePos(Map<String, BlockPos> m) => jsonEncode({
  for (final e in m.entries)
    if (!e.value.isEmpty) e.key: e.value.toJson(),
});

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
    this.liveHeight = 720,
    this.liveRecordLocal = true,
    this.hideMinimap = false,
    this.cameraId = '',
    this.cameraAsked = false,
    this.posLandscape = const {},
    this.posPortrait = const {},
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
  final int liveHeight; // 720 ou 1080
  final bool liveRecordLocal;
  final bool hideMinimap;

  /// ID da câmera preferida ('' = automática: traseira principal).
  final String cameraId;
  final bool cameraAsked;
  final Map<String, BlockPos> posLandscape;
  final Map<String, BlockPos> posPortrait;

  /// Posições dos blocos na orientação atual (cada orientação tem as suas).
  Map<String, BlockPos> get blockPos => portrait ? posPortrait : posLandscape;

  int get width => height == 1080 ? 1920 : 1280;
  int get liveWidth => liveHeight == 1080 ? 1920 : 1280;
  // 720p: 1,5–4 Mbps; 1080p: 3–6 Mbps (faixas iniciais; o bitrate adapta à rede)
  int get liveBitrate => liveHeight == 1080 ? 6000000 : 4000000;
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
          ...?blockPos[t]?.toJson(),
        },
    ],
    'minimapFullTrack': minimapFullTrack,
    'hideMinimap': hideMinimap,
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
    int? liveHeight,
    bool? liveRecordLocal,
    bool? hideMinimap,
    String? cameraId,
    bool? cameraAsked,
    Map<String, BlockPos>? posLandscape,
    Map<String, BlockPos>? posPortrait,
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
    liveHeight: liveHeight ?? this.liveHeight,
    liveRecordLocal: liveRecordLocal ?? this.liveRecordLocal,
    hideMinimap: hideMinimap ?? this.hideMinimap,
    cameraId: cameraId ?? this.cameraId,
    cameraAsked: cameraAsked ?? this.cameraAsked,
    posLandscape: posLandscape ?? this.posLandscape,
    posPortrait: posPortrait ?? this.posPortrait,
  );
}

/// Preferências já carregadas em main() (evita ler valores padrão antes do carregamento).
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider não inicializado'),
);

class SettingsNotifier extends Notifier<AppSettings> {
  late final SharedPreferences _prefs = ref.read(sharedPrefsProvider);

  @override
  AppSettings build() {
    final p = ref.read(sharedPrefsProvider);
    return AppSettings(
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
      liveHeight: p.getInt('liveHeight') ?? 720,
      liveRecordLocal: p.getBool('liveRecordLocal') ?? true,
      hideMinimap: p.getBool('hideMinimap') ?? false,
      cameraId: p.getString('cameraId') ?? '',
      cameraAsked: p.getBool('cameraAsked') ?? false,
      posLandscape: decodePos(p.getString('posLandscape')),
      posPortrait: decodePos(p.getString('posPortrait')),
    );
  }

  Future<void> update(AppSettings s) async {
    state = s;
    final p = _prefs;
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
    await p.setInt('liveHeight', s.liveHeight);
    await p.setBool('liveRecordLocal', s.liveRecordLocal);
    await p.setBool('hideMinimap', s.hideMinimap);
    await p.setString('cameraId', s.cameraId);
    await p.setBool('cameraAsked', s.cameraAsked);
    await p.setString('posLandscape', encodePos(s.posLandscape));
    await p.setString('posPortrait', encodePos(s.posPortrait));
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
