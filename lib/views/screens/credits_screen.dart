// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:game_for_cats_2025/views/widgets/playful_card.dart';
import 'package:game_for_cats_2025/views/theme/paw_theme.dart';
import 'package:game_for_cats_2025/l10n/app_localizations.dart';

import '../components/main_app_bar.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(AppLocalizations.of(context)!.credits_button, context),
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
          Text(l10n.credits_creators, style: PawTextStyles.heading.copyWith(color: Colors.black)),
          const SizedBox(height: 6),
          Text(l10n.credits_subtitle, style: PawTextStyles.subheading.copyWith(color: Colors.black)),
          const SizedBox(height: 20),
          Theme(
            data: ThemeData.light(),
            child: PlayfulCard(emoji: '✨', title: l10n.game_name, subtitle: l10n.credits_creators_text, gradient: PawPalette.pinkToOrange()),
          ),
        ],
      ),
    );
  }
}
