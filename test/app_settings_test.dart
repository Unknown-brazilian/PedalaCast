import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pedalacast/features/settings/app_settings.dart';

void main() {
  test('copyWith preserva todos os campos', () {
    const s = AppSettings(
      height: 720,
      portrait: true,
      liveHeight: 1080,
      liveRecordLocal: false,
      hideMinimap: true,
      sizePreset: 'large',
      cameraId: '2',
      cameraAsked: true,
      posPortrait: {'minimap': BlockPos(x: 0.1, y: 0.2, scale: 1.5)},
    );
    final c = s.copyWith(mic: false);
    expect(c.height, 720);
    expect(c.portrait, isTrue);
    expect(c.liveHeight, 1080);
    expect(c.liveRecordLocal, isFalse);
    expect(c.hideMinimap, isTrue);
    expect(c.sizePreset, 'large');
    expect(c.cameraId, '2');
    expect(c.cameraAsked, isTrue);
    expect(c.posPortrait['minimap']?.scale, 1.5);
    expect(c.mic, isFalse);
  });

  test('layoutJson inclui hideMinimap e posições da orientação atual', () {
    const s = AppSettings(
      portrait: true,
      hideMinimap: true,
      posPortrait: {'minimap': BlockPos(x: 0.1, y: 0.2, scale: 1.5)},
      posLandscape: {'minimap': BlockPos(x: 0.9, y: 0.9)},
    );
    final j = jsonDecode(s.layoutJson) as Map<String, dynamic>;
    expect(j['hideMinimap'], isTrue);
    final b = (j['blocks'] as List).cast<Map<String, dynamic>>().firstWhere(
      (e) => e['type'] == 'minimap',
    );
    expect(b['x'], 0.1);
    expect(b['y'], 0.2);
    expect(b['scale'], 1.5);
    final speed = (j['blocks'] as List).cast<Map<String, dynamic>>().firstWhere(
      (e) => e['type'] == 'speed_gauge',
    );
    expect(speed.containsKey('x'), isFalse);
  });

  test('encode/decode de posições', () {
    final m = {
      'a': const BlockPos(x: 0.5, y: 0.25, scale: 2),
      'b': const BlockPos(),
    };
    final d = decodePos(encodePos(m));
    expect(d['a']?.x, 0.5);
    expect(d['a']?.scale, 2);
    expect(d.containsKey('b'), isFalse); // vazio não é salvo
    expect(decodePos('lixo'), isEmpty);
  });
}
