import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// Idioma e rótulos do overlay enviados ao Kotlin (que desenha o vídeo).
Map<String, String> overlayLabels(BuildContext context) {
  final l = AppLocalizations.of(context);
  return {
    'locale': Localizations.localeOf(context).toLanguageTag(),
    'liveLabel': l.ovLiveLabel,
    'recLabel': l.ovRecLabel,
    'hrLabel': l.ovHrLabel,
  };
}
