import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core_channel.dart';
import '../../core/telemetry/telemetry_sample.dart';
import '../../l10n/app_localizations.dart';
import '../permissions/permissions.dart';
import '../settings/app_settings.dart';
import '../settings/settings_screen.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key});

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen>
    with SingleTickerProviderStateMixin {
  int? _textureId;
  bool _permsOk = false;
  bool _permsDenied = false;
  String? _error;
  late final AnimationController _hold =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..addStatusListener((s) {
        if (s == AnimationStatus.completed) _stop();
      });
  late final CoreChannel _core = ref.read(coreProvider);

  @override
  void initState() {
    super.initState();
    _applyOrientation(ref.read(settingsProvider));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  void _applyOrientation(AppSettings s) =>
      SystemChrome.setPreferredOrientations(
        s.portrait
            ? [DeviceOrientation.portraitUp]
            : [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ],
      );

  /// Abre os ajustes sem sair da tela. Se algo que muda o pipeline foi alterado
  /// (resolução, orientação, microfone) e não está gravando, reinicia o preview.
  Future<void> _openSettings() async {
    final before = ref.read(settingsProvider);
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
    if (!mounted) return;
    final after = ref.read(settingsProvider);
    _applyOrientation(after);
    await _core.setKeepScreenOn(after.keepScreenOn);
    await _core.setLayout(after.layoutJson);
    final status = ref.read(statusProvider).value;
    final changed =
        before.height != after.height ||
        before.portrait != after.portrait ||
        before.mic != after.mic ||
        before.simulation != after.simulation ||
        before.autoPause != after.autoPause;
    if (changed && !(status?.recording ?? false)) {
      setState(() => _textureId = null);
      await _core.stopPreview();
      await _startPreview();
    }
  }

  Future<void> _boot() async {
    final s = ref.read(settingsProvider);
    if (!s.safetyAccepted) {
      await _showSafety();
    }
    if (await _core.needsBackgroundHelp() && mounted) {
      await _showBackgroundHelp();
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
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: Text(l.safetyAccept),
          ),
        ],
      ),
    );
    final n = ref.read(settingsProvider.notifier);
    await n.update(ref.read(settingsProvider).copyWith(safetyAccepted: true));
  }

  Future<void> _showBackgroundHelp() async {
    final l = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        icon: const Icon(Icons.battery_alert),
        title: Text(l.bgTitle),
        content: Text(l.bgBody),
        actions: [
          TextButton(
            onPressed: _core.openAutostartSettings,
            child: Text(l.bgAutostart),
          ),
          TextButton(
            onPressed: _core.openBatterySettings,
            child: Text(l.bgBattery),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: Text(l.safetyAccept),
          ),
        ],
      ),
    );
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
        portrait: s.portrait,
        mic: s.mic,
        autoPause: s.autoPause,
        simulation: s.simulation,
        layout: s.layoutJson,
      );
      await _core.setKeepScreenOn(s.keepScreenOn);
      if (mounted) {
        setState(() {
          _permsOk = true;
          _textureId = id;
          _error = null;
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _permsOk = true;
          _error = e.message;
        });
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).recSaved)),
      );
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
            : _body(context, status, l),
      ),
    );
  }
}

extension on _RecordScreenState {
  Widget _body(BuildContext context, CoreStatus status, AppLocalizations l) {
    final portrait = ref.watch(settingsProvider.select((s) => s.portrait));
    final preview = AspectRatio(
      aspectRatio: portrait ? 9 / 16 : 16 / 9,
      child: _textureId == null
          ? Center(
              child: _error == null
                  ? Text(l.recStarting)
                  : Text(l.recError(_error!)),
            )
          : Texture(textureId: _textureId!),
    );
    final controls = _Controls(
      status: status,
      hold: _hold,
      horizontal: portrait,
      onStart: _start,
      onPause: _core.pauseRecording,
      onResume: _core.resumeRecording,
    );
    final settingsBtn = IconButton.filledTonal(
      tooltip: l.recSettings,
      icon: const Icon(Icons.settings),
      onPressed: _openSettings,
    );
    if (portrait) {
      return SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(child: _StatusBar(status: status)),
                  settingsBtn,
                ],
              ),
            ),
            Expanded(child: Center(child: preview)),
            _Warnings(status: status),
            Padding(padding: const EdgeInsets.all(12), child: controls),
          ],
        ),
      );
    }
    return Stack(
      children: [
        Center(child: preview),
        Positioned(top: 8, left: 8, child: _StatusBar(status: status)),
        Positioned(top: 8, right: 8, child: settingsBtn),
        Positioned(
          right: 16,
          top: 0,
          bottom: 0,
          child: Center(child: controls),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          right: 140,
          child: _Warnings(status: status),
        ),
      ],
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
    return Wrap(
      spacing: 6,
      children: [
        chip(
          status.gpsOk ? Icons.gps_fixed : Icons.gps_off,
          status.gpsOk ? l.recGps : l.recGpsNone,
          c: status.gpsOk ? null : cs.error,
        ),
        if (status.simulation) chip(Icons.science_outlined, l.recSimulation),
        if (status.freeBytes > 0)
          chip(
            Icons.sd_storage_outlined,
            l.recFree((status.freeBytes / 1e9).toStringAsFixed(1)),
          ),
        if (status.tempC != null)
          chip(Icons.thermostat, l.recTemp(status.tempC!.toStringAsFixed(0))),
      ],
    );
  }
}

class _Warnings extends StatelessWidget {
  const _Warnings({required this.status});
  final CoreStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final w = <String>[
      if (!status.hasBarometer && !status.simulation && status.state != 'idle')
        l.recNoBaro,
      if ((status.tempC ?? 0) >= 42) l.recHot,
      if (status.batteryPct >= 0 && status.batteryPct <= 15) l.recLowBattery,
      if (status.error != null) l.recError(status.error!),
    ];
    final c = Theme.of(context)
        .colorScheme
        .error; // warning (amarelo), nunca o vermelho "live"
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final t in w)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber, color: c, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(t, style: TextStyle(color: c)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.horizontal,
    required this.status,
    required this.hold,
    required this.onStart,
    required this.onPause,
    required this.onResume,
  });
  final bool horizontal;
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
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          onPressed: status.state == 'preview' ? onStart : null,
          child: Text(l.recStart, textAlign: TextAlign.center),
        ),
      );
    }
    final paused = status.state == 'paused';
    final kids = <Widget>[
      SizedBox(
        width: 72,
        height: 72,
        child: FilledButton.tonal(
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
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
            builder: (_, _) => Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: hold.value,
                    strokeWidth: 6,
                    color: live,
                  ),
                ),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: live,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stop, size: 40, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
      Text(l.recHoldToStop, style: const TextStyle(fontSize: 12)),
    ];
    return horizontal
        ? Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: kids)
        : Column(mainAxisSize: MainAxisSize.min, spacing: 16, children: kids);
  }
}
