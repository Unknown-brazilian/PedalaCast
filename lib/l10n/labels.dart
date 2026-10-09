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

/// Nomes dos blocos do overlay (para listas e editor).
Map<String, String> blockNames(AppLocalizations l) => {
  'speed_gauge': l.blk_speed_gauge,
  'distance_climb': l.blk_distance_climb,
  'minimap': l.blk_minimap,
  'elevation_profile': l.blk_elevation_profile,
  'grade_badge': l.blk_grade_badge,
  'hr': l.blk_hr,
  'cadence': l.blk_cadence,
  'power': l.blk_power,
  'phone_status': l.blk_phone_status,
  'live_badge': l.blk_live_badge,
  'pip': l.blk_pip,
};
