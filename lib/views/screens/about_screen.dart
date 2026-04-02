import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/services/app_info_service.dart';
import 'package:game_for_cats_2025/views/components/main_app_bar.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/views/widgets/playful_card.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
                _AboutHero(packageInfo: packageInfo),
                const SizedBox(height: 12),
                PlayfulCard(
                  emoji: '🐾',
                  title: l10n.about_story_title,
                  subtitle: l10n.about_story_subtitle,
                  gradient: PawPalette.pinkToOrange(),
                  child: Text(
                    l10n.about_story_body,
                    style: PawTextStyles.cardSubtitle,
                  ),
                ),
                PlayfulCard(
                  emoji: '🎯',
                  title: l10n.about_highlights_title,
                  subtitle: l10n.about_highlights_subtitle,
                  gradient: PawPalette.tealToLemon(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BulletLine(text: l10n.about_highlight_one),
                      _BulletLine(text: l10n.about_highlight_two),
                      _BulletLine(text: l10n.about_highlight_three),
                    ],
                  ),
                ),
                _AppInfoCard(packageInfo: packageInfo),
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
      emoji: '🧶',
      title: l10n.about_info_title,
      subtitle: l10n.about_info_subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(
            label: l10n.credits_creators,
            value: l10n.credits_creators_text,
          ),
          _InfoLine(label: l10n.credits_version_label, value: versionText),
          _InfoLine(
            label: l10n.about_platform_label,
            value: defaultTargetPlatform.name,
          ),
          _InfoLine(
            label: l10n.about_release_model_label,
            value: l10n.about_release_model_value,
          ),
        ],
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero({required this.packageInfo});

  final PackageInfo? packageInfo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final versionText = packageInfo == null
        ? l10n.credits_version_loading
        : '${packageInfo!.version}+${packageInfo!.buildNumber}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1238), Color(0xFF3A2A72), Color(0xFFFF5D8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: PawPalette.midnight.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.about_title, style: PawTextStyles.heading),
                const SizedBox(height: 6),
                Text(l10n.about_subtitle, style: PawTextStyles.subheading),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    '${l10n.credits_version_label}: $versionText',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: PawPalette.bubbleGum),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: PawTextStyles.cardSubtitle)),
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
