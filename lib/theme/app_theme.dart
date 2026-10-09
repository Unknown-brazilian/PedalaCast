import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cores da marca. Fonte única: assets/brand/brand_colors.json.
class BrandColors {
  const BrandColors({
    required this.background,
    required this.accent,
    required this.live,
    required this.text,
    required this.onAccent,
    required this.warning,
  });

  final Color background;
  final Color accent;
  final Color live;
  final Color text;
  final Color onAccent;
  final Color warning;

  /// Superfície: fundo levemente mais claro, para cartões e painéis.
  static const surface = Color(0xFF2A3040);

  /// Texto secundário: branco com ~70% de opacidade sobre o fundo.
  static const textSecondary = Color(0xFFB4B8C2);

  static Color _hex(String s) =>
      Color(int.parse('FF${s.replaceFirst('#', '')}', radix: 16));

  factory BrandColors.fromJson(Map<String, dynamic> j) => BrandColors(
    background: _hex(j['background'] as String),
    accent: _hex(j['accent'] as String),
    live: _hex(j['live'] as String),
    text: _hex(j['text'] as String),
    onAccent: _hex(j['onAccent'] as String),
    warning: _hex(j['warning'] as String),
  );

  static Future<BrandColors> load() async {
    final raw = await rootBundle.loadString('assets/brand/brand_colors.json');
    return BrandColors.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  ThemeData toTheme() {
    final scheme = ColorScheme.dark(
      primary: accent,
      onPrimary: onAccent, // nunca branco sobre laranja
      surface: background,
      onSurface: text,
      surfaceContainer: surface,
      onSurfaceVariant: textSecondary,
      tertiary: live, // somente AO VIVO / gravando
      onTertiary: text,
      error: warning, // avisos e erros usam warning, nunca o vermelho "live"
      onError: onAccent,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: surface),
    );
  }
}
