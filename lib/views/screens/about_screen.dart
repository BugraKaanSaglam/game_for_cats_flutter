import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/services/app_info_service.dart';
import 'package:game_for_cats_2025/services/app_logger.dart';
import 'package:game_for_cats_2025/services/app_share_service.dart';
import 'package:game_for_cats_2025/services/connectivity_service.dart';
import 'package:game_for_cats_2025/views/components/main_app_bar.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/views/widgets/playful_card.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
    AppAnalytics.screenView('about');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: MainAppBar(title: l10n.about_button),
      body: Container(
        decoration: const BoxDecoration(gradient: PawPalette.lightBackground),
        child: FutureBuilder<PackageInfo>(
          future: AppInfoService.instance.load(),
          builder: (context, snapshot) {
            final packageInfo = snapshot.data;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                Text(
                  l10n.about_title,
                  style: PawTextStyles.heading.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.about_subtitle,
                  style: PawTextStyles.subheading.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 20),
                _AppInfoCard(packageInfo: packageInfo),
                const _ConnectivityCard(),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AppInfoCard extends StatelessWidget {
  const _AppInfoCard({required this.packageInfo});

  final PackageInfo? packageInfo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final versionText = packageInfo == null
        ? l10n.credits_version_loading
        : '${packageInfo!.version}+${packageInfo!.buildNumber}';

    return PlayfulCard(
      emoji: 'ℹ️',
      title: l10n.about_info_title,
      subtitle: l10n.about_info_subtitle,
      gradient: PawPalette.pinkToOrange(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(label: l10n.credits_version_label, value: versionText),
          _InfoLine(
            label: l10n.about_platform_label,
            value: defaultTargetPlatform.name,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: packageInfo == null
                ? null
                : () => _shareApp(context, versionText),
            icon: const Icon(Icons.share_outlined),
            label: Text(l10n.share_app_button),
          ),
        ],
      ),
    );
  }

  Future<void> _shareApp(BuildContext context, String versionText) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await AppShareService.instance.shareText(
        subject: l10n.share_app_button,
        text: l10n.share_app_text(l10n.game_name, versionText),
      );
      AppAnalytics.track(
        AnalyticsEvent.appShared,
        parameters: <String, Object?>{
          'source': 'about',
          'version': versionText,
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Sharing app from about screen failed',
        error,
        stackTrace,
      );
    }
  }
}

class _ConnectivityCard extends StatelessWidget {
  const _ConnectivityCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = context.watch<ConnectivityController>().status;
    final label = switch (status) {
      ConnectionStateStatus.online => l10n.connectivity_status_online,
      ConnectionStateStatus.offline => l10n.connectivity_status_offline,
      ConnectionStateStatus.unknown => l10n.connectivity_status_unknown,
    };

    final tone = switch (status) {
      ConnectionStateStatus.online => Colors.green,
      ConnectionStateStatus.offline => Colors.deepOrange,
      ConnectionStateStatus.unknown => Colors.blueGrey,
    };

    return PlayfulCard(
      emoji: '📶',
      title: l10n.connectivity_title,
      subtitle: l10n.connectivity_subtitle,
      gradient: PawPalette.tealToLemon(),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: PawTextStyles.cardTitle.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: PawTextStyles.cardSubtitle,
          children: [
            TextSpan(
              text: '$label: ',
              style: PawTextStyles.cardTitle.copyWith(fontSize: 15),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
