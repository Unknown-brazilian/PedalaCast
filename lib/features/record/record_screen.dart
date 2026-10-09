import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core_channel.dart';
import '../../core/telemetry/telemetry_sample.dart';
import '../../l10n/app_localizations.dart';
import '../permissions/permissions.dart';
import '../settings/app_settings.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> with SingleTickerProviderStateMixin {
  int? _textureId;
  bool _permsOk = false;
  bool _permsDenied = false;
  String? _error;
  late final AnimationController _hold =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) _stop();
        });
  late final CoreChannel _core = ref.read(coreProvider);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final s = ref.read(settingsProvider);
    if (!s.safetyAccepted) {
      await _showSafety();
    }
    if (!await hasAllPermissions()) {
      setState(() => _permsOk = false);
      return;
    }
    await _startPreview();
  }

  Future<void> _showSafety() async {
    final l = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.warning_amber),
        title: Text(l.safetyTitle),
        content: Text(l.safetyBody),
        actions: [FilledButton(onPressed: () => Navigator.pop(c), child: Text(l.safetyAccept))],
      ),
    );
    final n = ref.read(settingsProvider.notifier);
    await n.update(ref.read(settingsProvider).copyWith(safetyAccepted: true));
  }

  Future<void> _grant() async {
    final ok = await requestAllPermissions();
    setState(() => _permsDenied = !ok);
    if (ok) await _startPreview();
  }

  Future<void> _startPreview() async {
    final s = ref.read(settingsProvider);
    try {
      final id = await _core.startPreview(
        width: s.width,
        height: s.height,
        fps: s.fps,
        bitrate: s.bitrate,
        mic: s.mic,
        autoPause: s.autoPause,
        simulation: s.simulation,
        layout: s.layoutJson,
      );
      await _core.setKeepScreenOn(s.keepScreenOn);
      if (mounted) setState(() { _permsOk = true; _textureId = id; _error = null; });
    } on PlatformException catch (e) {
      if (mounted) setState(() { _permsOk = true; _error = e.message; });
    }
  }

  Future<void> _start() async {
    try {
      await _core.startRecording();
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _stop() async {
    _hold.value = 0;
    final uri = await _core.stopRecording();
    if (uri != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).recSaved)));
    }
  }

  @override
  void dispose() {
    _hold.dispose();
    // O núcleo ignora stopPreview se ainda estiver gravando (o serviço mantém tudo vivo).
    _core.setKeepScreenOn(false);
    _core.stopPreview();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final status = ref.watch(statusProvider).value ?? const CoreStatus();
    return PopScope(
      canPop: !status.recording,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: !_permsOk && _textureId == null && _error == null
            ? PermissionsScreen(onGrant: _grant, denied: _permsDenied)
            : Stack(children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _textureId == null
                        ? Center(child: _error == null ? Text(l.recStarting) : Text(l.recError(_error!)))
                        : Texture(textureId: _textureId!),
                  ),
                ),
                Positioned(top: 8, left: 8, child: _StatusBar(status: status)),
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(child: _Controls(status: status, hold: _hold, onStart: _start, onPause: _core.pauseRecording, onResume: _core.resumeRecording)),
                ),
                Positioned(left: 8, bottom: 8, right: 140, child: _Warnings(status: status)),
              ]),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.status});
  final CoreStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    Widget chip(IconData i, String t, {Color? c}) => Chip(
          avatar: Icon(i, size: 16, color: c),
          label: Text(t),
          visualDensity: VisualDensity.compact,
        );
    return Wrap(spacing: 6, children: [
      chip(status.gpsOk ? Icons.gps_fixed : Icons.gps_off, status.gpsOk ? l.recGps : l.recGpsNone,
          c: status.gpsOk ? null : cs.error),
      if (status.simulation) chip(Icons.science_outlined, l.recSimulation),
      if (status.freeBytes > 0) chip(Icons.sd_storage_outlined, l.recFree((status.freeBytes / 1e9).toStringAsFixed(1))),
      if (status.tempC != null) chip(Icons.thermostat, l.recTemp(status.tempC!.toStringAsFixed(0))),
    ]);
  }
}

class _Warnings extends StatelessWidget {
  const _Warnings({required this.status});
  final CoreStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final w = <String>[
      if (!status.hasBarometer && !status.simulation && status.state != 'idle') l.recNoBaro,
      if ((status.tempC ?? 0) >= 42) l.recHot,
      if (status.batteryPct >= 0 && status.batteryPct <= 15) l.recLowBattery,
      if (status.error != null) l.recError(status.error!),
    ];
    final c = Theme.of(context).colorScheme.error; // warning (amarelo), nunca o vermelho "live"
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final t in w)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.warning_amber, color: c, size: 18),
              const SizedBox(width: 6),
              Flexible(child: Text(t, style: TextStyle(color: c))),
            ]),
          ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.status, required this.hold, required this.onStart, required this.onPause, required this.onResume});
  final CoreStatus status;
  final AnimationController hold;
  final VoidCallback onStart;
  final Future<void> Function() onPause;
  final Future<void> Function() onResume;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final live = Theme.of(context).colorScheme.tertiary;
    if (!status.recording) {
      return SizedBox(
        width: 96,
        height: 96,
        child: FilledButton(
          style: FilledButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
          onPressed: status.state == 'preview' ? onStart : null,
          child: Text(l.recStart, textAlign: TextAlign.center),
        ),
      );
    }
    final paused = status.state == 'paused';
    return Column(mainAxisSize: MainAxisSize.min, spacing: 16, children: [
      SizedBox(
        width: 72,
        height: 72,
        child: FilledButton.tonal(
          style: FilledButton.styleFrom(shape: const CircleBorder(), padding: EdgeInsets.zero),
          onPressed: paused ? onResume : onPause,
          child: Icon(paused ? Icons.play_arrow : Icons.pause, size: 36),
        ),
      ),
      Listener(
        onPointerDown: (_) => hold.forward(),
        onPointerUp: (_) => hold.reverse(),
        onPointerCancel: (_) => hold.reverse(),
        child: SizedBox(
          width: 96,
          height: 96,
          child: AnimatedBuilder(
            animation: hold,
            builder: (_, _) => Stack(alignment: Alignment.center, children: [
              SizedBox.expand(child: CircularProgressIndicator(value: hold.value, strokeWidth: 6, color: live)),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(color: live, shape: BoxShape.circle),
                child: const Icon(Icons.stop, size: 40, color: Colors.white),
              ),
            ]),
          ),
        ),
      ),
      Text(l.recHoldToStop, style: const TextStyle(fontSize: 12)),
    ]);
  }
}
