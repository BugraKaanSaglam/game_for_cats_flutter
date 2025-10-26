// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/global/argumentsender_class.dart';
import 'package:game_for_cats_2025/widgets/playful_card.dart';
import 'package:game_for_cats_2025/utils/paw_theme.dart';

import '../global/global_functions.dart';
import '../l10n/app_localizations.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ArgumentSender;

    return Scaffold(
      appBar: mainAppBar(args.title!, context),
      body: Container(
        decoration: const BoxDecoration(gradient: PawPalette.lightBackground),
        child: mainBody(context, args),
      ),
    );
  }

  Widget mainBody(BuildContext context, ArgumentSender args) {
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
