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
      appBar: mainAppBar(AppLocalizations.of(context)!.howtoplay_button, context),
      body: Container(
        decoration: const BoxDecoration(gradient: PawPalette.lightBackground),
        child: mainBody(context),
      ),
    );
  }

  Widget mainBody(BuildContext context) {
    final sections = [
      _InstructionSection(
        emoji: '🧑‍🏫',
        title: AppLocalizations.of(context)!.howtoplay_label_forhuman,
        description: AppLocalizations.of(context)!.howtoplay_text_forhuman,
        gradient: PawPalette.pinkToOrange(),
      ),
      _InstructionSection(
        emoji: '🐱',
        title: AppLocalizations.of(context)!.howtoplay_label_forcats,
        description: AppLocalizations.of(context)!.howtoplay_text_forcats,
        gradient: PawPalette.tealToLemon(),
      ),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
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
