// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/services/app_info_service.dart';
import 'package:game_for_cats_2025/services/app_logger.dart';
import 'package:game_for_cats_2025/services/app_share_service.dart';
import 'package:game_for_cats_2025/views/widgets/playful_card.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../components/main_app_bar.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: AppLocalizations.of(context)!.credits_button),
      body: Container(
        decoration: const BoxDecoration(gradient: PawPalette.lightBackground),
        child: mainBody(context),
      ),
    );
  }

  Widget mainBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Text(
            l10n.credits_creators,
            style: PawTextStyles.heading.copyWith(color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.credits_subtitle,
            style: PawTextStyles.subheading.copyWith(color: Colors.black),
          ),
          const SizedBox(height: 20),
          Theme(
            data: ThemeData.light(),
            child: PlayfulCard(
              emoji: '✨',
              title: l10n.game_name,
              subtitle: l10n.credits_creators_text,
              gradient: PawPalette.pinkToOrange(),
            ),
          ),
          Theme(
            data: ThemeData.light(),
            child: PlayfulCard(
              emoji: '📦',
              title: l10n.credits_share_title,
              subtitle: l10n.credits_share_subtitle,
              gradient: PawPalette.tealToLemon(),
              child: FutureBuilder<PackageInfo>(
                future: AppInfoService.instance.load(),
                builder: (context, snapshot) {
                  final versionLabel = snapshot.hasData
                      ? '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                      : l10n.credits_version_loading;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.credits_version_label}: $versionLabel',
                        style: PawTextStyles.cardTitle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: snapshot.hasData
                            ? () => _shareApp(context, snapshot.data!)
                            : null,
                        icon: const Icon(Icons.ios_share_rounded),
                        label: Text(l10n.share_app_button),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareApp(BuildContext context, PackageInfo packageInfo) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await AppShareService.instance.shareText(
        subject: l10n.share_app_button,
        text: l10n.share_app_text(
          l10n.game_name,
          '${packageInfo.version}+${packageInfo.buildNumber}',
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Sharing app details failed', error, stackTrace);
    }
  }
}
