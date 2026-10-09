import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/about_config.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

final aboutConfigProvider = FutureProvider<AboutConfig>(
  (ref) => AboutConfig.load(),
);
final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cfg = ref.watch(aboutConfigProvider).value;
    final info = ref.watch(packageInfoProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
      body: cfg == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Header(version: info?.version),
                if (cfg.authorName.isNotEmpty) _Author(cfg: cfg),
                if (AboutConfig.isValidLightningAddress(cfg.lightningAddress))
                  _Support(address: cfg.lightningAddress),
                _Legal(cfg: cfg),
              ],
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.version});
  final String? version;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Image.asset('assets/brand/png/app_icon.png', width: 96, height: 96),
        const SizedBox(height: 8),
        Text(l.appName, style: Theme.of(context).textTheme.headlineSmall),
        if (version != null)
          Text(
            l.aboutVersion(version!),
            style: const TextStyle(color: BrandColors.textSecondary),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Author extends StatelessWidget {
  const _Author({required this.cfg});
  final AboutConfig cfg;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _Section(
      title: l.aboutAuthor,
      children: [
        Text(cfg.authorName, style: Theme.of(context).textTheme.titleMedium),
        if (cfg.bio.isNotEmpty) Text(cfg.bio),
        Wrap(
          spacing: 8,
          children: [
            for (final link in cfg.links)
              ActionChip(
                label: Text(link.label),
                onPressed: () => launchUrl(
                  Uri.parse(link.url),
                  mode: LaunchMode.externalApplication,
                ),
              ),
          ],
        ),
        if (cfg.feedbackEmail.isNotEmpty)
          FilledButton(
            onPressed: () =>
                launchUrl(Uri(scheme: 'mailto', path: cfg.feedbackEmail)),
            child: Text(l.aboutSendFeedback),
          ),
      ],
    );
  }
}

class _Support extends StatelessWidget {
  const _Support({required this.address});
  final String address;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _Section(
      title: l.aboutSupportTitle,
      children: [
        Text(l.aboutSupportText),
        Row(
          children: [
            Expanded(child: SelectableText(address)),
            TextButton.icon(
              icon: const Icon(Icons.copy),
              label: Text(l.aboutCopy),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(ClipboardData(text: address));
                messenger.showSnackBar(SnackBar(content: Text(l.aboutCopied)));
              },
            ),
          ],
        ),
        Center(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: QrImageView(data: address, size: 200),
          ),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: Text(l.aboutOpenWallet),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final ok = await launchUrl(Uri.parse('lightning:$address'));
            if (!ok) {
              messenger.showSnackBar(SnackBar(content: Text(l.aboutNoWallet)));
            }
          },
        ),
        Text(
          l.aboutLightningNote,
          style: const TextStyle(color: BrandColors.textSecondary),
        ),
        Text(
          l.aboutDonationDisclaimer,
          style: const TextStyle(color: BrandColors.textSecondary),
        ),
      ],
    );
  }
}

class _Legal extends StatelessWidget {
  const _Legal({required this.cfg});
  final AboutConfig cfg;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _Section(
      title: l.aboutLegal,
      children: [
        if (cfg.privacyPolicyUrl.isNotEmpty)
          ListTile(
            title: Text(l.aboutPrivacyPolicy),
            onTap: () => launchUrl(
              Uri.parse(cfg.privacyPolicyUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ListTile(
          title: Text(l.aboutLicenses),
          onTap: () => showLicensePage(context: context),
        ),
        ListTile(
          leading: const Icon(Icons.warning_amber),
          title: Text(l.aboutSafetyTitle),
          subtitle: Text(l.aboutSafetyText),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          ...children,
        ],
      ),
    ),
  );
}
