import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../record/record_screen.dart';
import '../settings/app_settings.dart';
import 'live_store.dart';

class LiveSetupScreen extends ConsumerStatefulWidget {
  const LiveSetupScreen({super.key});

  @override
  ConsumerState<LiveSetupScreen> createState() => _LiveSetupScreenState();
}

class _LiveSetupScreenState extends ConsumerState<LiveSetupScreen> {
  final _store = LiveStore();
  final _url = TextEditingController(text: LiveStore.defaultUrl);
  final _key = TextEditingController();
  bool _show = false;
  bool _loaded = false;
  String? _urlError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _url.text = await _store.url();
    _key.text = (await _store.key()) ?? '';
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _url.dispose();
    _key.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final l = AppLocalizations.of(context);
    if (!LiveStore.isValidUrl(_url.text)) {
      setState(() => _urlError = l.liveBadUrl);
      return;
    }
    if (_key.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.liveNoKey)));
      return;
    }
    await _store.save(_url.text, _key.text);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RecordScreen(live: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l.liveTitle)),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l.liveHelp),
                const SizedBox(height: 16),
                TextField(
                  controller: _url,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l.liveUrl,
                    errorText: _urlError,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _key,
                  obscureText: !_show,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l.liveKey,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _show ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _show = !_show),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(l.liveKeyHint, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                Text(
                  l.liveQuality,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 720, label: Text(l.live720)),
                    ButtonSegment(value: 1080, label: Text(l.live1080)),
                  ],
                  selected: {s.liveHeight},
                  onSelectionChanged: (v) =>
                      n.update(s.copyWith(liveHeight: v.first)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.liveRecordLocal),
                  subtitle: Text(l.liveRecordLocalHint),
                  value: s.liveRecordLocal,
                  onChanged: (v) => n.update(s.copyWith(liveRecordLocal: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.liveHideMap),
                  value: s.hideMinimap,
                  onChanged: (v) => n.update(s.copyWith(hideMinimap: v)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 64,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.podcasts),
                    label: Text(l.liveGo, style: const TextStyle(fontSize: 18)),
                    onPressed: _go,
                  ),
                ),
                const SizedBox(height: 12),
                Text(l.liveTip, style: const TextStyle(fontSize: 12)),
              ],
            ),
    );
  }
}
