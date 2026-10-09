/// Espelha o formato interno de amostra (TelemetrySample.kt).
class TelemetrySample {
  const TelemetrySample({
    required this.tMs,
    required this.epochMs,
    this.lat,
    this.lon,
    this.speedMps,
    this.altitudeM,
    this.gradePct,
    required this.distanceM,
    required this.ascentM,
    this.hrBpm,
    this.cadenceRpm,
    this.powerW,
    this.batteryPct = -1,
    this.charging = false,
    this.signalLevel,
    this.networkType,
    this.tempC,
  });

  final int tMs;
  final int epochMs;
  final double? lat;
  final double? lon;
  final double? speedMps;
  final double? altitudeM;
  final double? gradePct;
  final double distanceM;
  final double ascentM;
  final int? hrBpm;
  final int? cadenceRpm;
  final int? powerW;
  final int batteryPct;
  final bool charging;
  final int? signalLevel;
  final String? networkType;
  final double? tempC;

  factory TelemetrySample.fromMap(Map<dynamic, dynamic> m) => TelemetrySample(
    tMs: (m['tMs'] as num).toInt(),
    epochMs: (m['epochMs'] as num).toInt(),
    lat: (m['lat'] as num?)?.toDouble(),
    lon: (m['lon'] as num?)?.toDouble(),
    speedMps: (m['speedMps'] as num?)?.toDouble(),
    altitudeM: (m['altitudeM'] as num?)?.toDouble(),
    gradePct: (m['gradePct'] as num?)?.toDouble(),
    distanceM: (m['distanceM'] as num).toDouble(),
    ascentM: (m['ascentM'] as num).toDouble(),
    hrBpm: (m['hrBpm'] as num?)?.toInt(),
    cadenceRpm: (m['cadenceRpm'] as num?)?.toInt(),
    powerW: (m['powerW'] as num?)?.toInt(),
    batteryPct: (m['batteryPct'] as num?)?.toInt() ?? -1,
    charging: (m['charging'] as bool?) ?? false,
    signalLevel: (m['signalLevel'] as num?)?.toInt(),
    networkType: m['networkType'] as String?,
    tempC: (m['tempC'] as num?)?.toDouble(),
  );
}

/// Status enviado pelo núcleo Kotlin (1 Hz).
class CoreStatus {
  const CoreStatus({
    this.state = 'idle',
    this.elapsedMs = 0,
    this.gpsOk = false,
    this.hasBarometer = true,
    this.freeBytes = 0,
    this.tempC,
    this.batteryPct = -1,
    this.simulation = false,
    this.live = false,
    this.liveState = 'off',
    this.bitrateKbps = 0,
    this.droppedFrames = 0,
    this.network,
    this.error,
  });

  final String state;
  final int elapsedMs;
  final bool gpsOk;
  final bool hasBarometer;
  final int freeBytes;
  final double? tempC;
  final int batteryPct;
  final bool simulation;
  final bool live;
  final String liveState;
  final int bitrateKbps;
  final int droppedFrames;
  final String? network;
  final String? error;

  bool get recording => state == 'recording' || state == 'paused';

  /// Gravando e/ou transmitindo (a parada exige segurar o botão).
  bool get active => recording || live;

  factory CoreStatus.fromMap(Map<dynamic, dynamic> m) => CoreStatus(
    state: m['state'] as String? ?? 'idle',
    elapsedMs: (m['elapsedMs'] as num?)?.toInt() ?? 0,
    gpsOk: (m['gpsOk'] as bool?) ?? false,
    hasBarometer: (m['hasBarometer'] as bool?) ?? true,
    freeBytes: (m['freeBytes'] as num?)?.toInt() ?? 0,
    tempC: (m['tempC'] as num?)?.toDouble(),
    batteryPct: (m['batteryPct'] as num?)?.toInt() ?? -1,
    simulation: (m['simulation'] as bool?) ?? false,
    error: m['error'] as String?,
  );
}
