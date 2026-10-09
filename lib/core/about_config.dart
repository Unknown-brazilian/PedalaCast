import 'dart:convert';

import 'package:flutter/services.dart';

class AboutLink {
  const AboutLink(this.label, this.url);
  final String label;
  final String url;
}

class AboutConfig {
  const AboutConfig({
    required this.authorName,
    required this.bio,
    required this.links,
    required this.feedbackEmail,
    required this.privacyPolicyUrl,
    required this.lightningAddress,
  });

  final String authorName;
  final String bio;
  final List<AboutLink> links;
  final String feedbackEmail;
  final String privacyPolicyUrl;
  final String lightningAddress;

  factory AboutConfig.fromJson(Map<String, dynamic> j) => AboutConfig(
    authorName: (j['authorName'] as String?) ?? '',
    bio: (j['bio'] as String?) ?? '',
    links: [
      for (final l in (j['links'] as List<dynamic>? ?? const []))
        AboutLink((l as Map)['label'] as String, l['url'] as String),
    ],
    feedbackEmail: (j['feedbackEmail'] as String?) ?? '',
    privacyPolicyUrl: (j['privacyPolicyUrl'] as String?) ?? '',
    lightningAddress: (j['lightningAddress'] as String?) ?? '',
  );

  static Future<AboutConfig> load() async => AboutConfig.fromJson(
    jsonDecode(await rootBundle.loadString('assets/about_config.json'))
        as Map<String, dynamic>,
  );

  /// Valida o formato `nome@dominio` de um endereço Lightning.
  static bool isValidLightningAddress(String a) => RegExp(
    r'^[a-z0-9._+-]+@[a-z0-9-]+(\.[a-z0-9-]+)+$',
    caseSensitive: false,
  ).hasMatch(a.trim());
}
