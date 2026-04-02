// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/views/widgets/playful_card.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';

import '../components/main_app_bar.dart';

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
    final sections = [
      _InstructionSection(
        emoji: '🧑‍🏫',
        title: l10n.howtoplay_label_forhuman,
        description: l10n.howtoplay_text_forhuman,
        gradient: PawPalette.pinkToOrange(),
      ),
      _InstructionSection(
        emoji: '🐱',
        title: l10n.howtoplay_label_forcats,
        description: l10n.howtoplay_text_forcats,
        gradient: PawPalette.tealToLemon(),
      ),
      _InstructionSection(
        emoji: '✨',
        title: l10n.howtoplay_label_forstreaks,
        description: l10n.howtoplay_text_forstreaks,
        gradient: const [Color(0xFF4FACFE), Color(0xFF7B61FF)],
      ),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF20133C),
                  Color(0xFF4B2E83),
                  Color(0xFFFF5D8F),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.howtoplay_title,
                  style: PawTextStyles.heading.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(l10n.howtoplay_subtitle, style: PawTextStyles.subheading),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            sections.length,
            (index) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1),
              duration: Duration(milliseconds: 450 + (index * 120)),
              curve: Curves.easeOutBack,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: PlayfulCard(
                emoji: sections[index].emoji,
                title: sections[index].title,
                subtitle: sections[index].description,
                gradient: sections[index].gradient,
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
    required this.emoji,
    required this.title,
    required this.description,
    required this.gradient,
  });

  final String emoji;
  final String title;
  final String description;
  final List<Color> gradient;
}
