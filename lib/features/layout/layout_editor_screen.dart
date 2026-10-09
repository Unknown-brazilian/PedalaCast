import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core_channel.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../settings/app_settings.dart';

/// Editor: arraste os blocos do overlay e mude o tamanho de cada um. Salvo por orientação.
class LayoutEditorScreen extends ConsumerStatefulWidget {
  const LayoutEditorScreen({super.key});

  @override
  ConsumerState<LayoutEditorScreen> createState() => _LayoutEditorScreenState();
}

class _LayoutEditorScreenState extends ConsumerState<LayoutEditorScreen> {
  Uint8List? _png;
  Map<String, List<double>> _rects = {};
  String? _selected;
  bool _busy = false;
  bool _dirty = false;

  // Posição provisória durante o arraste (canto superior esquerdo, 0..1).
  Offset? _drag;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _render());
  }

  Future<void> _render() async {
    if (_busy) {
      _dirty = true;
      return;
    }
    _busy = true;
    final s = ref.read(settingsProvider);
    try {
      final r = await ref
          .read(coreProvider)
          .renderEditor(s.layoutJson, s.portrait, overlayLabels(context));
      if (mounted) {
        setState(() {
          _png = r.png;
          _rects = r.rects;
        });
      }
    } finally {
      _busy = false;
    }
    if (_dirty && mounted) {
      _dirty = false;
      unawaited(_render());
    }
  }

  void _setPos(String id, {double? x, double? y, double? scale}) {
    final s = ref.read(settingsProvider);
    final map = {...s.blockPos};
    final cur = map[id] ?? const BlockPos();
    // Só arrastar fixa a posição; mudar o tamanho mantém o fluxo automático (os vizinhos acompanham).
    map[id] = BlockPos(x: x ?? cur.x, y: y ?? cur.y, scale: scale ?? cur.scale);
    ref
        .read(settingsProvider.notifier)
        .update(
          s.portrait
              ? s.copyWith(posPortrait: map)
              : s.copyWith(posLandscape: map),
        );
    _render();
  }

  void _reset([String? id]) {
    final s = ref.read(settingsProvider);
    final map = {...s.blockPos};
    if (id == null) {
      map.clear();
    } else {
      map.remove(id);
    }
    ref
        .read(settingsProvider.notifier)
        .update(
          s.portrait
              ? s.copyWith(posPortrait: map)
              : s.copyWith(posLandscape: map),
        );
    _render();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final aspect = s.portrait ? 9 / 16 : 16 / 9;
    final names = blockNames(l);
    final sel = _selected;
    final selScale = sel == null ? 1.0 : (s.blockPos[sel]?.scale ?? 1.0);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.editTitle),
        actions: [
          TextButton(onPressed: () => _reset(), child: Text(l.editResetAll)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                l.editHelp(s.portrait ? l.setPortrait : l.setLandscape),
              ),
            ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: aspect,
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth, h = c.maxHeight;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: _png == null
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Image.memory(
                                    _png!,
                                    fit: BoxFit.fill,
                                    gaplessPlayback: true,
                                  ),
                          ),
                          for (final e in _rects.entries)
                            _box(e.key, e.value, w, h, selected: e.key == sel),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            if (sel != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${names[sel] ?? sel}: ${l.editSize((selScale * 100).round())}',
                          ),
                          Slider(
                            value: selScale.clamp(0.4, 3.0),
                            min: 0.4,
                            max: 3.0,
                            onChanged: (v) => _setPos(
                              sel,
                              scale: double.parse(v.toStringAsFixed(2)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _reset(sel),
                      child: Text(l.editResetBlock),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(l.editTapHint),
              ),
          ],
        ),
      ),
    );
  }

  Widget _box(
    String id,
    List<double> r,
    double w,
    double h, {
    required bool selected,
  }) {
    final live = (selected && _drag != null) ? _drag! : Offset(r[0], r[1]);
    final bw = (r[2] - r[0]) * w, bh = (r[3] - r[1]) * h;
    final color = Theme.of(context).colorScheme.primary;
    return Positioned(
      left: live.dx * w,
      top: live.dy * h,
      width: bw,
      height: bh,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selected = id),
        onPanStart: (_) => setState(() {
          _selected = id;
          _drag = Offset(r[0], r[1]);
        }),
        onPanUpdate: (d) {
          final cur = _drag ?? Offset(r[0], r[1]);
          final nx = (cur.dx + d.delta.dx / w).clamp(0.0, 1.0 - (r[2] - r[0]));
          final ny = (cur.dy + d.delta.dy / h).clamp(0.0, 1.0 - (r[3] - r[1]));
          setState(() => _drag = Offset(nx, ny));
        },
        onPanEnd: (_) {
          final p = _drag;
          setState(() => _drag = null);
          if (p != null) _setPos(id, x: p.dx, y: p.dy);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.35),
              width: selected ? 2.5 : 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
