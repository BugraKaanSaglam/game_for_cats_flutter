import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/services/app_info_service.dart';
import 'package:game_for_cats_2025/views/components/hunt_ui.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Product story and runtime build information.
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
    return HuntCorePage(
      title: l10n.about_button,
      child: FutureBuilder<PackageInfo>(
        future: AppInfoService.instance.load(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          return HuntCoreViewport(
            child: ListView(
              children: [
                HuntCoreHeader(
                  eyebrow: l10n.about_button,
                  title: l10n.about_title,
                  subtitle: l10n.about_subtitle,
                  tone: HuntSurfaceTone.accent,
                ),
                const SizedBox(height: HuntSpacing.lg),
                HuntSurface(
                  tone: HuntSurfaceTone.field,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.track_changes,
                        color: HuntColors.moss,
                        size: 38,
                      ),
                      const SizedBox(height: HuntSpacing.md),
                      Text(
                        l10n.about_story_title,
                        style: HuntTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: HuntSpacing.sm),
                      Text(l10n.about_story_body, style: HuntTextStyles.body),
                      const SizedBox(height: HuntSpacing.md),
                      Text(
                        l10n.about_local_note,
                        style: HuntTextStyles.supporting,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: HuntSpacing.md),
                HuntSurface(
                  tone: HuntSurfaceTone.accent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.about_info_title,
                        style: HuntTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: HuntSpacing.md),
                      _InfoLine(
                        label: l10n.credits_creators,
                        value: l10n.credits_creators_text,
                      ),
                      _InfoLine(
                        label: l10n.credits_version_label,
                        value: info == null
                            ? l10n.credits_version_loading
                            : '${info.version}+${info.buildNumber}',
                      ),
                      _InfoLine(
                        label: l10n.about_platform_label,
                        value: defaultTargetPlatform.name,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
      padding: const EdgeInsets.only(bottom: HuntSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: HuntTextStyles.caption)),
          const SizedBox(width: HuntSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: HuntTextStyles.supporting,
            ),
          ),
        ],
      ),
    );
  }
}
