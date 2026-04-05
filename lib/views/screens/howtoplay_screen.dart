// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';

import '../components/main_app_bar.dart';

//* How-to screen framed as a short mission briefing rather than a generic FAQ.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: AppLocalizations.of(context)!.howtoplay_button),
      body: Container(
        decoration: const BoxDecoration(gradient: PawPalette.lightBackground),
        child: mainBody(context),
      ),
    );
  }

  Widget mainBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    //? Keeping instructions to three steps reduces cognitive load and makes this screen screenshot-friendly.
    final sections = [
      _InstructionSection(
        step: '01',
        icon: Icons.tune_rounded,
        title: l10n.howtoplay_label_forhuman,
        description: l10n.howtoplay_text_forhuman,
        gradient: PawPalette.pinkToOrange(),
      ),
      _InstructionSection(
        step: '02',
        icon: Icons.ads_click_rounded,
        title: l10n.howtoplay_label_forcats,
        description: l10n.howtoplay_text_forcats,
        gradient: PawPalette.tealToLemon(),
      ),
      _InstructionSection(
        step: '03',
        icon: Icons.auto_awesome_rounded,
        title: l10n.howtoplay_label_forstreaks,
        description: l10n.howtoplay_text_forstreaks,
        gradient: const [Color(0xFF4FACFE), Color(0xFF7B61FF)],
      ),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          _HowToHero(
            title: l10n.howtoplay_title,
            subtitle: l10n.howtoplay_subtitle,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: List.generate(
                sections.length,
                (index) => TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.96, end: 1),
                  duration: Duration(milliseconds: 420 + (index * 120)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: _HowToStepCard(
                    isLast: index == sections.length - 1,
                    data: sections[index],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionSection {
  const _InstructionSection({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  final String step;
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
}

class _HowToHero extends StatelessWidget {
  const _HowToHero({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF140F2D), Color(0xFF2A1A58), Color(0xFF0E6B88)],
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.map_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PawTextStyles.heading.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: PawTextStyles.subheading),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowToStepCard extends StatelessWidget {
  const _HowToStepCard({required this.data, required this.isLast});

  final _InstructionSection data;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    //! The vertical rail gives the screen a route / sequence feeling instead of stacked info cards.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: data.gradient),
                  ),
                  child: Center(
                    child: Text(
                      data.step,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(colors: data.gradient),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Colors.white.withValues(alpha: 0.9),
                border: Border.all(
                  color: data.gradient.first.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.gradient.first.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: data.gradient),
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.title, style: PawTextStyles.cardTitle),
                        const SizedBox(height: 6),
                        Text(
                          data.description,
                          style: PawTextStyles.cardSubtitle,
                        ),
                      ],
                    ),
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
