import 'package:flutter/material.dart';
import 'package:mice_and_paws_cat_game/l10n/app_localizations.dart';
import 'package:mice_and_paws_cat_game/services/app_analytics.dart';
import 'package:mice_and_paws_cat_game/views/components/hunt_ui.dart';
import 'package:mice_and_paws_cat_game/views/theme/paw_theme.dart';

/// Short human and cat instructions shown before the first hunt.
class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {
  @override
  void initState() {
    super.initState();
    AppAnalytics.screenView('how_to_play');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return HuntCorePage(
      title: l10n.howtoplay_button,
      child: HuntCoreViewport(
        child: ListView(
          children: [
            HuntCoreHeader(
              eyebrow: l10n.howtoplay_button,
              title: l10n.howtoplay_title,
              subtitle: l10n.howtoplay_subtitle,
            ),
            const SizedBox(height: HuntSpacing.lg),
            _GuideSection(
              title: l10n.howtoplay_label_forhuman,
              text: l10n.howtoplay_text_forhuman,
              icon: Icons.person_rounded,
              tone: HuntSurfaceTone.field,
            ),
            _GuideSection(
              title: l10n.howtoplay_label_forcats,
              text: l10n.howtoplay_text_forcats,
              icon: Icons.pets_rounded,
              tone: HuntSurfaceTone.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({
    required this.title,
    required this.text,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String text;
  final IconData icon;
  final HuntSurfaceTone tone;

  @override
  Widget build(BuildContext context) {
    return HuntSurface(
      tone: tone,
      margin: const EdgeInsets.only(bottom: HuntSpacing.md),
      padding: const EdgeInsets.all(HuntSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: HuntColors.field,
              borderRadius: BorderRadius.circular(HuntRadii.sm),
              border: Border.all(color: HuntColors.fieldLine),
            ),
            child: Center(child: Icon(icon, color: HuntColors.moss, size: 21)),
          ),
          const SizedBox(width: HuntSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: HuntTextStyles.sectionTitle.copyWith(fontSize: 17),
                ),
                const SizedBox(height: HuntSpacing.sm),
                Text(text, style: HuntTextStyles.supporting),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
