import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'telemetry/telemetry_sample.dart';

/// Acesso ao núcleo Kotlin (MethodChannel/EventChannel).
class CoreChannel {
  static const _control = MethodChannel('pedalacast/control');
  static const _telemetry = EventChannel('pedalacast/telemetry');
  static const _status = EventChannel('pedalacast/status');

  Stream<TelemetrySample> get telemetry => _telemetry
      .receiveBroadcastStream()
      .map((e) => TelemetrySample.fromMap(e as Map));

  Stream<CoreStatus> get status =>
      _status.receiveBroadcastStream().map((e) => CoreStatus.fromMap(e as Map));

  /// Retorna o id da textura com o preview já composto com o overlay.
  Future<int> startPreview({
    required int width,
    required int height,
    required int fps,
    required int bitrate,
    required bool portrait,
    String cameraId = '',
    required bool mic,
    required bool autoPause,
    required bool simulation,
    required String layout,
    required Map<String, String> labels,
  }) async => (await _control.invokeMethod<int>('startPreview', {
    'width': width,
    'height': height,
    'fps': fps,
    'bitrate': bitrate,
    'portrait': portrait,
    'cameraId': cameraId,
    'mic': mic,
    'autoPause': autoPause,
    'simulation': simulation,
    'layout': layout,
    ...labels,
  }))!;

  Future<void> stopPreview() => _control.invokeMethod('stopPreview');
  Future<void> startRecording() => _control.invokeMethod('startRecording');
  Future<String?> stopRecording() =>
      _control.invokeMethod<String>('stopRecording');
  Future<void> startLive({
    required String endpoint,
    required int maxBitrate,
    required bool recordLocal,
  }) => _control.invokeMethod('startLive', {
    'endpoint': endpoint,
    'maxBitrate': maxBitrate,
    'recordLocal': recordLocal,
  });
  Future<void> stopLive() => _control.invokeMethod('stopLive');
  Future<void> pauseRecording() => _control.invokeMethod('pauseRecording');
  Future<void> resumeRecording() => _control.invokeMethod('resumeRecording');
  Future<void> setLayout(String json) =>
      _control.invokeMethod('setLayout', {'layout': json});
  Future<void> setSimulation(bool on) =>
      _control.invokeMethod('setSimulation', {'enabled': on});
  Future<void> setKeepScreenOn(bool on) =>
      _control.invokeMethod('setKeepScreenOn', {'enabled': on});
  Future<String> renderDebugPng(
    String layout,
    Map<String, String> labels,
  ) async => (await _control.invokeMethod<String>('renderDebugPng', {
    'layout': layout,
    ...labels,
  }))!;

  /// PNG do overlay (dados de exemplo) + retângulo normalizado [l,t,r,b] de cada bloco.
  Future<({Uint8List png, Map<String, List<double>> rects})> renderEditor(
    String layout,
    bool portrait,
    Map<String, String> labels,
  ) async {
    final m = (await _control.invokeMethod<Map<dynamic, dynamic>>(
      'renderEditor',
      {'layout': layout, 'portrait': portrait, ...labels},
    ))!;
    final rects = (m['rects'] as Map).map(
      (k, v) => MapEntry(
        k as String,
        (v as List).map((e) => (e as num).toDouble()).toList(),
      ),
    );
    return (png: m['png'] as Uint8List, rects: rects);
  }

  /// Câmeras disponíveis: id, facing (front/back), kind (main/ultrawide/tele/front), equivMm, mp.
  Future<List<Map<dynamic, dynamic>>> listCameras() async =>
      ((await _control.invokeMethod<List<dynamic>>('listCameras')) ?? const [])
          .cast<Map<dynamic, dynamic>>();
  Future<bool> needsBackgroundHelp() async =>
      (await _control.invokeMethod<bool>('needsBackgroundHelp')) ?? false;
  Future<void> openBatterySettings() =>
      _control.invokeMethod('openBatterySettings');
  Future<void> openAutostartSettings() =>
      _control.invokeMethod('openAutostartSettings');
  Future<bool> hasBarometer() async =>
      (await _control.invokeMethod<bool>('hasBarometer')) ?? false;

  Future<List<Map<dynamic, dynamic>>> listRecordings() async =>
      ((await _control.invokeMethod<List<dynamic>>('listRecordings')) ??
              const [])
          .cast<Map<dynamic, dynamic>>();
  Future<void> openRecording(String uri) =>
      _control.invokeMethod('openRecording', {'uri': uri});
  Future<void> shareRecording(String uri) =>
      _control.invokeMethod('shareRecording', {'uri': uri});
  Future<void> deleteRecording(String uri) =>
      _control.invokeMethod('deleteRecording', {'uri': uri});
}

final coreProvider = Provider<CoreChannel>((ref) => CoreChannel());

final statusProvider = StreamProvider<CoreStatus>(
  (ref) => ref.watch(coreProvider).status,
);
final telemetryProvider = StreamProvider<TelemetrySample>(
  (ref) => ref.watch(coreProvider).telemetry,
);
