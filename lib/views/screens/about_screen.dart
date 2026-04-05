import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/services/app_info_service.dart';
import 'package:game_for_cats_2025/views/components/main_app_bar.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

//* About / product-story screen.
//? This screen explains the app identity without surfacing "portfolio shell" signals like debug/build tooling.
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
                const SizedBox(height: 18),
                _StoryPanel(
                  title: l10n.about_story_title,
                  subtitle: l10n.about_story_subtitle,
                  body: l10n.about_story_body,
                ),
                const SizedBox(height: 14),
                _HighlightsPanel(
                  title: l10n.about_highlights_title,
                  subtitle: l10n.about_highlights_subtitle,
                  items: [
                    l10n.about_highlight_one,
                    l10n.about_highlight_two,
                    l10n.about_highlight_three,
                  ],
                ),
                const SizedBox(height: 14),
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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFDF7FF), Color(0xFFF1FBFF)],
        ),
        border: Border.all(color: PawPalette.midnight.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.about_info_title, style: PawTextStyles.cardTitle),
          const SizedBox(height: 6),
          Text(l10n.about_info_subtitle, style: PawTextStyles.cardSubtitle),
          const SizedBox(height: 14),
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
      //* Hero mixes product statement, distinctiveness bullets, and build badge in one fold.
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          colors: [Color(0xFF140F2D), Color(0xFF2A1A58), Color(0xFF0E6B88)],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _AboutBadge(
                icon: Icons.stars_rounded,
                label: l10n.about_highlight_one,
              ),
              _AboutBadge(
                icon: Icons.photo_size_select_large_rounded,
                label: l10n.about_highlight_two,
              ),
              _AboutBadge(
                icon: Icons.insights_rounded,
                label: l10n.about_highlight_three,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
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
    );
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel({
    required this.title,
    required this.subtitle,
    required this.body,
  });

  final String title;
  final String subtitle;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.92),
        border: Border.all(color: PawPalette.midnight.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: PawTextStyles.cardTitle),
          const SizedBox(height: 6),
          Text(subtitle, style: PawTextStyles.cardSubtitle),
          const SizedBox(height: 14),
          Text(body, style: PawTextStyles.cardSubtitle),
        ],
      ),
    );
  }
}

class _HighlightsPanel extends StatelessWidget {
  const _HighlightsPanel({
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final String subtitle;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    //! This panel turns the differentiators into visible product claims instead of burying them in prose.
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFEFFDF9), Color(0xFFF5F1FF)],
        ),
        border: Border.all(color: PawPalette.teal.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: PawTextStyles.cardTitle),
          const SizedBox(height: 6),
          Text(subtitle, style: PawTextStyles.cardSubtitle),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PawPalette.teal.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.pets_rounded,
                      size: 14,
                      color: PawPalette.teal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: PawTextStyles.cardSubtitle),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutBadge extends StatelessWidget {
  const _AboutBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
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
