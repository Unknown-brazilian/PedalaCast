import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core_channel.dart';
import '../../l10n/app_localizations.dart';
import '../settings/app_settings.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  String? _msg;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.dbgTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 16, children: [
          Text(l.dbgBody),
          FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    final uri = await ref.read(coreProvider).renderDebugPng(ref.read(settingsProvider).layoutJson);
                    if (mounted) setState(() { _busy = false; _msg = l.dbgSaved(uri); });
                  },
            child: Text(l.dbgRender),
          ),
          if (_msg != null) Text(_msg!),
        ]),
      ),
    );
  }
}
