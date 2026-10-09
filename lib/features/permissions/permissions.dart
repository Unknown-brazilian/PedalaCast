import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../l10n/app_localizations.dart';

final _required = [Permission.camera, Permission.microphone, Permission.locationWhenInUse];

Future<bool> hasAllPermissions() async {
  for (final p in _required) {
    if (!await p.isGranted) return false;
  }
  return true;
}

/// Pede câmera, microfone, localização precisa e (Android 13+) notificações.
/// Notificação negada não impede a gravação.
Future<bool> requestAllPermissions() async {
  final r = await _required.request();
  await Permission.notification.request();
  await Permission.phone.request(); // intensidade do sinal; opcional
  return r.values.every((s) => s.isGranted);
}

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key, required this.onGrant, required this.denied});
  final VoidCallback onGrant;
  final bool denied;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(l.permTitle, style: Theme.of(context).textTheme.headlineSmall),
              Text(l.permIntro),
              Text('• ${l.permCamera}'),
              Text('• ${l.permMic}'),
              Text('• ${l.permLocation}'),
              Text('• ${l.permNotif}'),
              if (denied)
                Row(children: [
                  Icon(Icons.warning_amber, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l.permDenied)),
                ]),
              FilledButton(onPressed: onGrant, child: Text(l.permGrant)),
              if (denied) TextButton(onPressed: openAppSettings, child: Text(l.permOpenSettings)),
            ],
          ),
        ),
      ),
    );
  }
}
