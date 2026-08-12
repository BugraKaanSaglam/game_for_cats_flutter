import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';
import 'package:game_for_cats_2025/services/app_analytics.dart';
import 'package:game_for_cats_2025/views/components/hunt_ui.dart';
import 'package:game_for_cats_2025/views/components/main_app_bar.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {
  bool _practiceTapped = false;

  @override
  void initState() {
    super.initState();
    AppAnalytics.screenView('how_to_play');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: MainAppBar(title: l10n.howtoplay_button),
      body: ColoredBox(
        color: HuntColors.paperWarm,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(HuntSpacing.lg),
                children: [
                  HuntSectionHeading(
                    eyebrow: l10n.guide_practice,
                    title: l10n.howtoplay_title,
                    subtitle: l10n.howtoplay_subtitle,
                  ),
                  const SizedBox(height: HuntSpacing.lg),
                  HuntSurface(
                    tone: HuntSurfaceTone.field,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.guide_practice,
                          style: HuntTextStyles.sectionTitle,
                        ),
                        const SizedBox(height: HuntSpacing.xs),
                        Text(
                          l10n.guide_practice_subtitle,
                          style: HuntTextStyles.supporting,
                        ),
                        const SizedBox(height: HuntSpacing.md),
                        GestureDetector(
                          onTap: () => setState(() => _practiceTapped = true),
                          child: SizedBox(
                            height: 190,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _GuideFieldPainter(
                                tapped: _practiceTapped,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: HuntSpacing.sm),
                        HuntTag(
                          label: _practiceTapped
                              ? l10n.onboarding_title_track
                              : l10n.onboarding_title_play,
                          icon: _practiceTapped
                              ? Icons.check_rounded
                              : Icons.touch_app_outlined,
                          tone: _practiceTapped
                              ? HuntTagTone.success
                              : HuntTagTone.neutral,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: HuntSpacing.md),
                  _GuideSection(
                    step: '01',
                    title: l10n.howtoplay_label_forhuman,
                    text: l10n.howtoplay_text_forhuman,
                    icon: Icons.tune_rounded,
                  ),
                  _GuideSection(
                    step: '02',
                    title: l10n.howtoplay_label_forcats,
                    text: l10n.howtoplay_text_forcats,
                    icon: Icons.ads_click_rounded,
                  ),
                  _GuideSection(
                    step: '03',
                    title: l10n.howtoplay_label_forstreaks,
                    text: l10n.howtoplay_text_forstreaks,
                    icon: Icons.auto_awesome_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({
    required this.step,
    required this.title,
    required this.text,
    required this.icon,
  });

  final String step;
  final String title;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return HuntSurface(
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
                Text(step, style: HuntTextStyles.eyebrow),
                const SizedBox(height: HuntSpacing.xs),
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

class _GuideFieldPainter extends CustomPainter {
  const _GuideFieldPainter({required this.tapped});

  final bool tapped;

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = HuntColors.fieldLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(HuntRadii.md),
      ),
      border,
    );
    final center = Offset(
      size.width * (tapped ? 0.66 : 0.32),
      size.height * 0.48,
    );
    final color = tapped ? HuntColors.moss : HuntColors.coral;
    canvas.drawCircle(center, 31, Paint()..color = color);
    canvas.drawCircle(
      center,
      20,
      Paint()..color = HuntColors.paper.withValues(alpha: 0.82),
    );
    canvas.drawCircle(center, 8, Paint()..color = color);
    final path = Path()..moveTo(size.width * 0.1, size.height * 0.76);
    for (var i = 0; i < 4; i++) {
      path.lineTo(
        size.width * (0.22 + i * 0.18),
        size.height * (0.72 + math.sin(i) * 0.04),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = HuntColors.moss.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _GuideFieldPainter oldDelegate) =>
      oldDelegate.tapped != tapped;
}
