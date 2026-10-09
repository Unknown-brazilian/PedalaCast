import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core_channel.dart';
import '../../l10n/app_localizations.dart';

final recordingsProvider =
    FutureProvider.autoDispose<List<Map<dynamic, dynamic>>>(
      (ref) => ref.watch(coreProvider).listRecordings(),
    );

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final core = ref.read(coreProvider);
    final items = ref.watch(recordingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.homeLibrary)),
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(child: Text(l.libEmpty))
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l.libNote),
                  ),
                  for (final r in list)
                    ListTile(
                      leading: const Icon(Icons.movie_outlined),
                      title: Text(r['name'] as String),
                      subtitle: Text(_sub(r)),
                      onTap: () => core.openRecording(r['uri'] as String),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          final uri = r['uri'] as String;
                          if (v == 'open') await core.openRecording(uri);
                          if (v == 'share') await core.shareRecording(uri);
                          if (v == 'delete') {
                            if (!context.mounted) return;
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: Text(l.libDeleteConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: Text(l.libCancel),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    child: Text(l.libDeleteDo),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await core.deleteRecording(uri);
                              ref.invalidate(recordingsProvider);
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'open', child: Text(l.libOpen)),
                          PopupMenuItem(
                            value: 'share',
                            child: Text(l.libShare),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(l.libDelete),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  String _sub(Map<dynamic, dynamic> r) {
    final s = ((r['durationMs'] as num?) ?? 0) ~/ 1000;
    final mb = (((r['size'] as num?) ?? 0) / 1e6).toStringAsFixed(0);
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')} · $mb MB';
  }
}
